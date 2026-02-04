// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/party_dao.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../services/sales_invoice_service.dart';

class SaleInvoiceListScreen extends ConsumerStatefulWidget {
  const SaleInvoiceListScreen({super.key});

  @override
  ConsumerState<SaleInvoiceListScreen> createState() =>
      _SaleInvoiceListScreenState();
}

class _SaleInvoiceListScreenState extends ConsumerState<SaleInvoiceListScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';
  final _currencyFormat = NumberFormat.currency(symbol: 'PKR ');
  final _dateFormat = DateFormat('dd MMM yyyy');
  final _cardMargin = const EdgeInsets.symmetric(vertical: 8);
  final _cardBorderRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToInvoiceForm([int? invoiceId]) async {
    final route = invoiceId != null
        ? '/sales/invoice/form?id=$invoiceId'
        : '/sales/invoice/form';
    final result = await context.push(route);
    if (result == true && mounted) {
      setState(() {}); // Refresh list
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// Get current customer balance from accounting ledger
  Future<double> _getCustomerBalance(int customerId) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return 0.0;

    final isarService = ref.read(isarServiceProvider);
    final partyDao = PartyDao(isarService.isar);

    try {
      return await partyDao.getPartyBalance(
        partyId: customerId,
        companyId: company.id,
      );
    } catch (e) {
      print('Error getting customer balance: $e');
      return 0.0;
    }
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete this invoice?\nAmount: ${_currencyFormat.format(invoice.grandTotal)}',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final isar = ref.read(isarServiceProvider).isar;
        final service = SalesInvoiceService(isar);
        await service.deleteSaleInvoice(invoice.id);
        _showSnackBar('Invoice deleted successfully');
        setState(() {}); // Refresh list
      } catch (e) {
        _showSnackBar('Error deleting invoice: $e', isError: true);
      }
    }
  }

  // Future<void> _shareInvoice(Invoice invoice) async {
  //   await _shareAsPDF(invoice);
  // }

  // Future<void> _printInvoice(Invoice invoice) async {
  //   try {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Generating PDF for printing...')),
  //     );

  //     final isar = ref.read(isarServiceProvider).isar;
  //     final service = SalesInvoiceService(isar);
  //     final company = ref.read(currentCompanyProvider);

  //     if (company == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('No company selected')),
  //       );
  //       return;
  //     }

  //     // Get required data
  //     final party = await service.getPartyForInvoice(invoice.partyId);
  //     final salesDao = ref.read(salesDaoProvider);
  //     final transaction = await salesDao.getTransactionForInvoice(invoice.id);

  //     if (party == null || transaction == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Could not load invoice data')),
  //       );
  //       return;
  //     }

  //     // Get transaction lines
  //     final transactionLines =
  //         await salesDao.getTransactionLines(transaction.id);
  //     final lineItems = transactionLines
  //         .map((line) => {
  //               'productName': line.productId != null
  //                   ? isar.products.getSync(line.productId!)?.name ??
  //                       'Unknown Product'
  //                   : 'Unknown Product',
  //               'quantity': line.quantity,
  //               'rate': line.unitPrice,
  //               'amount': line.quantity * line.unitPrice,
  //             })
  //         .toList();

  // Generate PDF using InvoiceGenerator
  //     final customerBalance = await _getCustomerBalance(invoice.partyId);
  //     final pdfBytes = await InvoiceGenerator.generateInvoicePdf(
  //       company: company,
  //       party: party,
  //       invoice: invoice,
  //       transaction: transaction,
  //       lineItems: lineItems,
  //       customerBalance: customerBalance,
  //     );

  //     // Print PDF
  //     await Printing.layoutPdf(
  //       onLayout: (format) async => pdfBytes,
  //       name: 'sales_invoice_${transaction.referenceNo}.pdf',
  //     );
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error printing invoice: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // Future<void> _shareAsPDF(Invoice invoice) async {
  //   try {
  //     _showSnackBar('Generating PDF...');

  //     final isar = ref.read(isarServiceProvider).isar;
  //     final service = SalesInvoiceService(isar);
  //     final salesDao = ref.read(salesDaoProvider);
  //     final party = await service.getPartyForInvoice(invoice.partyId);
  //     final company = ref.read(currentCompanyProvider);

  //     // Get transaction and line items
  //     final transaction = await salesDao.getTransactionForInvoice(invoice.id);
  //     final transactionLines = transaction != null
  //         ? await salesDao.getTransactionLines(transaction.id)
  //         : <TransactionLine>[];

  //     final pdf = pw.Document();

  //     pdf.addPage(
  //       pw.Page(
  //         pageFormat: PdfPageFormat.a4,
  //         build: (pw.Context context) {
  //           return pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               // Header
  //               pw.Text(
  //                 'INVOICE #${invoice.id}',
  //                 style: pw.TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: pw.FontWeight.bold,
  //                 ),
  //               ),
  //               pw.SizedBox(height: 20),

  //               // Company and Customer Info
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text('From: ${company?.name ?? 'Company'}'),
  //                       pw.SizedBox(height: 10),
  //                       pw.Text('Customer: ${party?.name ?? 'Unknown'}'),
  //                       pw.Text(
  //                           'Date: ${_dateFormat.format(invoice.invoiceDate)}'),
  //                       if (transaction != null)
  //                         pw.Text('Ref: ${transaction.referenceNo}'),
  //                     ],
  //                   ),
  //                   if (invoice.status != null)
  //                     pw.Text('Status: ${invoice.status!}'),
  //                 ],
  //               ),
  //               pw.SizedBox(height: 30),

  //               // Line Items Table
  //               if (transactionLines.isNotEmpty) ...[
  //                 pw.Table(
  //                   border: pw.TableBorder.all(),
  //                   columnWidths: {
  //                     0: const pw.FlexColumnWidth(3),
  //                     1: const pw.FlexColumnWidth(1),
  //                     2: const pw.FlexColumnWidth(1.5),
  //                     3: const pw.FlexColumnWidth(1.5),
  //                   },
  //                   children: [
  //                     // Header
  //                     pw.TableRow(
  //                       decoration:
  //                           const pw.BoxDecoration(color: PdfColors.grey300),
  //                       children: [
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8),
  //                           child: pw.Text('Item',
  //                               style: pw.TextStyle(
  //                                   fontWeight: pw.FontWeight.bold)),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8),
  //                           child: pw.Text('Qty',
  //                               style: pw.TextStyle(
  //                                   fontWeight: pw.FontWeight.bold),
  //                               textAlign: pw.TextAlign.center),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8),
  //                           child: pw.Text('Rate',
  //                               style: pw.TextStyle(
  //                                   fontWeight: pw.FontWeight.bold),
  //                               textAlign: pw.TextAlign.right),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8),
  //                           child: pw.Text('Amount',
  //                               style: pw.TextStyle(
  //                                   fontWeight: pw.FontWeight.bold),
  //                               textAlign: pw.TextAlign.right),
  //                         ),
  //                       ],
  //                     ),
  //                     // Data rows
  //                     ...transactionLines.map((line) {
  //                       final product = line.productId != null
  //                           ? isar.products.getSync(line.productId!)
  //                           : null;
  //                       final productName = product?.name ?? 'Unknown Product';
  //                       final amount = line.quantity * line.unitPrice;

  //                       return pw.TableRow(
  //                         children: [
  //                           pw.Padding(
  //                             padding: const pw.EdgeInsets.all(8),
  //                             child: pw.Text(productName),
  //                           ),
  //                           pw.Padding(
  //                             padding: const pw.EdgeInsets.all(8),
  //                             child: pw.Text(line.quantity.toStringAsFixed(0),
  //                                 textAlign: pw.TextAlign.center),
  //                           ),
  //                           pw.Padding(
  //                             padding: const pw.EdgeInsets.all(8),
  //                             child: pw.Text(line.unitPrice.toStringAsFixed(2),
  //                                 textAlign: pw.TextAlign.right),
  //                           ),
  //                           pw.Padding(
  //                             padding: const pw.EdgeInsets.all(8),
  //                             child: pw.Text(amount.toStringAsFixed(2),
  //                                 textAlign: pw.TextAlign.right),
  //                           ),
  //                         ],
  //                       );
  //                     }).toList(),
  //                   ],
  //                 ),
  //                 pw.SizedBox(height: 20),
  //               ],

  //               pw.Divider(),
  //               pw.SizedBox(height: 10),

  //               // Total
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.end,
  //                 children: [
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.end,
  //                     children: [
  //                       if (transactionLines.isNotEmpty)
  //                         pw.Row(
  //                           children: [
  //                             pw.Text('Subtotal: '),
  //                             pw.Text(transactionLines
  //                                 .fold<double>(
  //                                     0,
  //                                     (sum, line) =>
  //                                         sum +
  //                                         (line.quantity * line.unitPrice))
  //                                 .toStringAsFixed(2)),
  //                           ],
  //                         ),
  //                       pw.SizedBox(height: 5),
  //                       pw.Row(
  //                         children: [
  //                           pw.Text(
  //                             'Total: ',
  //                             style: pw.TextStyle(
  //                                 fontSize: 18, fontWeight: pw.FontWeight.bold),
  //                           ),
  //                           pw.Text(
  //                             _currencyFormat.format(invoice.grandTotal),
  //                             style: pw.TextStyle(
  //                                 fontSize: 18, fontWeight: pw.FontWeight.bold),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     );

  //     final tempDir = await getTemporaryDirectory();
  //     final file = File('${tempDir.path}/invoice_${invoice.id}.pdf');
  //     await file.writeAsBytes(await pdf.save());

  //     await Share.shareXFiles([XFile(file.path)],
  //         subject: 'Invoice #${invoice.id}');
  //     _showSnackBar('Invoice shared successfully');
  //   } catch (e) {
  //     _showSnackBar('Error sharing invoice: $e', isError: true);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final company = ref.watch(currentCompanyProvider);

    if (company == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sale Invoices'),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(child: Text('Please select a company first')),
      );
    }

    final isar = ref.watch(isarServiceProvider).isar;
    final service = SalesInvoiceService(isar);

    return Scaffold(
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'sales',
      ),
      appBar: AppBar(
        title: const Text('Sale List'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Search Bar and Total Sales Amount (Side by Side)
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
                                setState(() => _searchQuery = '');
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
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Total Sales Amount - Half Width
                Expanded(
                  flex: 1,
                  child: FutureBuilder<List<Invoice>>(
                    future: service.getAllSaleInvoices(company.id),
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
                                  'Total Sales',
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
                                'Total Sales',
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
              future: _searchQuery.isEmpty
                  ? service.getAllSaleInvoices(company.id)
                  : service.searchSaleInvoices(company.id, _searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
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
                          Icons.receipt_long,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No Sale Invoices Found'
                              : 'No matching invoices',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Tap + to create your first sale invoice'
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
        onPressed: () => _navigateToInvoiceForm(),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Add Sale Invoice',
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Sale', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search invoice...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    if (mounted && _searchController.text.isNotEmpty) {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    }
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          if (mounted) {
            setState(() => _searchQuery = value);
          }
        },
      ),
    );
  }

  Widget _buildInvoiceCard(
    Invoice invoice,
    ColorScheme colorScheme,
    SalesInvoiceService service,
  ) {
    return Dismissible(
      key: Key('invoice_${invoice.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: _cardMargin,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Invoice'),
            content: Text(
              'Are you sure you want to delete this invoice?\nAmount: ${_currencyFormat.format(invoice.grandTotal)}',
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          final isar = ref.read(isarServiceProvider).isar;
          final service = SalesInvoiceService(isar);
          await service.deleteSaleInvoice(invoice.id);
          _showSnackBar('Invoice deleted successfully');
          setState(() {}); // Refresh list
        } catch (e) {
          _showSnackBar('Error deleting invoice: $e', isError: true);
        }
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToInvoiceForm(invoice.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Invoice number and Date
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
                  ],
                ),
                const SizedBox(height: 12),

                // Main Row: Customer Name, Total Amount, Due Balance
                FutureBuilder<Party?>(
                  future: service.getPartyForInvoice(invoice.partyId),
                  builder: (context, snapshot) {
                    final party = snapshot.data;
                    final partyName = party?.name ?? 'Loading...';
                    final openingBalance = party?.openingBalance ?? 0.0;

                    return Row(
                      children: [
                        // Customer Name (Left)
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

                        // Total Amount (Center)
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Rs ${NumberFormat('#,##0').format(invoice.grandTotal)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
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
      ),
    );
  }
}
