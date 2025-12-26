import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:matrix_accounts/data/models/transaction_model.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/sales_dao.dart';
import '../../../data/models/account_models.dart' as account_models;
import '../../../data/models/company_model.dart';
import '../../../data/models/inventory_models.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/models/user_model.dart';
import '../../inventory/presentation/product_selection_screen.dart';
import '../../parties/presentation/party_selection_screen.dart';
import '../../payments/logic/payment_providers.dart';
import '../logic/sales_providers.dart';
import '../services/invoice_generator.dart';
import '../services/sales_invoice_service.dart';

class SaleLineDraft {
  int? productId;
  String? productName;
  double qty;
  double rate;

  SaleLineDraft({
    this.productId,
    this.productName,
    this.qty = 1,
    this.rate = 0,
  });
}

class PaymentLineDraft {
  int? accountId;
  String? accountName;
  String? accountIcon;
  double amount;

  PaymentLineDraft({
    this.accountId,
    this.accountName,
    this.accountIcon,
    this.amount = 0,
  });
}

class SalesInvoiceFormScreen extends ConsumerStatefulWidget {
  final int? invoiceId;

  const SalesInvoiceFormScreen({super.key, this.invoiceId});

  @override
  ConsumerState<SalesInvoiceFormScreen> createState() {
    return _SalesInvoiceFormScreenState();
  }
}

class _SalesInvoiceFormScreenState
    extends ConsumerState<SalesInvoiceFormScreen> {
  Party? _selectedCustomer;
  DateTime _date = DateTime.now();
  final _refNoCtrl = TextEditingController();
  final List<SaleLineDraft> _lines = [];
  final List<PaymentLineDraft> _paymentLines = []; // NEW: payment lines
  String _discountType = 'Flat';
  double _discountValue = 0;
  double _vat = 0;
  double _shippingCharge = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.invoiceId != null) {
      _loadInvoice();
    } else {
      _refNoCtrl.text = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      _addDefaultCashPayment().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  Future<void> _addDefaultCashPayment() async {
    // Load the actual cash account
    final paymentDao = ref.read(paymentDaoProvider);
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      final accounts = await paymentDao.getPaymentAccounts(company.id);
      final cashAccount = accounts
          .where((a) => a.accountType == PaymentAccountType.cash)
          .firstOrNull;

      if (cashAccount != null && mounted) {
        setState(() {
          _paymentLines.add(PaymentLineDraft(
            accountId: cashAccount.id,
            accountName: cashAccount.accountName,
            accountIcon: cashAccount.icon,
            amount: 0,
          ));
        });
      }
    }
  }

  Future<void> _loadInvoice() async {
    try {
      final salesDao = ref.read(salesDaoProvider);
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;

      final invoice = await salesDao.getInvoiceById(widget.invoiceId!);
      if (invoice == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice not found')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final transaction =
          await salesDao.getTransactionForInvoice(widget.invoiceId!);
      if (transaction == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction not found')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final lines = await salesDao.getTransactionLines(transaction.id);
      final customer = await isar.partys.get(invoice.partyId);

      setState(() {
        _selectedCustomer = customer;
        _date = invoice.invoiceDate;
        _refNoCtrl.text = transaction.referenceNo;
        _lines.clear();

        for (final line in lines) {
          final productId = line.productId;
          final product =
              productId != null ? isar.products.getSync(productId) : null;
          _lines.add(SaleLineDraft(
            productId: line.productId,
            productName: product?.name ?? 'Unknown',
            qty: line.quantity,
            rate: line.unitPrice,
          ));
        }

        if (_lines.isEmpty) {
          _lines.add(SaleLineDraft());
        }

        // Load payment lines from account transactions
        _paymentLines.clear();
        _loadPaymentLines(invoice.companyId, invoice.id);

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoice: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadPaymentLines(int companyId, int invoiceId) async {
    try {
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;
      final paymentDao = ref.read(paymentDaoProvider);

      // Get all payment account transactions for this invoice (manual query to avoid extension issues)
      final allAccountTransactions =
          await isar.accountTransactions.where().findAll();
      final payments = allAccountTransactions
          .where((p) =>
              p.companyId == companyId &&
              p.referenceId == invoiceId &&
              p.transactionType == account_models.TransactionType.saleInvoice)
          .toList();

      final paymentAccounts = await paymentDao.getPaymentAccounts(companyId);

      for (final payment in payments) {
        // Get the account to check if it's a cash/bank account (not AR)
        final account = await isar.accounts.get(payment.accountId);
        if (account != null &&
            (account.code == '1000' ||
                account.code == '1050' ||
                account.code == '1100')) {
          // This is a cash/bank payment, determine the account type
          PaymentAccountType accountType;
          if (account.code == '1000') {
            accountType = PaymentAccountType.cash;
          } else if (account.code == '1050') {
            accountType = PaymentAccountType.cheque;
          } else {
            accountType = PaymentAccountType.bank;
          }

          // Find a matching payment account or use first of same type
          final matchingAccounts = paymentAccounts
              .where((pa) => pa.accountType == accountType)
              .toList();
          if (matchingAccounts.isNotEmpty && mounted) {
            final paymentAccount = matchingAccounts.first;

            setState(() {
              _paymentLines.add(PaymentLineDraft(
                accountId: paymentAccount.id,
                accountName: paymentAccount.accountName,
                accountIcon: paymentAccount.icon,
                amount: payment.debit, // Debit represents cash received
              ));
            });
          }
        }
      }

      // If no payment lines were loaded, add a default cash line
      if (mounted && _paymentLines.isEmpty) {
        final cashAccount = paymentAccounts
            .where((a) => a.accountType == PaymentAccountType.cash)
            .firstOrNull;

        if (cashAccount != null) {
          setState(() {
            _paymentLines.add(PaymentLineDraft(
              accountId: cashAccount.id,
              accountName: cashAccount.accountName,
              accountIcon: cashAccount.icon,
              amount: 0,
            ));
          });
        }
      }
    } catch (e) {
      // Silently fail - user can manually add payments
      print('Error loading payment lines: $e');
    }
  }

  @override
  void dispose() {
    _refNoCtrl.dispose();
    super.dispose();
  }

  double get _subTotal =>
      _lines.fold<double>(0, (sum, l) => sum + (l.qty * l.rate));

  double get _totalDiscount {
    if (_discountType == 'Flat') return _discountValue;
    return _subTotal * (_discountValue / 100);
  }

  double get _afterDiscount => _subTotal - _totalDiscount;

  double get _totalVAT => _afterDiscount * (_vat / 100);

  double get _grandTotal => _afterDiscount + _totalVAT + _shippingCharge;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final user = ref.watch(currentUserProvider);
    final productAsync = ref.watch(productListProvider);
    final salesDao = ref.read(salesDaoProvider);

    if (company == null) {
      return const Scaffold(
        body: Center(child: Text('No company selected')),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoiceId != null ? 'Edit Sales' : 'Add Sales'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                company.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerSelector(context),
              const SizedBox(height: 20),
              productAsync.when(
                data: (products) => Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _lines.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildLineItem(context, _lines[i], products, i),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                        ),
                        onPressed: () async {
                          final selected = await Navigator.push<Product>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductSelectionScreen(
                                title: 'Select Product',
                              ),
                            ),
                          );
                          if (selected != null) {
                            setState(() {
                              _lines.add(SaleLineDraft(
                                productId: selected.id,
                                productName: selected.name,
                                qty: 1,
                                rate: selected.salePrice,
                              ));
                            });
                          }
                        },
                        child: Text(
                          'Add Items',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Error loading products')),
              ),
              const SizedBox(height: 20),
              _buildCalculationCard(),
              const SizedBox(height: 20),
              _buildPaymentLinesSection(),
              const SizedBox(height: 20),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.note),
                ),
                onChanged: (v) {},
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.red.shade600),
                      ),
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          _saveSalesInvoice(salesDao, company, user),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _saveAndShareInvoice(salesDao, company, user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    'Save & Share',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSalesInvoice(
      SalesDao salesDao, Company company, User? user) async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final validLines = _lines
        .where((l) => l.productId != null && l.qty > 0 && l.rate > 0)
        .toList();

    if (validLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final inputs = validLines
        .map((l) => SaleLineInput(
              productId: l.productId!,
              qty: l.qty,
              rate: l.rate,
            ))
        .toList();

    // Prepare payment lines
    final validPaymentLines = _paymentLines
        .where((p) => p.accountId != null && p.amount > 0)
        .toList();

    final paymentInputs = validPaymentLines.isNotEmpty
        ? validPaymentLines
            .map((p) => PaymentLineInput(
                  paymentAccountId: p.accountId!,
                  amount: p.amount,
                ))
            .toList()
        : null;

    if (widget.invoiceId != null) {
      // Update existing invoice
      await salesDao.updateSaleInvoice(
        invoiceId: widget.invoiceId!,
        companyId: company.id,
        customer: _selectedCustomer!,
        date: _date,
        referenceNo: _refNoCtrl.text.trim(),
        lines: inputs,
        paymentLines: paymentInputs,
        userId: user?.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to signal refresh
      }
    } else {
      // Create new invoice
      await salesDao.createSaleInvoice(
        companyId: company.id,
        customer: _selectedCustomer!,
        date: _date,
        referenceNo: _refNoCtrl.text.trim(),
        lines: inputs,
        paymentLines: paymentInputs,
        userId: user?.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to signal refresh
      }
    }
  }

  Widget _buildCustomerSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await Navigator.push<Party>(
          context,
          MaterialPageRoute(
            builder: (_) => const PartySelectionScreen(
              showSuppliers: false,
              showCustomers: true,
              title: 'Select Customer',
            ),
          ),
        );
        if (selected != null) {
          setState(() => _selectedCustomer = selected);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _selectedCustomer?.name.isNotEmpty == true
                      ? _selectedCustomer!.name[0].toUpperCase()
                      : 'C',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCustomer?.name ?? 'Choose a Customer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedCustomer != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Balance: \$${_selectedCustomer!.openingBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(
    BuildContext context,
    SaleLineDraft line,
    List<Product> products,
    int index,
  ) {
    final amount = (line.qty * line.rate).toStringAsFixed(0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.productName ?? 'Tap to select product',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${line.qty.toStringAsFixed(0)} X ${line.rate.toStringAsFixed(0)} = $amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      color: Colors.red.shade600,
                      onPressed: () {
                        try {
                          setState(() {
                            if (line.qty > 1) {
                              line.qty--;
                            }
                          });
                        } catch (e) {
                          print('Error decreasing quantity: $e');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    line.qty.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      color: Colors.red.shade600,
                      onPressed: () {
                        try {
                          setState(() {
                            line.qty++;
                          });
                        } catch (e) {
                          print('Error increasing quantity: $e');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      color: Colors.red.shade600,
                      onPressed: () {
                        setState(() {
                          _lines.removeAt(index);
                          if (_lines.isEmpty) {
                            _lines.add(SaleLineDraft());
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Rate',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) {
              try {
                setState(() {
                  line.rate = double.tryParse(v) ?? 0;
                });
              } catch (e) {
                print('Error updating rate: $e');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalcRow('Sub Total', _subTotal),
          const Divider(),
          Row(
            children: [
              const Expanded(child: Text('Discount')),
              SizedBox(
                width: 70,
                child: DropdownButton<String>(
                  value: _discountType,
                  isExpanded: true,
                  items: ['Flat', '%']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _discountType = v ?? 'Flat');
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onChanged: (v) {
                    setState(() => _discountValue = double.tryParse(v) ?? 0);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(_totalDiscount.toStringAsFixed(0)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('VAT')),
              SizedBox(
                width: 70,
                child: DropdownButton<String>(
                  value: '%',
                  isExpanded: true,
                  items: ['%']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Select',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onChanged: (v) {
                    setState(() => _vat = double.tryParse(v) ?? 0);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(_totalVAT.toStringAsFixed(0)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('Shipping Charge')),
              const Spacer(),
              SizedBox(
                width: 70,
                child: TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onChanged: (v) {
                    setState(() => _shippingCharge = double.tryParse(v) ?? 0);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(_shippingCharge.toStringAsFixed(0)),
            ],
          ),
          const Divider(),
          _buildCalcRow('Total', _grandTotal, isBold: true),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('Rounding (+/-)')),
              const Spacer(),
              SizedBox(
                width: 70,
                child: Container(),
              ),
              const SizedBox(width: 8),
              const Text('0'),
            ],
          ),
          const SizedBox(height: 12),
          _buildCalcRow('Rounded Total', _grandTotal, isBold: true),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: Text('Received Amount')),
              Spacer(),
              SizedBox(
                width: 70,
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text('0'),
            ],
          ),
          const Divider(),
          _buildCalcRow('Due Amount', _grandTotal, isBold: true),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentLinesSection() {
    final paymentAccountsAsync = ref.watch(paymentAccountsProvider);

    return paymentAccountsAsync.when(
      data: (accounts) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Payment Accounts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => _showPaymentTypeDialog(accounts),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_paymentLines.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Tap "Add" to add payment accounts',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ...List.generate(_paymentLines.length, (index) {
                return _buildPaymentLine(_paymentLines[index], accounts, index);
              }),
          ],
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading payment accounts'),
    );
  }

  Widget _buildPaymentLine(
    PaymentLineDraft line,
    List<PaymentAccount> accounts,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Text(
            line.accountIcon ?? '💰',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              line.accountName ?? 'Unknown',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              try {
                setState(() => _paymentLines.removeAt(index));
              } catch (e) {
                print('Error removing payment line: $e');
              }
            },
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: TextField(
              key: ValueKey('payment_amount_${index}_${line.accountId}'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: 'Rs ',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (value) {
                try {
                  line.amount = double.tryParse(value) ?? 0;
                  setState(() {});
                } catch (e) {
                  print('Error updating payment amount: $e');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentTypeDialog(List<PaymentAccount> accounts) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Payment Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...accounts.map((account) {
                return ListTile(
                  leading: Text(
                    account.icon ?? '💰',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(account.accountName),
                  subtitle: account.accountType == PaymentAccountType.bank
                      ? Text(account.bankName ?? '')
                      : null,
                  onTap: () {
                    setState(() {
                      _paymentLines.add(PaymentLineDraft(
                        accountId: account.id,
                        accountName: account.accountName,
                        accountIcon: account.icon,
                        amount: 0,
                      ));
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAndShareInvoice(
    SalesDao salesDao,
    Company company,
    User? user,
  ) async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final validLines = _lines
        .where((l) => l.productId != null && l.qty > 0 && l.rate > 0)
        .toList();

    if (validLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final inputs = validLines
        .map((l) => SaleLineInput(
              productId: l.productId!,
              qty: l.qty,
              rate: l.rate,
            ))
        .toList();

    // Prepare payment lines
    final validPaymentLines = _paymentLines
        .where((p) => p.accountId != null && p.amount > 0)
        .toList();

    final paymentInputs = validPaymentLines.isNotEmpty
        ? validPaymentLines
            .map((p) => PaymentLineInput(
                  paymentAccountId: p.accountId!,
                  amount: p.amount,
                ))
            .toList()
        : null;

    try {
      String refNo = _refNoCtrl.text.trim();

      if (widget.invoiceId != null) {
        await salesDao.updateSaleInvoice(
          invoiceId: widget.invoiceId!,
          companyId: company.id,
          customer: _selectedCustomer!,
          date: _date,
          referenceNo: refNo,
          lines: inputs,
          paymentLines: paymentInputs,
          userId: user?.id,
        );
      } else {
        await salesDao.createSaleInvoice(
          companyId: company.id,
          customer: _selectedCustomer!,
          date: _date,
          referenceNo: refNo,
          lines: inputs,
          paymentLines: paymentInputs,
          userId: user?.id,
        );
      }

      if (mounted) {
        // Get the saved invoice using the service
        final isarService = ref.read(isarServiceProvider);
        final isar = isarService.isar;
        final invoiceService = SalesInvoiceService(isar);

        // Fetch invoice by ID or by finding the most recent for this customer/date
        Invoice? invoice;
        if (widget.invoiceId != null) {
          invoice = await invoiceService.getSaleInvoiceById(widget.invoiceId!);
        } else {
          // For newly created invoice, find by date and customer
          final allInvoices =
              await invoiceService.getAllSaleInvoices(company.id);
          invoice = allInvoices
              .where((i) =>
                  i.invoiceDate.day == _date.day &&
                  i.invoiceDate.month == _date.month &&
                  i.invoiceDate.year == _date.year &&
                  i.partyId == _selectedCustomer!.id)
              .lastOrNull;
        }

        if (invoice != null) {
          // Get transaction - need to access isar directly
          final transaction =
              await isar.transactions.get(invoice.transactionId);

          if (transaction != null) {
            // Get transaction lines using salesDao
            final transactionLines =
                await salesDao.getTransactionLines(transaction.id);

            // Prepare line items with product names
            final lineItems = <Map<String, dynamic>>[];
            for (final txLine in transactionLines) {
              if (txLine.productId != null) {
                final product = await isar.products.get(txLine.productId!);
                lineItems.add({
                  'productName': product?.name ?? 'Unknown',
                  'qty': txLine.quantity,
                  'rate': txLine.unitPrice,
                });
              }
            }

            // Debug: Check if lineItems is empty
            if (lineItems.isEmpty) {
              print('Warning: No line items found for invoice ${invoice.id}');
              print('Transaction lines count: ${transactionLines.length}');
            } else {
              print('Found ${lineItems.length} line items');
            }

            // Prepare payment details if any
            List<Map<String, dynamic>>? paymentDetails;
            if (validPaymentLines.isNotEmpty) {
              paymentDetails = [];
              for (final payLine in validPaymentLines) {
                if (payLine.accountId != null) {
                  final account = await isar.accounts.get(payLine.accountId!);
                  paymentDetails.add({
                    'accountName':
                        account?.name ?? payLine.accountName ?? 'Unknown',
                    'amount': payLine.amount,
                  });
                }
              }
            }

            // Call invoice generator
            await InvoiceGenerator.shareInvoice(
              context: context,
              company: company,
              party: _selectedCustomer!,
              invoice: invoice,
              transaction: transaction,
              lineItems: lineItems,
              paymentLines: paymentDetails,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
