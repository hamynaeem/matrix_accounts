// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/inventory_models.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/transaction_model.dart';

class PurchaseReturnFormScreen extends ConsumerStatefulWidget {
  const PurchaseReturnFormScreen({super.key});

  @override
  ConsumerState<PurchaseReturnFormScreen> createState() =>
      _PurchaseReturnFormScreenState();
}

class _PurchaseReturnFormScreenState
    extends ConsumerState<PurchaseReturnFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _returnNoController = TextEditingController();
  final _notesController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(symbol: 'PKR ');
  final _dateFormat = DateFormat('dd MMM yyyy');

  Party? _selectedSupplier;
  Invoice? _selectedOriginalInvoice;
  DateTime _returnDate = DateTime.now();
  final List<_ReturnLineItem> _returnItems = [];
  double _totalReturnAmount = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateReturnNumber();
  }

  @override
  void dispose() {
    _returnNoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generateReturnNumber() {
    final now = DateTime.now();
    _returnNoController.text =
        'PR${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecond.toString().padLeft(3, '0')}';
  }

  Future<List<Party>> _loadSuppliers() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return [];

    final isar = ref.read(isarServiceProvider).isar;
    return await isar
        .collection<Party>()
        .filter()
        .companyIdEqualTo(company.id)
        .and()
        .partyTypeEqualTo(PartyType.supplier)
        .findAll();
  }

  Future<List<Invoice>> _loadPurchaseInvoices() async {
    if (_selectedSupplier == null) return [];

    final company = ref.read(currentCompanyProvider);
    if (company == null) return [];

    final isar = ref.read(isarServiceProvider).isar;
    return await isar
        .collection<Invoice>()
        .filter()
        .companyIdEqualTo(company.id)
        .and()
        .invoiceTypeEqualTo(InvoiceType.purchase)
        .and()
        .partyIdEqualTo(_selectedSupplier!.id)
        .and()
        .not()
        .statusEqualTo('Return')
        .sortByInvoiceDateDesc()
        .findAll();
  }

  Future<void> _loadOriginalInvoiceItems() async {
    if (_selectedOriginalInvoice == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final isar = ref.read(isarServiceProvider).isar;
      final transactionLines = await isar
          .collection<TransactionLine>()
          .filter()
          .transactionIdEqualTo(_selectedOriginalInvoice!.transactionId)
          .findAll();

      _returnItems.clear();
      for (final line in transactionLines) {
        if (line.productId != null) {
          final product = await isar.collection<Product>().get(line.productId!);
          if (product != null) {
            _returnItems.add(_ReturnLineItem(
              productId: product.id,
              productName: product.name,
              originalQuantity: line.quantity,
              originalUnitPrice: line.unitPrice,
              returnQuantity: 0.0,
              returnUnitPrice: line.unitPrice,
            ));
          }
        }
      }

      _calculateTotal();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading invoice items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotal() {
    _totalReturnAmount = _returnItems.fold(
        0.0, (sum, item) => sum + (item.returnQuantity * item.returnUnitPrice));
    setState(() {});
  }

  Future<void> _saveReturn() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      _showError('Please select a supplier');
      return;
    }
    if (_selectedOriginalInvoice == null) {
      _showError('Please select original purchase invoice');
      return;
    }
    if (_returnItems.where((item) => item.returnQuantity > 0).isEmpty) {
      _showError('Please add at least one item to return');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final company = ref.read(currentCompanyProvider);
      if (company == null) throw Exception('No company selected');

      final isar = ref.read(isarServiceProvider).isar;

      // Create return transaction
      final transaction = Transaction()
        ..companyId = company.id
        ..type = TransactionType.purchaseReturn
        ..date = _returnDate
        ..referenceNo = _returnNoController.text
        ..partyId = _selectedSupplier!.id
        ..totalAmount = _totalReturnAmount
        ..isPosted = true
        ..createdAt = DateTime.now();

      // Save transaction
      await isar.writeTxn(() async {
        final transactionId =
            await isar.collection<Transaction>().put(transaction);

        // Create transaction lines for returned items
        for (final item in _returnItems) {
          if (item.returnQuantity > 0) {
            final transactionLine = TransactionLine()
              ..transactionId = transactionId
              ..productId = item.productId
              ..quantity = item.returnQuantity
              ..unitPrice = item.returnUnitPrice
              ..lineAmount = item.returnQuantity * item.returnUnitPrice;

            await isar.collection<TransactionLine>().put(transactionLine);
          }
        }

        // Create return invoice
        final returnInvoice = Invoice()
          ..companyId = company.id
          ..transactionId = transactionId
          ..invoiceType = InvoiceType.purchase
          ..partyId = _selectedSupplier!.id
          ..invoiceDate = _returnDate
          ..grandTotal = _totalReturnAmount
          ..status = 'Return';

        await isar.collection<Invoice>().put(returnInvoice);

        // Update stock ledger for returned items
        for (final item in _returnItems) {
          if (item.returnQuantity > 0) {
            final stockLedger = StockLedger()
              ..companyId = company.id
              ..productId = item.productId
              ..date = _returnDate
              ..movementType = StockMovementType
                  .outAdjustment // Returning items reduces stock
              ..quantityDelta =
                  -item.returnQuantity // Negative because it's going out
              ..unitCost = item.returnUnitPrice
              ..totalCost = item.returnQuantity * item.returnUnitPrice
              ..transactionId = transactionId;

            await isar.collection<StockLedger>().put(stockLedger);
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase return created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Go back to return list
      }
    } catch (e) {
      if (mounted) {
        _showError('Error creating purchase return: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);

    if (company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Purchase Return')),
        body: const Center(
          child: Text('Please select a company first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Purchase Return'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          TextButton.icon(
            onPressed: _isLoading ? null : _saveReturn,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'purchase-returns',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Return Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Return Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Return Number and Date
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _returnNoController,
                              decoration: const InputDecoration(
                                labelText: 'Return Number',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter return number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _returnDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _returnDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Return Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(_dateFormat.format(_returnDate)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Supplier Selection
                      FutureBuilder<List<Party>>(
                        future: _loadSuppliers(),
                        builder: (context, snapshot) {
                          final suppliers = snapshot.data ?? [];

                          // Ensure selected supplier matches one from the list
                          Party? validSelectedSupplier;
                          if (_selectedSupplier != null &&
                              suppliers.isNotEmpty) {
                            validSelectedSupplier = suppliers.firstWhere(
                              (supplier) =>
                                  supplier.id == _selectedSupplier!.id,
                              orElse: () => suppliers.first,
                            );
                          }

                          return DropdownButtonFormField<Party>(
                            initialValue: validSelectedSupplier,
                            decoration: const InputDecoration(
                              labelText: 'Select Supplier',
                              border: OutlineInputBorder(),
                            ),
                            items: suppliers.map((supplier) {
                              return DropdownMenuItem<Party>(
                                value: supplier,
                                child: Text(supplier.name),
                              );
                            }).toList(),
                            onChanged: (supplier) {
                              setState(() {
                                _selectedSupplier = supplier;
                                _selectedOriginalInvoice = null;
                                _returnItems.clear();
                                _totalReturnAmount = 0.0;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a supplier';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Original Purchase Invoice Selection
                      if (_selectedSupplier != null)
                        FutureBuilder<List<Invoice>>(
                          future: _loadPurchaseInvoices(),
                          builder: (context, snapshot) {
                            final invoices = snapshot.data ?? [];

                            // Ensure selected invoice matches one from the list
                            Invoice? validSelectedInvoice;
                            if (_selectedOriginalInvoice != null &&
                                invoices.isNotEmpty) {
                              validSelectedInvoice = invoices.firstWhere(
                                (invoice) =>
                                    invoice.id == _selectedOriginalInvoice!.id,
                                orElse: () => invoices.first,
                              );
                            }

                            return DropdownButtonFormField<Invoice>(
                              initialValue: validSelectedInvoice,
                              decoration: const InputDecoration(
                                labelText: 'Select Original Purchase Invoice',
                                border: OutlineInputBorder(),
                              ),
                              items: invoices.map((invoice) {
                                return DropdownMenuItem<Invoice>(
                                  value: invoice,
                                  child: FutureBuilder<Transaction?>(
                                    future: ref
                                        .read(isarServiceProvider)
                                        .isar
                                        .collection<Transaction>()
                                        .get(invoice.transactionId),
                                    builder: (context, txnSnapshot) {
                                      final transaction = txnSnapshot.data;
                                      return Text(
                                        '${transaction?.referenceNo ?? 'N/A'} - ${_currencyFormat.format(invoice.grandTotal)} - ${_dateFormat.format(invoice.invoiceDate)}',
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                              onChanged: (invoice) {
                                setState(() {
                                  _selectedOriginalInvoice = invoice;
                                });
                                if (invoice != null) {
                                  _loadOriginalInvoiceItems();
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select original purchase invoice';
                                }
                                return null;
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Return Items Card
              if (_returnItems.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Return Items',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Total: ${_currencyFormat.format(_totalReturnAmount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _returnItems.length,
                          itemBuilder: (context, index) {
                            final item = _returnItems[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Original Qty: ${item.originalQuantity}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'Unit Price: ${_currencyFormat.format(item.originalUnitPrice)}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: TextFormField(
                                            initialValue:
                                                item.returnQuantity.toString(),
                                            decoration: const InputDecoration(
                                              labelText: 'Return Qty',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 8,
                                              ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              final qty =
                                                  double.tryParse(value) ?? 0.0;
                                              if (qty <=
                                                  item.originalQuantity) {
                                                item.returnQuantity = qty;
                                                _calculateTotal();
                                              }
                                            },
                                            validator: (value) {
                                              final qty = double.tryParse(
                                                      value ?? '') ??
                                                  0.0;
                                              if (qty < 0) {
                                                return 'Invalid';
                                              }
                                              if (qty > item.originalQuantity) {
                                                return 'Max ${item.originalQuantity}';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _currencyFormat.format(
                                            item.returnQuantity *
                                                item.returnUnitPrice,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveReturn,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label:
                        Text(_isLoading ? 'Saving...' : 'Save Purchase Return'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReturnLineItem {
  final int productId;
  final String productName;
  final double originalQuantity;
  final double originalUnitPrice;
  double returnQuantity;
  final double returnUnitPrice;

  _ReturnLineItem({
    required this.productId,
    required this.productName,
    required this.originalQuantity,
    required this.originalUnitPrice,
    required this.returnQuantity,
    required this.returnUnitPrice,
  });
}
