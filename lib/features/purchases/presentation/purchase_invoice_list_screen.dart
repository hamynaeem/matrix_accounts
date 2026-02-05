// ignore_for_file: unused_field, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/party_dao.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../services/purchase_invoice_service.dart';
import '../services/purchase_invoice_generator.dart';
import 'purchase_invoice_form_screen.dart';

class PurchaseInvoiceListScreen extends ConsumerStatefulWidget {
  const PurchaseInvoiceListScreen({super.key});

  @override
  ConsumerState<PurchaseInvoiceListScreen> createState() =>
      _PurchaseInvoiceListScreenState();
}

class _PurchaseInvoiceListScreenState
    extends ConsumerState<PurchaseInvoiceListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _currencyFormat = NumberFormat.currency(symbol: 'PKR ');
  final _dateFormat = DateFormat('dd MMM yyyy');

  // Cache the futures to prevent rebuilding
  Future<List<Invoice>>? _invoicesFuture;
  Future<List<Invoice>>? _totalInvoicesFuture;

  @override
  void initState() {
    super.initState();
    _initializeFutures();
  }

  void _initializeFutures() {
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      final isar = ref.read(isarServiceProvider).isar;
      final service = PurchaseInvoiceService(isar);
      _invoicesFuture = service.getAllPurchaseInvoices(company.id);
      _totalInvoicesFuture = service.getAllPurchaseInvoices(company.id);
    }
  }

  void _refreshInvoices() {
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      final isar = ref.read(isarServiceProvider).isar;
      final service = PurchaseInvoiceService(isar);
      setState(() {
        if (_searchQuery.isEmpty) {
          _invoicesFuture = service.getAllPurchaseInvoices(company.id);
        } else {
          _invoicesFuture =
              service.searchPurchaseInvoices(company.id, _searchQuery);
        }
        _totalInvoicesFuture = service.getAllPurchaseInvoices(company.id);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get current supplier balance from accounting ledger
  Future<double> _getSupplierBalance(int supplierId) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return 0.0;

    final isarService = ref.read(isarServiceProvider);
    final partyDao = PartyDao(isarService.isar);

    try {
      return await partyDao.getPartyBalance(
        partyId: supplierId,
        companyId: company.id,
      );
    } catch (e) {
      print('Error getting supplier balance: $e');
      return 0.0;
    }
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete this purchase invoice?\nAmount: ${_currencyFormat.format(invoice.grandTotal)}',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final isar = ref.read(isarServiceProvider).isar;
        final service = PurchaseInvoiceService(isar);
        await service.deletePurchaseInvoice(invoice.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase invoice deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshInvoices(); // Use refresh method instead of setState
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting invoice: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _printInvoice(Invoice invoice) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF for printing...')),
      );

      final isar = ref.read(isarServiceProvider).isar;
      final service = PurchaseInvoiceService(isar);
      final company = ref.read(currentCompanyProvider);

      if (company == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No company selected')),
        );
        return;
      }

      // Get required data
      final supplier = await service.getPartyForInvoice(invoice.partyId);
      final transaction = await service.getTransactionForInvoice(invoice.id);

      if (supplier == null || transaction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load invoice data')),
        );
        return;
      }

      // Get transaction lines
      final transactionLines =
          await service.getTransactionLines(transaction.id);
      final lineItems = transactionLines
          .map((line) => {
                'productName': line.description ?? 'Unknown Product',
                'quantity': line.quantity,
                'rate': line.unitPrice,
                'amount': line.quantity * line.unitPrice,
              })
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareInvoice(Invoice invoice) async {
    try {
      final isar = ref.read(isarServiceProvider).isar;
      final service = PurchaseInvoiceService(isar);
      final company = ref.read(currentCompanyProvider);

      if (company == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No company selected')),
        );
        return;
      }

      // Get required data
      final supplier = await service.getPartyForInvoice(invoice.partyId);
      final transaction = await service.getTransactionForInvoice(invoice.id);

      if (supplier == null || transaction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load invoice data')),
        );
        return;
      }

      // Get transaction lines
      final transactionLines =
          await service.getTransactionLines(transaction.id);
      final lineItems = transactionLines
          .map((line) => {
                'productName': line.description ?? 'Unknown Product',
                'quantity': line.quantity,
                'rate': line.unitPrice,
                'amount': line.quantity * line.unitPrice,
              })
          .toList();

      // Get current supplier balance
      final supplierBalance = await _getSupplierBalance(supplier.id);

      // Show share options
      await PurchaseInvoiceGenerator.sharePurchaseInvoice(
        context: context,
        company: company,
        supplier: supplier,
        invoice: invoice,
        transaction: transaction,
        lineItems: lineItems,
        supplierBalance: supplierBalance,
        openingBalance: supplier.openingBalance,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final company = ref.watch(currentCompanyProvider);

    if (company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Invoices')),
        body: const Center(
          child: Text('Please select a company first'),
        ),
      );
    }

    final isar = ref.watch(isarServiceProvider).isar;
    final service = PurchaseInvoiceService(isar);

    return Scaffold(
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'purchases',
      ),
      appBar: AppBar(
        title: const Text('Purchase List'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search Bar and Total Purchase Amount (Side by Side)
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surface,
            child: Row(
              children: [
                // Search Bar - Half Width
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search invoices...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _refreshInvoices();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _refreshInvoices();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Total Purchase Amount - Half Width
                Expanded(
                  flex: 1,
                  child: FutureBuilder<List<Invoice>>(
                    future: _totalInvoicesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final totalAmount = snapshot.data!.fold<double>(
                            0.0, (sum, invoice) => sum + invoice.grandTotal);
                        return Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Purchase',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rs ${NumberFormat('#,##0.0').format(totalAmount)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Purchase',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Loading...',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Invoice List
          Expanded(
            child: FutureBuilder<List<Invoice>>(
              key: ValueKey('invoices_${_searchQuery}_${company.id}'),
              future: _invoicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading invoices',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final invoices = snapshot.data ?? [];

                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No Purchase Invoices Found'
                              : 'No matching invoices',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Tap + to create your first purchase invoice'
                              : 'Try a different search term',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildInvoiceCard(invoice, colorScheme, service),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PurchaseInvoiceFormScreen(),
            ),
          );
          if (result == true && mounted) {
            _refreshInvoices(); // Use refresh method instead of setState
          }
        },
        backgroundColor: Colors.blueAccent,
        tooltip: 'Add Purchase Invoice',
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Add Purchase', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInvoiceCard(
    Invoice invoice,
    ColorScheme colorScheme,
    PurchaseInvoiceService service,
  ) {
    return Dismissible(
        key: Key('invoice_${invoice.id}'),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Invoice'),
              content: Text(
                'Are you sure you want to delete this purchase invoice?\nAmount: ${_currencyFormat.format(invoice.grandTotal)}',
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          try {
            final isar = ref.read(isarServiceProvider).isar;
            final service = PurchaseInvoiceService(isar);
            await service.deletePurchaseInvoice(invoice.id);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase invoice deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _refreshInvoices(); // Use refresh method
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting invoice: $e'),
                  backgroundColor: Colors.red,
                ),
              );
              _refreshInvoices(); // Refresh to restore the item
            }
          }
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PurchaseInvoiceFormScreen(invoiceId: invoice.id),
                ),
              );
              if (result == true && mounted) {
                _refreshInvoices(); // Use refresh method instead of setState
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Date and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yy').format(invoice.invoiceDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Payment Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(invoice),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(invoice),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main Row: Supplier Name, Total Amount, Opening Balance
                  FutureBuilder<Party?>(
                    future: service.getPartyForInvoice(invoice.partyId),
                    builder: (context, snapshot) {
                      final party = snapshot.data;
                      final partyName = party?.name ?? 'Loading...';
                      final openingBalance = party?.openingBalance ?? 0.0;

                      return Row(
                        children: [
                          // Supplier Name (Left)
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partyName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Total Amount and Balance Information
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Purchase Amount
                                Text(
                                  'Purchase: Rs ${NumberFormat('#,##0').format(invoice.grandTotal)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),

                                // Previous Balance (if any)
                                if (invoice.previousBalance > 0) ...[
                                  Text(
                                    'Previous: Rs ${NumberFormat('#,##0').format(invoice.previousBalance)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade700,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                ],

                                // Paid Amount
                                if (invoice.paidAmount > 0) ...[
                                  Text(
                                    'Paid: Rs ${NumberFormat('#,##0').format(invoice.paidAmount)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green.shade700,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                ],

                                // Remaining Balance
                                Text(
                                  'Balance: Rs ${NumberFormat('#,##0').format(invoice.remainingBalance)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: invoice.remainingBalance > 0
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                  ),
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Color _getStatusColor(Invoice invoice) {
    final totalPayable = invoice.previousBalance + invoice.grandTotal;
    if (invoice.paidAmount >= totalPayable) {
      return Colors.green;
    } else if (invoice.paidAmount > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getStatusText(Invoice invoice) {
    final totalPayable = invoice.previousBalance + invoice.grandTotal;
    if (invoice.paidAmount >= totalPayable) {
      return 'PAID';
    } else if (invoice.paidAmount > 0) {
      return 'PARTIAL';
    } else {
      return 'UNPAID';
    }
  }
}
