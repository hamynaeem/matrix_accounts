import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/account_models.dart';
import '../../../data/models/company_model.dart';

class ReportPdfGenerator {
  static final _dateFormat = DateFormat('dd MMM, yyyy');
  static final _currencyFormat = NumberFormat('#,##,##0.00');

  // Generate Balance Sheet PDF
  static Future<Uint8List> generateBalanceSheetPdf({
    required Company company,
    required DateTime asOfDate,
    required List<Account> assetAccounts,
    required List<Account> liabilityAccounts,
    required List<Account> equityAccounts,
    required double totalAssets,
    required double totalLiabilities,
    required double totalEquity,
    required double netIncome,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final isBalanced =
              (totalAssets - (totalLiabilities + totalEquity + netIncome))
                      .abs() <
                  0.01;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildReportHeader(company, 'Balance Sheet',
                  'As of ${_dateFormat.format(asOfDate)}'),
              pw.SizedBox(height: 30),

              // Balance indicator
              if (isBalanced)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('✓ ',
                          style: pw.TextStyle(
                              color: PdfColors.green700,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text('Accounting Equation Balanced',
                          style: pw.TextStyle(
                              color: PdfColors.green700,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                )
              else
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    border: pw.Border.all(color: PdfColors.red),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text('Warning: Books are not balanced!',
                      style: pw.TextStyle(
                          color: PdfColors.red700,
                          fontWeight: pw.FontWeight.bold)),
                ),
              pw.SizedBox(height: 20),

              // Assets
              _buildAccountSection(
                  'ASSETS', assetAccounts, totalAssets, PdfColors.blue),
              pw.SizedBox(height: 20),

              // Liabilities
              _buildAccountSection('LIABILITIES', liabilityAccounts,
                  totalLiabilities, PdfColors.orange),
              pw.SizedBox(height: 20),

              // Equity
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.purple50,
                  border: pw.Border.all(color: PdfColors.purple200),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('EQUITY',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple)),
                    pw.SizedBox(height: 8),
                    ...equityAccounts.map((account) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('  ${account.name}'),
                              pw.Text(_currencyFormat
                                  .format(account.currentBalance)),
                            ],
                          ),
                        )),
                    if (netIncome != 0) ...[
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('  Net Income'),
                            pw.Text(_currencyFormat.format(netIncome)),
                          ],
                        ),
                      ),
                    ],
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Equity',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(_currencyFormat.format(totalEquity + netIncome),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Accounting Equation
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('Accounting Equation',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                            'Assets: ${_currencyFormat.format(totalAssets)}'),
                        pw.Text(' = ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            'Liabilities: ${_currencyFormat.format(totalLiabilities)}'),
                        pw.Text(' + ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            'Equity: ${_currencyFormat.format(totalEquity + netIncome)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Generate Trial Balance PDF
  static Future<Uint8List> generateTrialBalancePdf({
    required Company company,
    required DateTime asOfDate,
    required List<Map<String, dynamic>> accountItems,
    required double totalDebits,
    required double totalCredits,
  }) async {
    final pdf = pw.Document();
    final isBalanced = (totalDebits - totalCredits).abs() < 0.01;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildReportHeader(company, 'Trial Balance',
                  'As of ${_dateFormat.format(asOfDate)}'),
              pw.SizedBox(height: 20),

              // Balance indicator
              if (isBalanced)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('✓ ',
                          style: pw.TextStyle(
                              color: PdfColors.green700,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text('Trial Balance is Balanced',
                          style: pw.TextStyle(
                              color: PdfColors.green700,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                )
              else
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    border: pw.Border.all(color: PdfColors.red),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text('Warning: Trial Balance is NOT Balanced!',
                      style: pw.TextStyle(
                          color: PdfColors.red700,
                          fontWeight: pw.FontWeight.bold)),
                ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.indigo50),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Code',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Account Name',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Debit',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Credit',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...accountItems.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['code'] ?? '',
                              style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['name'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            item['debit'] > 0
                                ? _currencyFormat.format(item['debit'])
                                : '-',
                            style: pw.TextStyle(
                                color: item['debit'] > 0
                                    ? PdfColors.green700
                                    : PdfColors.grey),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            item['credit'] > 0
                                ? _currencyFormat.format(item['credit'])
                                : '-',
                            style: pw.TextStyle(
                                color: item['credit'] > 0
                                    ? PdfColors.blue700
                                    : PdfColors.grey),
                          ),
                        ),
                      ],
                    );
                  }),
                  // Total row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.indigo100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(''),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('TOTAL',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(_currencyFormat.format(totalDebits),
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(_currencyFormat.format(totalCredits),
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Generate Cash Flow PDF
  static Future<Uint8List> generateCashFlowPdf({
    required Company company,
    required DateTime startDate,
    required DateTime endDate,
    required double netIncome,
    required double receivableChange,
    required double payableChange,
    required double inventoryChange,
    required double assetPurchases,
    required double assetSales,
    required double equityIncrease,
    required double equityDecrease,
    required double liabilityIncrease,
    required double liabilityDecrease,
    required double cashBeginning,
    required double cashEnding,
  }) async {
    final pdf = pw.Document();

    final operatingCash =
        netIncome - receivableChange + payableChange - inventoryChange;
    final investingCash = assetSales - assetPurchases;
    final financingCash =
        equityIncrease - equityDecrease + liabilityIncrease - liabilityDecrease;
    final netChange = operatingCash + investingCash + financingCash;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildReportHeader(
                company,
                'Cash Flow Statement',
                'For the period ${_dateFormat.format(startDate)} to ${_dateFormat.format(endDate)}',
              ),
              pw.SizedBox(height: 30),

              // Operating Activities
              _buildCashFlowSection(
                'Cash Flow from Operating Activities',
                [
                  {'label': 'Net Income', 'amount': netIncome, 'indent': false},
                  {'label': 'Adjustments:', 'amount': null, 'indent': false},
                  {
                    'label': 'Decrease in Accounts Receivable',
                    'amount': -receivableChange,
                    'indent': true
                  },
                  {
                    'label': 'Increase in Accounts Payable',
                    'amount': payableChange,
                    'indent': true
                  },
                  {
                    'label': 'Decrease in Inventory',
                    'amount': -inventoryChange,
                    'indent': true
                  },
                ],
                operatingCash,
                PdfColors.green,
              ),
              pw.SizedBox(height: 20),

              // Investing Activities
              _buildCashFlowSection(
                'Cash Flow from Investing Activities',
                [
                  {
                    'label': 'Purchase of Assets',
                    'amount': -assetPurchases,
                    'indent': false
                  },
                  {
                    'label': 'Sale of Assets',
                    'amount': assetSales,
                    'indent': false
                  },
                ],
                investingCash,
                PdfColors.blue,
              ),
              pw.SizedBox(height: 20),

              // Financing Activities
              _buildCashFlowSection(
                'Cash Flow from Financing Activities',
                [
                  {
                    'label': 'Equity Contributions',
                    'amount': equityIncrease,
                    'indent': false
                  },
                  {
                    'label': 'Equity Withdrawals',
                    'amount': -equityDecrease,
                    'indent': false
                  },
                  {
                    'label': 'Loans Received',
                    'amount': liabilityIncrease,
                    'indent': false
                  },
                  {
                    'label': 'Loan Repayments',
                    'amount': -liabilityDecrease,
                    'indent': false
                  },
                ],
                financingCash,
                PdfColors.orange,
              ),
              pw.SizedBox(height: 20),

              // Net Change
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.purple50,
                  border: pw.Border.all(color: PdfColors.purple200),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Net Change in Cash',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple)),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Cash at Beginning of Period'),
                        pw.Text(_currencyFormat.format(cashBeginning)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Net Increase/(Decrease) in Cash'),
                        pw.Text(_currencyFormat.format(netChange),
                            style: pw.TextStyle(
                                color: netChange >= 0
                                    ? PdfColors.green700
                                    : PdfColors.red700)),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Cash at End of Period',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(_currencyFormat.format(cashEnding),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Helper: Build report header
  static pw.Widget _buildReportHeader(
      Company company, String reportTitle, String subtitle) {
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
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  reportTitle,
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated on',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  _dateFormat.format(DateTime.now()),
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2),
      ],
    );
  }

  // Helper: Build account section
  static pw.Widget _buildAccountSection(
      String title, List<Account> accounts, double total, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.05),
        border: pw.Border.all(color: color.shade(0.2)),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
          pw.SizedBox(height: 8),
          ...accounts.map((account) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('  ${account.name}'),
                    pw.Text(_currencyFormat.format(account.currentBalance)),
                  ],
                ),
              )),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total $title',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_currencyFormat.format(total),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: Build cash flow section
  static pw.Widget _buildCashFlowSection(
    String title,
    List<Map<String, dynamic>> items,
    double total,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.05),
        border: pw.Border.all(color: color.shade(0.2)),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
          pw.SizedBox(height: 8),
          ...items.map((item) {
            if (item['amount'] == null) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4, top: 4),
                child: pw.Text(item['label'],
                    style: const pw.TextStyle(
                        fontSize: 11, color: PdfColors.grey700)),
              );
            }
            return pw.Padding(
              padding: pw.EdgeInsets.only(
                  bottom: 4, left: item['indent'] == true ? 16 : 0),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(item['label']),
                  pw.Text(_currencyFormat.format(item['amount'])),
                ],
              ),
            );
          }),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                  'Net Cash from ${title.replaceAll('Cash Flow from ', '')}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_currencyFormat.format(total),
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color:
                          total >= 0 ? PdfColors.green700 : PdfColors.red700)),
            ],
          ),
        ],
      ),
    );
  }

  // Share or print PDF
  static Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: filename,
    );
  }

  // Print PDF directly
  static Future<void> printPdf(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: title,
    );
  }
}
