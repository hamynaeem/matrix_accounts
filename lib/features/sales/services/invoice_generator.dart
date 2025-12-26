import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../data/models/company_model.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/transaction_model.dart';

class InvoiceGenerator {
  static final _dateFormat = DateFormat('dd MMM, yyyy');
  static final _currencyFormat = NumberFormat('#,##,##0.00');

  // Generate invoice as image
  static Future<Uint8List> generateInvoiceImage({
    required Company company,
    required Party party,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>>
        lineItems, // product name, qty, rate, amount
    List<Map<String, dynamic>>? paymentLines,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(800, 1400);

      // Background - use a slightly off-white background for better contrast
      final paint = Paint()..color = const Color(0xFFFAFAFA);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Add a border for debugging
      final borderPaint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
          borderPaint);

      // Header - Company name
      _drawText(
        canvas,
        company.name,
        const Offset(40, 40),
        const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
      );

      // Invoice ID
      _drawText(
        canvas,
        invoice.id.toString(),
        const Offset(40, 75),
        TextStyle(fontSize: 14, color: Colors.grey.shade600),
      );

      // Title
      _drawText(
        canvas,
        'Sales Invoice',
        const Offset(300, 150),
        const TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
      );

      // Customer details
      _drawText(
        canvas,
        'Bill To:',
        const Offset(40, 220),
        TextStyle(fontSize: 14, color: Colors.grey.shade600),
      );
      _drawText(
        canvas,
        party.name,
        const Offset(40, 245),
        const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
      );

      // Invoice No
      _drawText(
        canvas,
        'Invoice No.',
        const Offset(600, 220),
        TextStyle(fontSize: 14, color: Colors.grey.shade600),
      );
      _drawText(
        canvas,
        transaction.referenceNo,
        const Offset(600, 245),
        const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
      );

      // Date
      _drawText(
        canvas,
        'Date: ${_dateFormat.format(invoice.invoiceDate)}',
        const Offset(600, 280),
        const TextStyle(fontSize: 14, color: Colors.black87),
      );

      // Items table
      double yPos = 340;

      // Table header background
      final headerPaint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(40, yPos, 720, 35), headerPaint);

      // Table headers
      _drawText(canvas, 'Item', Offset(50, yPos + 8),
          const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
      _drawText(canvas, 'Qty', Offset(410, yPos + 8),
          const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
      _drawText(canvas, 'Rate', Offset(510, yPos + 8),
          const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
      _drawText(canvas, 'Amount', Offset(660, yPos + 8),
          const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));

      yPos += 35;

      // Table border - draw the header border
      final headerBorderPaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRect(const Rect.fromLTWH(40, 340, 720, 35), headerBorderPaint);

      // Items
      double subTotal = 0;

      // Debug: Print lineItems data
      print('=== LINE ITEMS DEBUG ===');
      print('lineItems count: ${lineItems.length}');
      for (int i = 0; i < lineItems.length; i++) {
        print('Item $i: ${lineItems[i]}');
      }
      print('========================');

      // Debug: Check if lineItems is empty
      if (lineItems.isEmpty) {
        print('WARNING: lineItems is empty in generateInvoiceImage');
        // Add a placeholder item to show there's an issue
        _drawText(
            canvas,
            'No items found',
            Offset(50, yPos + 8),
            TextStyle(
                fontSize: 13,
                color: Colors.red.shade700,
                fontStyle: FontStyle.italic));
        yPos += 30;
      } else {
        print('Rendering ${lineItems.length} line items');
        for (int index = 0; index < lineItems.length; index++) {
          final line = lineItems[index];
          print('Processing line item $index: $line');

          // Try different possible key names for flexibility
          final productName = line['productName'] as String? ??
              line['product_name'] as String? ??
              line['item_name'] as String? ??
              line['name'] as String? ??
              'Unknown Product';

          final qty =
              (line['qty'] as num? ?? line['quantity'] as num? ?? 0).toDouble();

          final rate = (line['rate'] as num? ??
                  line['price'] as num? ??
                  line['unit_price'] as num? ??
                  0)
              .toDouble();

          final amount = qty * rate;
          subTotal += amount;

          print(
              'Rendering: $productName, Qty: $qty, Rate: $rate, Amount: $amount');

          canvas.drawLine(Offset(40, yPos), Offset(760, yPos), borderPaint);

          _drawText(canvas, productName, Offset(50, yPos + 8),
              const TextStyle(fontSize: 13, color: Colors.black87));
          _drawText(canvas, qty.toStringAsFixed(0), Offset(410, yPos + 8),
              const TextStyle(fontSize: 13, color: Colors.black87));
          _drawText(canvas, _currencyFormat.format(rate), Offset(510, yPos + 8),
              const TextStyle(fontSize: 13, color: Colors.black87));
          _drawText(
              canvas,
              _currencyFormat.format(amount),
              Offset(660, yPos + 8),
              const TextStyle(fontSize: 13, color: Colors.black87));

          yPos += 30;
        }
      }

      // Bottom border
      canvas.drawLine(Offset(40, yPos), Offset(760, yPos), borderPaint);

      // Draw the complete table border (but don't redraw over the content)
      final tableBorderPaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Left border
      canvas.drawLine(
          const Offset(40, 340), Offset(40, yPos), tableBorderPaint);
      // Right border
      canvas.drawLine(
          const Offset(760, 340), Offset(760, yPos), tableBorderPaint);
      // Bottom border (already drawn above)
      // Top border (already drawn for header)

      yPos += 20;

      // Amounts section
      final amountBoxPaint = Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40, yPos, 720, 100),
          const Radius.circular(12),
        ),
        amountBoxPaint,
      );

      final amountBorderPaint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40, yPos, 720, 100),
          const Radius.circular(12),
        ),
        amountBorderPaint,
      );

      _drawText(canvas, 'Sub Total', Offset(500, yPos + 20),
          const TextStyle(fontSize: 14));
      _drawText(canvas, 'Rs ${_currencyFormat.format(subTotal)}',
          Offset(650, yPos + 20), const TextStyle(fontSize: 14));

      _drawText(
          canvas,
          'Grand Total',
          Offset(500, yPos + 55),
          const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3)));
      _drawText(
          canvas,
          'Rs ${_currencyFormat.format(invoice.grandTotal)}',
          Offset(650, yPos + 55),
          const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3)));

      yPos += 120;

      // Payment details section if available
      if (paymentLines != null && paymentLines.isNotEmpty) {
        _drawText(canvas, 'Payment Details', Offset(40, yPos),
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
        yPos += 30;

        final paymentBoxPaint = Paint()
          ..color = Colors.green.shade50
          ..style = PaintingStyle.fill;

        double paymentBoxHeight = 60 + (paymentLines.length * 30.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(40, yPos, 720, paymentBoxHeight),
            const Radius.circular(12),
          ),
          paymentBoxPaint,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(40, yPos, 720, paymentBoxHeight),
            const Radius.circular(12),
          ),
          amountBorderPaint,
        );

        _drawText(canvas, 'Cash Receipt', Offset(60, yPos + 15),
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
        yPos += 40;

        double totalPaid = 0;
        for (final payment in paymentLines) {
          final accountName = payment['accountName'] as String? ?? 'Unknown';
          final amount = payment['amount'] as double? ?? 0;
          totalPaid += amount;

          _drawText(canvas, accountName, Offset(80, yPos),
              const TextStyle(fontSize: 14));
          _drawText(canvas, 'Rs ${_currencyFormat.format(amount)}',
              Offset(650, yPos), const TextStyle(fontSize: 14));
          yPos += 25;
        }

        yPos += 10;
        _drawText(
            canvas,
            'Total Paid',
            Offset(500, yPos),
            const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50)));
        _drawText(
            canvas,
            'Rs ${_currencyFormat.format(totalPaid)}',
            Offset(650, yPos),
            const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50)));

        yPos += 35;
        final due = invoice.grandTotal - totalPaid;
        _drawText(
            canvas,
            'Due Amount',
            Offset(500, yPos),
            const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5722)));
        _drawText(
            canvas,
            'Rs ${_currencyFormat.format(due)}',
            Offset(650, yPos),
            const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5722)));
      }

      final picture = recorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate image data');
      }

      final imageBytes = byteData.buffer.asUint8List();
      print('Generated image with ${imageBytes.length} bytes');
      return imageBytes;
    } catch (e) {
      print('Error generating invoice image: $e');
      rethrow;
    }
  }

  // Generate invoice as PDF
  static Future<Uint8List> generateInvoicePdf({
    required Company company,
    required Party party,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
  }) async {
    final pdf = pw.Document();

    // Build items table
    List<pw.TableRow> itemRows = [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Item',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Qty',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Rate',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    ];

    double subTotal = 0;
    for (final line in lineItems) {
      final productName = line['productName'] as String? ?? 'Unknown Product';
      final qty = line['qty'] as double? ?? 0;
      final rate = line['rate'] as double? ?? 0;
      final amount = qty * rate;
      subTotal += amount;

      itemRows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(productName),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(qty.toStringAsFixed(2)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(_currencyFormat.format(rate)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(_currencyFormat.format(amount)),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
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
                        invoice.id.toString(),
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'GENERATED ON',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Title
              pw.Center(
                child: pw.Text(
                  'Sales Invoice',
                  style: pw.TextStyle(
                      fontSize: 32, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 30),

              // Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To:',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        party.name,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Invoice No.',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        transaction.referenceNo,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Date: ${_dateFormat.format(invoice.invoiceDate)}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Items table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: itemRows,
              ),
              pw.SizedBox(height: 20),

              // Amounts
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Sub Total',
                            style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('Rs ${_currencyFormat.format(subTotal)}',
                            style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Grand Total',
                            style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue)),
                        pw.Text(
                            'Rs ${_currencyFormat.format(invoice.grandTotal)}',
                            style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue)),
                      ],
                    ),
                  ],
                ),
              ),

              // Payment details
              if (paymentLines != null && paymentLines.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text('Payment Details',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Cash Receipt',
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      ...paymentLines.map((payment) {
                        final accountName =
                            payment['accountName'] as String? ?? 'Unknown';
                        final amount = payment['amount'] as double? ?? 0;
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(accountName),
                              pw.Text('Rs ${_currencyFormat.format(amount)}'),
                            ],
                          ),
                        );
                      }),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Paid',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green)),
                          pw.Text(
                            'Rs ${_currencyFormat.format(paymentLines.fold(0.0, (sum, p) => sum + (p['amount'] as double? ?? 0)))}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Due Amount',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red)),
                          pw.Text(
                            'Rs ${_currencyFormat.format(invoice.grandTotal - paymentLines.fold(0.0, (sum, p) => sum + (p['amount'] as double? ?? 0)))}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Share invoice with options
  static Future<void> shareInvoice({
    required BuildContext context,
    required Company company,
    required Party party,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Invoice',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Share as Image'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareAsImage(company, party, invoice, transaction,
                      lineItems, paymentLines);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Share as PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareAsPdf(company, party, invoice, transaction,
                      lineItems, paymentLines);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _shareAsImage(
    Company company,
    Party party,
    Invoice invoice,
    Transaction transaction,
    List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
  ) async {
    try {
      print('Starting image generation for invoice ${transaction.referenceNo}');
      print('Line items count: ${lineItems.length}');

      final imageBytes = await generateInvoiceImage(
        company: company,
        party: party,
        invoice: invoice,
        transaction: transaction,
        lineItems: lineItems,
        paymentLines: paymentLines,
      );

      print('Image generated successfully, size: ${imageBytes.length} bytes');

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'invoice_${transaction.referenceNo}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      print('Image saved to: ${file.path}');

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sales Invoice - ${transaction.referenceNo}',
      );

      print('Image shared successfully');
    } catch (e) {
      print('Error sharing image: $e');
      // You might want to show a user-friendly error message here
      rethrow;
    }
  }

  static Future<void> _shareAsPdf(
    Company company,
    Party party,
    Invoice invoice,
    Transaction transaction,
    List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
  ) async {
    try {
      final pdfBytes = await generateInvoicePdf(
        company: company,
        party: party,
        invoice: invoice,
        transaction: transaction,
        lineItems: lineItems,
        paymentLines: paymentLines,
      );

      final tempDir = await getTemporaryDirectory();
      final file =
          File('${tempDir.path}/invoice_${transaction.referenceNo}.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sales Invoice - ${transaction.referenceNo}',
      );
    } catch (e) {
      // Handle error
    }
  }

  static void _drawText(
      Canvas canvas, String text, Offset position, TextStyle style) {
    try {
      final textSpan = TextSpan(text: text, style: style);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.left,
      );

      textPainter.layout();

      // Add bounds checking
      if (position.dx >= 0 && position.dy >= 0) {
        textPainter.paint(canvas, position);
      } else {
        print('Warning: Invalid text position $position for text: $text');
      }
    } catch (e) {
      print('Error drawing text "$text" at $position: $e');
    }
  }
}
