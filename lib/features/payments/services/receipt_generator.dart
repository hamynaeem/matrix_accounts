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
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';

class ReceiptGenerator {
  static final _dateFormat = DateFormat('dd MMM, yyyy');
  static final _currencyFormat = NumberFormat('#,##,##0.00');

  // Generate receipt as image
  static Future<Uint8List> generateReceiptImage({
    required Company company,
    required Party party,
    required PaymentIn payment,
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
      'Payment-In',
      const Offset(320, 150),
      const TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
    );

    // Received from
    _drawText(
      canvas,
      'Received from:',
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

    // Receipt No
    _drawText(
      canvas,
      'Receipt No.',
      const Offset(600, 220),
      TextStyle(fontSize: 14, color: Colors.grey.shade600),
    );
    _drawText(
      canvas,
      payment.receiptNo,
      const Offset(600, 245),
      const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
    );

    // Date
    _drawText(
      canvas,
      'Date: ${_dateFormat.format(payment.receiptDate)}',
      const Offset(600, 280),
      const TextStyle(fontSize: 14, color: Colors.black87),
    );

    // Amounts box
    final boxPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 350, 720, 150),
        const Radius.circular(12),
      ),
      boxPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 350, 720, 150),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    _drawText(
      canvas,
      'Amounts',
      const Offset(60, 370),
      const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );

    _drawText(
      canvas,
      'Received Amount',
      const Offset(60, 420),
      TextStyle(fontSize: 16, color: Colors.grey.shade700),
    );
    _drawText(
      canvas,
      'Rs ${_currencyFormat.format(totalAmount)}',
      const Offset(600, 420),
      const TextStyle(fontSize: 16, color: Colors.black87),
    );

    _drawText(
      canvas,
      'Total Amount',
      const Offset(60, 460),
      const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2196F3)),
    );
    _drawText(
      canvas,
      'Rs ${_currencyFormat.format(totalAmount)}',
      const Offset(600, 460),
      const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2196F3)),
    );

    // Add image if provided
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final image = await decodeImageFromList(bytes);

          // Draw image
          const imageTop = 550.0;
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
    required Party party,
    required PaymentIn payment,
    required double totalAmount,
    String? imagePath,
  }) async {
    final pdf = pw.Document();

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
                        'GENERATED ON',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Title
              pw.Center(
                child: pw.Text(
                  'Payment-In',
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
                        'Received from:',
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
                        'Receipt No.',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        payment.receiptNo,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Date: ${_dateFormat.format(payment.receiptDate)}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Amounts box
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Amounts',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Received Amount',
                            style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('Rs ${_currencyFormat.format(totalAmount)}',
                            style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Amount',
                            style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue)),
                        pw.Text('Rs ${_currencyFormat.format(totalAmount)}',
                            style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue)),
                      ],
                    ),
                  ],
                ),
              ),

              // Image if provided
              if (pdfImage != null) ...[
                pw.SizedBox(height: 30),
                pw.Center(
                  child:
                      pw.Image(pdfImage, height: 200, fit: pw.BoxFit.contain),
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
    required Party party,
    required PaymentIn payment,
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
                  await _shareAsImage(
                      company, party, payment, totalAmount, imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Share as PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareAsPdf(
                      company, party, payment, totalAmount, imagePath);
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
    PaymentIn payment,
    double totalAmount,
    String? imagePath,
  ) async {
    try {
      final imageBytes = await generateReceiptImage(
        company: company,
        party: party,
        payment: payment,
        totalAmount: totalAmount,
        imagePath: imagePath,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/receipt_${payment.receiptNo}.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Payment Receipt - ${payment.receiptNo}',
      );
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> _shareAsPdf(
    Company company,
    Party party,
    PaymentIn payment,
    double totalAmount,
    String? imagePath,
  ) async {
    try {
      final pdfBytes = await generateReceiptPdf(
        company: company,
        party: party,
        payment: payment,
        totalAmount: totalAmount,
        imagePath: imagePath,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/receipt_${payment.receiptNo}.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Payment Receipt - ${payment.receiptNo}',
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
