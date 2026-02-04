import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../data/models/company_model.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';

class PaymentOutReceiptGenerator {
  static final _dateFormat = DateFormat('dd MMM, yyyy');
  static final _currencyFormat = NumberFormat('#,##,##0.00');

  // Generate receipt as image
  static Future<Uint8List> generateReceiptImage({
    required Company company,
    required Party supplier,
    required PaymentOut payment,
    required List<PaymentOutLine> lines,
    required double totalAmount,
    String? imagePath,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(800, 1200);

    // Background
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Header - Company name
    _drawText(
      canvas,
      company.name,
      const Offset(40, 40),
      const TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
    );

    // Company ID
    _drawText(
      canvas,
      payment.id.toString(),
      const Offset(40, 75),
      TextStyle(fontSize: 14, color: Colors.grey.shade600),
    );

    // Title
    _drawText(
      canvas,
      'Payment-Out',
      const Offset(280, 150),
      const TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red),
    );

    // Paid to
    _drawText(
      canvas,
      'Paid to:',
      const Offset(40, 220),
      TextStyle(fontSize: 14, color: Colors.grey.shade600),
    );
    _drawText(
      canvas,
      supplier.name,
      const Offset(40, 245),
      const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
    );

    // Voucher No
    _drawText(
      canvas,
      'Voucher No.',
      const Offset(600, 220),
      TextStyle(fontSize: 14, color: Colors.grey.shade600),
    );
    _drawText(
      canvas,
      payment.voucherNo,
      const Offset(600, 245),
      const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
    );

    // Date
    _drawText(
      canvas,
      'Date: ${_dateFormat.format(payment.voucherDate)}',
      const Offset(600, 280),
      const TextStyle(fontSize: 14, color: Colors.black87),
    );

    // Payment lines
    double currentY = 350;
    _drawText(
      canvas,
      'Payment Details',
      Offset(40, currentY),
      const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
    currentY += 30;

    for (final line in lines) {
      // Look up the payment account to get its name
      final isar = Isar.getInstance();
      final account = isar != null
          ? await isar.paymentAccounts.get(line.paymentAccountId)
          : null;
      final accountName = account?.accountName ?? 'Unknown';

      _drawText(
        canvas,
        accountName,
        Offset(40, currentY),
        TextStyle(fontSize: 14, color: Colors.grey.shade700),
      );
      _drawText(
        canvas,
        'Rs ${_currencyFormat.format(line.amount)}',
        Offset(600, currentY),
        const TextStyle(fontSize: 14, color: Colors.black87),
      );
      currentY += 25;
    }

    // Amounts box
    currentY += 20;
    final boxPaint = Paint()
      ..color = Colors.red.shade50
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(40, currentY, 720, 120),
        const Radius.circular(12),
      ),
      boxPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.red.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(40, currentY, 720, 120),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    currentY += 15;
    _drawText(
      canvas,
      'Total Paid Amount',
      Offset(60, currentY),
      const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
    );
    _drawText(
      canvas,
      'Rs ${_currencyFormat.format(totalAmount)}',
      Offset(600, currentY),
      const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
    );

    // Add image if provided
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final image = await decodeImageFromList(bytes);

          // Draw image
          const imageTop = 900.0;
          const imageHeight = 200.0;
          final imageWidth = (image.width / image.height) * imageHeight;
          final imageLeft = (size.width - imageWidth) / 2;

          canvas.drawImageRect(
            image,
            Rect.fromLTWH(
                0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(imageLeft, imageTop, imageWidth, imageHeight),
            Paint(),
          );
        }
      } catch (e) {
        // Ignore image errors
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Generate receipt as PDF
  static Future<Uint8List> generateReceiptPdf({
    required Company company,
    required Party supplier,
    required PaymentOut payment,
    required List<PaymentOutLine> lines,
    required double totalAmount,
    String? imagePath,
  }) async {
    final pdf = pw.Document();
    final isar = Isar.getInstance();

    // Pre-process lines to get account names
    final processedLines = <MapEntry<String, double>>[];
    for (final line in lines) {
      final account = isar != null
          ? await isar.paymentAccounts.get(line.paymentAccountId)
          : null;
      final accountName = account?.accountName ?? 'Unknown';
      processedLines.add(MapEntry(accountName, line.amount));
    }

    pw.ImageProvider? pdfImage;
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          pdfImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        // Ignore image errors
      }
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
                        payment.id.toString(),
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'PAYMENT-OUT',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Title
              pw.Center(
                child: pw.Text(
                  'Payment-Out Voucher',
                  style: pw.TextStyle(
                      fontSize: 32, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 40),

              // Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Paid to:',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        supplier.name,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Voucher No.',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        payment.voucherNo,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Date: ${_dateFormat.format(payment.voucherDate)}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Payment details table
              pw.Text(
                'Payment Details',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Payment Type',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
                  // Data rows
                  ...processedLines.map((entry) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(entry.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rs ${_currencyFormat.format(entry.value)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 30),

              // Amounts box
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red100,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.red),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Paid Amount',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Rs ${_currencyFormat.format(totalAmount)}',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                  ],
                ),
              ),

              // Image if provided
              if (pdfImage != null) ...[
                pw.SizedBox(height: 30),
                pw.Center(
                  child:
                      pw.Image(pdfImage, height: 150, fit: pw.BoxFit.contain),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Share receipt with options
  static Future<void> shareReceipt({
    required BuildContext context,
    required Company company,
    required Party supplier,
    required PaymentOut payment,
    required List<PaymentOutLine> lines,
    required double totalAmount,
    String? imagePath,
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
                'Share Receipt',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Share as Image'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareAsImage(company, supplier, payment, lines,
                      totalAmount, imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Share as PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareAsPdf(company, supplier, payment, lines,
                      totalAmount, imagePath);
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
    Party supplier,
    PaymentOut payment,
    List<PaymentOutLine> lines,
    double totalAmount,
    String? imagePath,
  ) async {
    try {
      final imageBytes = await generateReceiptImage(
        company: company,
        supplier: supplier,
        payment: payment,
        lines: lines,
        totalAmount: totalAmount,
        imagePath: imagePath,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/payment_out_${payment.voucherNo}.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Payment Out Voucher - ${payment.voucherNo}',
      );
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> _shareAsPdf(
    Company company,
    Party supplier,
    PaymentOut payment,
    List<PaymentOutLine> lines,
    double totalAmount,
    String? imagePath,
  ) async {
    try {
      final pdfBytes = await generateReceiptPdf(
        company: company,
        supplier: supplier,
        payment: payment,
        lines: lines,
        totalAmount: totalAmount,
        imagePath: imagePath,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/payment_out_${payment.voucherNo}.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Payment Out Voucher - ${payment.voucherNo}',
      );
    } catch (e) {
      // Handle error
    }
  }

  static void _drawText(
      Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }
}
