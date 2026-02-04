// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/company_model.dart' show Company;
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import '../logic/payment_providers.dart';

class PaymentInListScreen extends ConsumerStatefulWidget {
  const PaymentInListScreen({super.key});

  @override
  ConsumerState<PaymentInListScreen> createState() =>
      _PaymentInListScreenState();
}

class _PaymentInListScreenState extends ConsumerState<PaymentInListScreen> {
  String _searchQuery = '';
  Party? _selectedCustomer;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Set default date range to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate =
        DateTime(now.year, now.month + 1, 0); // Last day of current month
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final paymentsAsync = ref.watch(paymentInsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment In'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Export to PDF',
            onPressed: () => _generatePaymentInPDF(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                company?.name ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section to match screenshot design
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCustomerPicker(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedCustomer?.name ?? 'All Users',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _selectDateRange(),
                  child: Row(
                    children: [
                      Text(
                        'Custom Range',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'to',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Payment-In',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Enhanced Search field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by party name, receipt number, or amount...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue.shade400,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() => _searchQuery = value.toLowerCase());
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: paymentsAsync.when(
              data: (payments) {
                if (payments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No payment receipts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first payment receipt',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _PaymentsList(
                  payments: payments,
                  searchQuery: _searchQuery,
                  selectedCustomer: _selectedCustomer,
                  startDate: _startDate,
                  endDate: _endDate,
                  onPaymentDeleted: () {
                    ref.invalidate(paymentInsProvider);
                  },
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading payments...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading payments',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await context.push('/payments/in/form');
            if (result == true && mounted) {
              ref.invalidate(paymentInsProvider);
            }
          },
          backgroundColor: Colors.blueAccent,
          elevation: 4,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: const Text(
            'Add Payment In',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  void _sharePayment(PaymentIn payment) {
    final text = '''Payment Receipt: ${payment.receiptNo}

Date: ${payment.receiptDate.day}/${payment.receiptDate.month}/${payment.receiptDate.year}
Total Amount: Rs ${payment.totalAmount.toStringAsFixed(2)}

Generated by Matrix Accounts''';

    Share.share(text);
  }

  Future<void> _showCustomerPicker() async {
    final isarService = ref.read(isarServiceProvider);
    final customers = await isarService.isar.partys.where().findAll();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Customer'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              ListTile(
                title: const Text('All Users'),
                leading: Radio<Party?>(
                  value: null,
                  groupValue: _selectedCustomer,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() => _selectedCustomer = null);
                  },
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedCustomer = null);
                },
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle: null,
                      leading: Radio<Party?>(
                        value: customer,
                        groupValue: _selectedCustomer,
                        onChanged: (value) {
                          Navigator.pop(context);
                          setState(() => _selectedCustomer = value);
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedCustomer = customer);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generatePaymentInPDF() async {
    try {
      final paymentsAsync = ref.read(paymentInsProvider);
      final company = ref.read(currentCompanyProvider);

      if (company == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No company selected'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final payments = paymentsAsync.maybeWhen(
        data: (data) => data,
        orElse: () => <PaymentIn>[],
      );
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;

      // Filter payments based on current filters
      var filteredPayments = payments.where((payment) {
        final isWithinDateRange = payment.receiptDate
                .isAfter(_startDate.subtract(const Duration(days: 1))) &&
            payment.receiptDate.isBefore(_endDate.add(const Duration(days: 1)));

        final matchesCustomer = _selectedCustomer == null ||
            payment.partyId == _selectedCustomer!.id;

        return isWithinDateRange && matchesCustomer;
      }).toList();

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final searchablePayments = <PaymentIn>[];
        for (final payment in filteredPayments) {
          final party = await isar.partys.get(payment.partyId);
          final partyName = party?.name.toLowerCase() ?? '';
          final receiptNo = payment.receiptNo.toLowerCase();
          final amount = payment.totalAmount.toString();

          if (partyName.contains(_searchQuery) ||
              receiptNo.contains(_searchQuery) ||
              amount.contains(_searchQuery)) {
            searchablePayments.add(payment);
          }
        }
        filteredPayments = searchablePayments;
      }

      // Sort by date (newest first)
      filteredPayments.sort((a, b) => b.receiptDate.compareTo(a.receiptDate));

      // Generate PDF
      final pdfData = await _createPaymentInPDF(
        company: company,
        payments: filteredPayments,
        isar: isar,
      );

      Navigator.of(context).pop(); // Remove loading dialog

      // Share the PDF
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/payment_in_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(pdfData);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Payment In Report - ${company.name}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment In report PDF generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List> _createPaymentInPDF({
    required Company company,
    required List<PaymentIn> payments,
    required Isar isar,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat('#,##,##0.00');
    final dateFormat = DateFormat('dd MMM, yyyy');

    // Calculate totals
    final totalAmount =
        payments.fold<double>(0, (sum, payment) => sum + payment.totalAmount);

    // Collect customer names for all payments
    final Map<int, String> customerNames = {};
    for (final payment in payments) {
      if (!customerNames.containsKey(payment.partyId)) {
        final party = await isar.partys.get(payment.partyId);
        customerNames[payment.partyId] = party?.name ?? 'Unknown Customer';
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Header
            _buildPDFHeader(company, 'Payment In Report'),
            pw.SizedBox(height: 20),

            // Date range and filters info
            _buildFilterInfo(),
            pw.SizedBox(height: 20),

            // Summary
            _buildSummarySection(totalAmount, payments.length, currencyFormat),
            pw.SizedBox(height: 20),

            // Payment records table
            if (payments.isNotEmpty) ...[
              pw.Text(
                'Payment Records',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPaymentTable(
                  payments, customerNames, dateFormat, currencyFormat),
            ] else ...[
              pw.Center(
                child: pw.Text(
                  'No payment records found for the selected criteria',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPDFHeader(Company company, String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  company.name,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
                pw.Text(
                  'Generated: ${DateFormat('dd MMM, yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.blue),
      ],
    );
  }

  pw.Widget _buildFilterInfo() {
    final dateFormat = DateFormat('dd MMM, yyyy');
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Report Filters',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '📅 Date Range: ${dateFormat.format(_startDate)} to ${dateFormat.format(_endDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          if (_selectedCustomer != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              '👤 Customer: ${_selectedCustomer!.name}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
          if (_searchQuery.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              '🔍 Search: "$_searchQuery"',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSummarySection(
      double totalAmount, int recordCount, NumberFormat currencyFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            children: [
              pw.Text(
                'Total Records',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                recordCount.toString(),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green700,
                ),
              ),
            ],
          ),
          pw.Container(
            width: 1,
            height: 40,
            color: PdfColors.green200,
          ),
          pw.Column(
            children: [
              pw.Text(
                'Total Amount',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Rs ${currencyFormat.format(totalAmount)}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentTable(
      List<PaymentIn> payments,
      Map<int, String> customerNames,
      DateFormat dateFormat,
      NumberFormat currencyFormat) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.5), // Date
        1: pw.FlexColumnWidth(2), // Receipt No
        2: pw.FlexColumnWidth(3), // Customer
        3: pw.FlexColumnWidth(2), // Amount
        4: pw.FlexColumnWidth(2.5), // Description
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue50),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Receipt No.', isHeader: true),
            _buildTableCell('Customer', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
            _buildTableCell('Description', isHeader: true),
          ],
        ),
        // Data rows
        ...payments.map((payment) {
          return pw.TableRow(
            children: [
              _buildTableCell(dateFormat.format(payment.receiptDate)),
              _buildTableCell(payment.receiptNo),
              _buildTableCell(
                  customerNames[payment.partyId] ?? 'Unknown Customer'),
              _buildTableCell(
                  'Rs ${currencyFormat.format(payment.totalAmount)}'),
              _buildTableCell(payment.description ?? '-'),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blue900 : PdfColors.black,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
}

class _PaymentsList extends ConsumerWidget {
  final List<PaymentIn> payments;
  final String searchQuery;
  final Party? selectedCustomer;
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onPaymentDeleted;

  const _PaymentsList({
    required this.payments,
    required this.searchQuery,
    required this.selectedCustomer,
    required this.startDate,
    required this.endDate,
    required this.onPaymentDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getPaymentsWithCustomers(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading payments...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading payments',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final paymentsWithCustomers = snapshot.data ?? [];
        final filtered = paymentsWithCustomers.where((item) {
          final payment = item['payment'] as PaymentIn;
          final customer = item['customer'] as Party?;

          // Date range filter
          final paymentDate = DateTime(
            payment.receiptDate.year,
            payment.receiptDate.month,
            payment.receiptDate.day,
          );
          final isInDateRange = paymentDate
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              paymentDate.isBefore(endDate.add(const Duration(days: 1)));

          if (!isInDateRange) return false;

          // Customer filter
          if (selectedCustomer != null) {
            if (customer?.id != selectedCustomer!.id) return false;
          }

          // Search query filter
          if (searchQuery.isNotEmpty) {
            final matchesSearch =
                (customer?.name.toLowerCase().contains(searchQuery) ?? false) ||
                    payment.receiptNo.toLowerCase().contains(searchQuery) ||
                    payment.totalAmount.toString().contains(searchQuery);
            if (!matchesSearch) return false;
          }

          return true;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No payment receipts found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try adjusting your search terms',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final payment = filtered[index]['payment'] as PaymentIn;
            return _PaymentCard(
              payment: payment,
              onDeleted: onPaymentDeleted,
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getPaymentsWithCustomers(
      WidgetRef ref) async {
    final isarService = ref.read(isarServiceProvider);
    final isar = isarService.isar;

    final paymentsWithCustomers = <Map<String, dynamic>>[];
    for (final payment in payments) {
      final customer = await isar.partys.get(payment.partyId);
      paymentsWithCustomers.add({
        'payment': payment,
        'customer': customer,
      });
    }

    return paymentsWithCustomers;
  }
}

class _PaymentCard extends ConsumerWidget {
  final PaymentIn payment;
  final VoidCallback onDeleted;

  const _PaymentCard({
    required this.payment,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarService = ref.read(isarServiceProvider);
    final paymentDao = ref.read(paymentDaoProvider);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([
        isarService.isar.partys.get(payment.partyId),
        paymentDao.getPaymentInLines(payment.id),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        final customer = snapshot.data?[0] as Party?;
        final lines = snapshot.data?[1] as List<PaymentInLine>? ?? [];

        return Dismissible(
          key: Key('payment_${payment.id}'),
          direction: DismissDirection.startToEnd,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.only(bottom: 12),
            child: const Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Payment'),
                content: Text(
                    'Are you sure you want to delete payment receipt #${payment.receiptNo}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            try {
              await paymentDao.deletePaymentIn(payment.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Payment receipt #${payment.receiptNo} deleted'),
                    backgroundColor: Colors.green,
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: Colors.white,
                      onPressed: onDeleted,
                    ),
                  ),
                );
                onDeleted();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting payment: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
                onDeleted();
              }
            }
          },
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () async {
                final result =
                    await context.push('/payments/in/form?id=${payment.id}');
                if (result == true && context.mounted) {
                  onDeleted();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer?.name ?? 'Unknown Customer',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${payment.receiptDate.day.toString().padLeft(2, '0')}/${payment.receiptDate.month.toString().padLeft(2, '0')}/${payment.receiptDate.year} • ${payment.receiptDate.hour.toString().padLeft(2, '0')}:${payment.receiptDate.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.blue.shade200,
                            ),
                          ),
                          child: Text(
                            'Payment-In',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total: Rs ${payment.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Balance: Rs ${payment.totalAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rs ${payment.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
