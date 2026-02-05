// ignore_for_file: deprecated_member_use, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:matrix_accounts/data/models/transaction_model.dart'
    show
        GetTransactionLineCollection,
        TransactionLineQueryFilter,
        TransactionLine;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/config/providers.dart';
import '../../data/models/company_model.dart';
import '../../data/models/invoice_stock_models.dart';
import '../../data/models/inventory_models.dart';
import '../../data/models/party_model.dart';
import 'services/purchase_invoice_service.dart';

class PurchaseReportScreen extends ConsumerStatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  ConsumerState<PurchaseReportScreen> createState() =>
      _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends ConsumerState<PurchaseReportScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  Party? _selectedSupplier;
  final String _reportType = 'summary'; // summary, detailed, supplier
  final _dateFormat = DateFormat('dd MMM yyyy');
  final _currencyFormat = NumberFormat.currency(symbol: 'PKR ');

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final isar = ref.watch(isarServiceProvider).isar;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (company == null) {
      return const Scaffold(
        body: Center(child: Text('No company selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Reports'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _generatePDF(company, isar),
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(colorScheme, isar),
          Expanded(
            child: _buildReportContent(company, isar),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(ColorScheme colorScheme, Isar isar) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectFromDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fromDate != null
                              ? _dateFormat.format(_fromDate!)
                              : 'From Date',
                          style: TextStyle(
                            color: _fromDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectToDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _toDate != null
                              ? _dateFormat.format(_toDate!)
                              : 'To Date',
                          style: TextStyle(
                            color: _toDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAllReports,
                icon: const Icon(Icons.list_alt, size: 18),
                label: const Text('All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(Company company, Isar isar) {
    return FutureBuilder<_PurchaseReportData>(
      future: _loadReportData(company.id, isar),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        if (data.invoices.isEmpty) {
          return const Center(child: Text('No purchase data found'));
        }

        return _buildDetailedReport(data);
      },
    );
  }

  Widget _buildDetailedReport(_PurchaseReportData data) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) {
      return const Center(child: Text('No company selected'));
    }

    // Group invoices by date
    final Map<String, List<Invoice>> invoicesByDate = {};
    for (final invoice in data.invoices) {
      final dateStr = _dateFormat.format(invoice.invoiceDate);
      invoicesByDate.putIfAbsent(dateStr, () => []).add(invoice);
    }

    final sortedDates = invoicesByDate.keys.toList()
      ..sort((a, b) => _dateFormat.parse(b).compareTo(_dateFormat.parse(a)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIdx) {
        final dateStr = sortedDates[dateIdx];
        final invoices = invoicesByDate[dateStr]!;

        // For daily totals
        return FutureBuilder<List<List<TransactionLine>>>(
          future: Future.wait(
              invoices.map((inv) => _getTransactionLines(inv.transactionId))),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final allLines = snapshot.data!;
            double totalQty = 0;
            double totalAmount = 0;
            double totalRate = 0;
            int rateCount = 0;
            for (final lines in allLines) {
              for (final line in lines) {
                totalQty += line.quantity;
                totalAmount += line.lineAmount;
                totalRate += line.unitPrice;
                rateCount++;
              }
            }
            final avgRate = rateCount > 0 ? totalRate / rateCount : 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily total summary
                Card(
                  color: Colors.blue[50],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Qty: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87),
                                  ),
                                  TextSpan(
                                    text: totalQty == totalQty.roundToDouble()
                                        ? totalQty.toStringAsFixed(0)
                                        : totalQty.toStringAsFixed(2),
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Avg Rate: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87),
                                  ),
                                  TextSpan(
                                    text: avgRate.toStringAsFixed(2),
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Amount: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87),
                                  ),
                                  TextSpan(
                                    text: totalAmount.toStringAsFixed(2),
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // List all invoices for this day
                ...List.generate(invoices.length, (invIdx) {
                  final invoice = invoices[invIdx];
                  final supplier = data.suppliers[invoice.partyId];
                  return FutureBuilder<List<TransactionLine>>(
                    future: _getTransactionLines(invoice.transactionId),
                    builder: (context, linesSnapshot) {
                      final lines = linesSnapshot.data ?? [];
                      final totalQty =
                          lines.fold(0.0, (sum, line) => sum + line.quantity);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          supplier?.name ?? 'Unknown Supplier',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _dateFormat
                                              .format(invoice.invoiceDate),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () => _generateInvoicePDF(
                                            data.company!,
                                            invoice,
                                            supplier,
                                            lines),
                                        tooltip:
                                            'Generate PDF for this invoice',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _currencyFormat
                                              .format(invoice.grandTotal),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (lines.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    children: [
                                      // Header row
                                      const Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Product',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Qty',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Rate',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Amount',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 8, thickness: 0.5),
                                      ...lines.take(5).map((line) =>
                                          FutureBuilder<Product?>(
                                            future: _getProduct(line.productId),
                                            builder:
                                                (context, productSnapshot) {
                                              final product =
                                                  productSnapshot.data;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 3),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        product?.name ??
                                                            'Unknown Product',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        line.quantity ==
                                                                line.quantity
                                                                    .roundToDouble()
                                                            ? line.quantity
                                                                .toStringAsFixed(
                                                                    0)
                                                            : line.quantity
                                                                .toStringAsFixed(
                                                                    2),
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        line.unitPrice
                                                            .toStringAsFixed(2),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.orange,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        line.lineAmount
                                                            .toStringAsFixed(2),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )),
                                      if (lines.length > 5)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '+${lines.length - 5} more items',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<TransactionLine>> _getTransactionLines(int transactionId) async {
    final isar = ref.read(isarServiceProvider).isar;
    return await isar.transactionLines
        .filter()
        .transactionIdEqualTo(transactionId)
        .findAll();
  }

  Future<Product?> _getProduct(int? productId) async {
    if (productId == null || productId == 0) return null;
    final isar = ref.read(isarServiceProvider).isar;
    return await isar.products.get(productId);
  }

  Future<_PurchaseReportData> _loadReportData(int companyId, Isar isar) async {
    final service = PurchaseInvoiceService(isar);
    var invoices = await service.getAllPurchaseInvoices(companyId);

    // Apply date filters
    if (_fromDate != null) {
      invoices = invoices
          .where((inv) =>
              inv.invoiceDate.isAfter(_fromDate!) ||
              inv.invoiceDate.isAtSameMomentAs(_fromDate!))
          .toList();
    }

    if (_toDate != null) {
      invoices = invoices
          .where((inv) =>
              inv.invoiceDate.isBefore(_toDate!) ||
              inv.invoiceDate.isAtSameMomentAs(_toDate!))
          .toList();
    }

    // Apply supplier filter
    if (_selectedSupplier != null) {
      invoices = invoices
          .where((inv) => inv.partyId == _selectedSupplier!.id)
          .toList();
    }

    // Load suppliers
    final supplierIds = invoices.map((inv) => inv.partyId).toSet();
    final suppliers = <int, Party>{};

    for (final id in supplierIds) {
      final supplier = await isar.partys.get(id);
      if (supplier != null) {
        suppliers[id] = supplier;
      }
    }

    return _PurchaseReportData(
      invoices: invoices,
      suppliers: suppliers,
      company: await isar.companys.get(companyId),
    );
  }

  Future<void> _generatePDF(Company company, Isar isar) async {
    final data = await _loadReportData(company.id, isar);

    // Calculate totals
    double grandTotal = 0;
    double totalWeight = 0;

    // Collect all transaction lines for calculations
    List<Map<String, dynamic>> reportData = [];

    for (var invoice in data.invoices) {
      final supplier = data.suppliers[invoice.partyId];
      final lines = await _getTransactionLines(invoice.transactionId);

      for (var line in lines) {
        final product = await _getProduct(line.productId);
        reportData.add({
          'date': invoice.invoiceDate,
          'partyName': supplier?.name ?? 'Unknown Supplier',
          'saleMan': 'Dilawar Hussain', // You can make this dynamic if needed
          'weight': line.quantity,
          'rate': line.unitPrice,
          'totalAmount': line.lineAmount,
        });
        totalWeight += line.quantity;
        grandTotal += line.lineAmount;
      }
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Center(
              child: pw.Text(
                'Purchase Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),

            // Date
            pw.Text(
              'Date: ${_fromDate != null ? _dateFormat.format(_fromDate!) : _dateFormat.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5), // Date
                1: const pw.FlexColumnWidth(2.5), // Party Name
                2: const pw.FlexColumnWidth(2), // Sale Man
                3: const pw.FlexColumnWidth(1.2), // Weight
                4: const pw.FlexColumnWidth(1.2), // Rate
                5: const pw.FlexColumnWidth(1.8), // Total Amount
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Date',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Party Name',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Sale Man',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Weight',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Rate',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total Amount',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),

                // Data rows
                ...reportData.map((item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(_dateFormat.format(item['date'])),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['partyName']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['saleMan']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                              item['weight'] == item['weight'].roundToDouble()
                                  ? item['weight'].toStringAsFixed(0)
                                  : item['weight'].toStringAsFixed(2),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['rate'].toStringAsFixed(2),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['totalAmount'].toStringAsFixed(2),
                              textAlign: pw.TextAlign.right),
                        ),
                      ],
                    )),

                // Total row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('')),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('TOTAL',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                          totalWeight == totalWeight.roundToDouble()
                              ? totalWeight.toStringAsFixed(0)
                              : totalWeight.toStringAsFixed(2),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('')),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(grandTotal.toStringAsFixed(2),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedSupplier = null;
    });
  }

  void _showAllReports() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedSupplier = null;
    });
  }

  Future<void> _generateInvoicePDF(Company company, Invoice invoice,
      Party? supplier, List<TransactionLine> lines) async {
    final pdf = pw.Document();

    // Calculate totals for this invoice
    double totalAmount = 0;
    double totalWeight = 0;

    for (var line in lines) {
      totalAmount += line.lineAmount;
      totalWeight += line.quantity;
    }

    // Pre-build the table rows to avoid async operations in the build function
    List<pw.TableRow> tableRows = [
      // Header
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Product',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Qty',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Rate',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Amount',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    ];

    // Add data rows
    for (var line in lines) {
      final product = await _getProduct(line.productId);
      tableRows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(product?.name ?? 'Unknown Product'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                line.quantity == line.quantity.roundToDouble()
                    ? line.quantity.toStringAsFixed(0)
                    : line.quantity.toStringAsFixed(2),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                line.unitPrice.toStringAsFixed(2),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                line.lineAmount.toStringAsFixed(2),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    // Add total row
    tableRows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey50),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Total',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              totalWeight == totalWeight.roundToDouble()
                  ? totalWeight.toStringAsFixed(0)
                  : totalWeight.toStringAsFixed(2),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(''),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              totalAmount.toStringAsFixed(2),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          // Header
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      company.name,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Purchase Invoice #${invoice.invoiceNumber}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Date: ${_dateFormat.format(invoice.invoiceDate)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Supplier info
          pw.Text(
            'Supplier: ${supplier?.name ?? 'Unknown Supplier'}',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 20),

          // Items table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: tableRows,
          ),

          pw.SizedBox(height: 20),

          // Grand Total
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Grand Total: Rs ${invoice.grandTotal.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

class _PurchaseReportData {
  final List<Invoice> invoices;
  final Map<int, Party> suppliers;
  final Company? company;

  _PurchaseReportData({
    required this.invoices,
    required this.suppliers,
    this.company,
  });
}
