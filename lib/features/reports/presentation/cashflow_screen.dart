// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:matrix_accounts/data/models/party_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/invoice_stock_models.dart';

class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isLoading = true;
  List<CashFlowTransaction> _transactions = [];
  final double _beginningCash = -3346.4; // Starting balance

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCashFlow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCompany = ref.watch(currentCompanyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow Report'),
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _generatePDF,
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'cashflow',
      ),
      body: Column(
        children: [
          _buildFiltersSection(theme),
          Expanded(
            child: _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
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
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _loadCashFlow,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                const Text(
                  'Cashflow Report',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: From ${_fromDate != null ? _dateFormat.format(_fromDate!) : 'Start'} to ${_toDate != null ? _dateFormat.format(_toDate!) : 'End'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cash Flow Table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('PARTY NAME',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Opening Amount',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Cash In',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Cash Out',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                ),

                // Transaction Rows
                ..._transactions.map((transaction) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(transaction.partyName),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              transaction.openingAmount != 0
                                  ? (transaction.openingAmount < 0
                                      ? '- Rs ${transaction.openingAmount.abs().toStringAsFixed(0)}'
                                      : 'Rs ${transaction.openingAmount.toStringAsFixed(0)}')
                                  : '',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: transaction.openingAmount < 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              transaction.cashIn > 0
                                  ? 'Rs ${transaction.cashIn.toStringAsFixed(0)}'
                                  : '',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              transaction.cashOut > 0
                                  ? 'Rs ${transaction.cashOut.toStringAsFixed(0)}'
                                  : '',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )),

                // Totals Row
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: Colors.grey[400]!, width: 2),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text('TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rs ${_transactions.fold(0.0, (sum, t) => sum + t.openingAmount).toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rs ${_transactions.fold(0.0, (sum, t) => sum + t.cashIn).toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rs ${_transactions.fold(0.0, (sum, t) => sum + t.cashOut).toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCashFlow() async {
    if (_fromDate == null || _toDate == null) return;

    setState(() => _isLoading = true);

    try {
      final isar = ref.read(isarServiceProvider).isar;
      final company = ref.read(currentCompanyProvider);

      if (company == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get all invoices in the date range
      final invoices = await isar.invoices
          .filter()
          .companyIdEqualTo(company.id)
          .invoiceDateBetween(_fromDate!, _toDate!)
          .sortByInvoiceDate()
          .findAll();

      List<CashFlowTransaction> transactions = [];
      double runningBalance = _beginningCash;

      // Convert invoices to cash flow transactions
      for (var invoice in invoices) {
        final party = await isar.partys.get(invoice.partyId);

        CashFlowTransaction transaction = CashFlowTransaction(
          date: invoice.invoiceDate,
          partyName: party?.name ?? 'Unknown Party',
          category: '',
          openingAmount: party?.openingBalance ?? 0,
          cashIn:
              invoice.invoiceType == InvoiceType.sale ? invoice.grandTotal : 0,
          cashOut: invoice.invoiceType == InvoiceType.purchase
              ? invoice.grandTotal
              : 0,
          runningBalance: 0,
        );

        runningBalance += transaction.cashIn - transaction.cashOut;
        transaction.runningBalance = runningBalance;
        transactions.add(transaction);
      }

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cash flow: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePDF() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Center(
            child: pw.Text(
              'Cashflow Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Duration: From ${_fromDate != null ? _dateFormat.format(_fromDate!) : 'Start'} to ${_toDate != null ? _dateFormat.format(_toDate!) : 'End'}',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(3),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('PARTY NAME',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Opening Amount',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Cash In',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Cash Out',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),

              // Transaction Rows
              ..._transactions.map((transaction) => pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(transaction.partyName)),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(transaction.openingAmount != 0
                              ? (transaction.openingAmount < 0
                                  ? '- Rs ${transaction.openingAmount.abs().toStringAsFixed(0)}'
                                  : 'Rs ${transaction.openingAmount.toStringAsFixed(0)}')
                              : '')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(transaction.cashIn > 0
                              ? 'Rs ${transaction.cashIn.toStringAsFixed(0)}'
                              : '')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(transaction.cashOut > 0
                              ? 'Rs ${transaction.cashOut.toStringAsFixed(0)}'
                              : '')),
                    ],
                  )),

              // Totals Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('TOTAL',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6), child: pw.Text('')),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                          'Rs ${_transactions.fold(0.0, (sum, t) => sum + t.cashIn).toStringAsFixed(0)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                          'Rs ${_transactions.fold(0.0, (sum, t) => sum + t.cashOut).toStringAsFixed(0)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                          _transactions.isNotEmpty
                              ? (_transactions.last.runningBalance < 0
                                  ? '- Rs ${_transactions.last.runningBalance.abs().toStringAsFixed(1)}'
                                  : 'Rs ${_transactions.last.runningBalance.toStringAsFixed(1)}')
                              : (_beginningCash < 0
                                  ? '- Rs ${_beginningCash.abs().toStringAsFixed(1)}'
                                  : 'Rs ${_beginningCash.toStringAsFixed(1)}'),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
    });
  }
}

class CashFlowTransaction {
  final DateTime date;
  final String partyName;
  final String category;
  final double openingAmount;
  final double cashIn;
  final double cashOut;
  double runningBalance;

  CashFlowTransaction({
    required this.date,
    required this.partyName,
    required this.category,
    required this.openingAmount,
    required this.cashIn,
    required this.cashOut,
    required this.runningBalance,
  });
}
