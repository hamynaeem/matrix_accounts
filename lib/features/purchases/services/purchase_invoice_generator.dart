// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/company_model.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/transaction_model.dart';

class PurchaseInvoiceGenerator {
  static final _dateFormat = DateFormat('dd MMM, yyyy hh:mm a');
  static final _currencyFormat = NumberFormat('#,##,##0.00');

  // Generate purchase invoice as image
  static Future<Uint8List> generatePurchaseInvoiceImage({
    required Company company,
    required Party supplier,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>>
        lineItems, // product name, qty, rate, amount
    List<Map<String, dynamic>>? paymentLines,
    double? supplierBalance,
    double? openingBalance,
  }) async {
    try {
      // Debug: Print opening balance parameter
      print('=== PURCHASE OPENING BALANCE DEBUG ===');
      print('openingBalance parameter: $openingBalance');
      print('supplierBalance parameter: $supplierBalance');
      print('======================================');

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(800, 1400);

      // Background - use a slightly off-white background for better contrast
      final paint = Paint()..color = const Color(0xFFFAFAFA);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Add a border
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
        'Purchase Invoice',
        const Offset(280, 150),
        const TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
      );

      // Supplier details
      _drawText(
        canvas,
        'Bill From:',
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
      if (supplier.phone != null && supplier.phone!.isNotEmpty) {
        _drawText(
          canvas,
          'Phone: ${supplier.phone}',
          const Offset(40, 270),
          const TextStyle(fontSize: 14, color: Colors.black87),
        );
      }

      // Date & Time
      _drawText(
        canvas,
        'Date & Time: ${_dateFormat.format(invoice.invoiceDate)}',
        const Offset(600, 280),
        const TextStyle(fontSize: 14, color: Colors.black87),
      );

      // Items table
      double yPos = 340;

      // Table header background
      final headerPaint = Paint()
        ..color = Colors.orange.shade100
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(40, yPos, 720, 35), headerPaint);

      // Table headers
      _drawText(
          canvas,
          'Item',
          Offset(50, yPos + 8),
          const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
      _drawRightAlignedText(
          canvas,
          'Qty',
          Offset(480, yPos + 8),
          const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
      _drawRightAlignedText(
          canvas,
          'Rate',
          Offset(600, yPos + 8),
          const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
      _drawRightAlignedText(
          canvas,
          'Amount',
          Offset(750, yPos + 8),
          const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87));

      yPos += 35;

      // Table border - draw the header border
      final headerBorderPaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRect(const Rect.fromLTWH(40, 340, 720, 35), headerBorderPaint);

      // Items
      double subTotal = 0;
      double totalQuantity = 0;
      double totalRate = 0;

      // Debug: Print lineItems data
      print('=== PURCHASE LINE ITEMS DEBUG ===');
      print('lineItems count: ${lineItems.length}');
      for (int i = 0; i < lineItems.length; i++) {
        print('Item $i: ${lineItems[i]}');
      }
      print('===================================');

      // Debug: Check if lineItems is empty
      if (lineItems.isEmpty) {
        print('WARNING: lineItems is empty in generatePurchaseInvoiceImage');
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
          totalQuantity += qty;
          totalRate += rate;

          print(
              'Rendering: $productName, Qty: $qty, Rate: $rate, Amount: $amount');

          canvas.drawLine(Offset(40, yPos), Offset(760, yPos), borderPaint);

          // Item name (left aligned)
          _drawText(canvas, productName, Offset(50, yPos + 8),
              const TextStyle(fontSize: 13, color: Colors.black87));

          // Quantity (right aligned)
          final qtyText = qty == qty.roundToDouble()
              ? qty.toStringAsFixed(0)
              : qty.toStringAsFixed(2);
          _drawRightAlignedText(canvas, qtyText, Offset(480, yPos + 8),
              const TextStyle(fontSize: 13, color: Colors.black87));

          // Rate (right aligned)
          _drawRightAlignedText(
              canvas,
              _currencyFormat.format(rate),
              Offset(600, yPos + 8),
              const TextStyle(fontSize: 13, color: Colors.black87));

          // Amount (right aligned)
          _drawRightAlignedText(
              canvas,
              _currencyFormat.format(amount),
              Offset(750, yPos + 8),
              const TextStyle(fontSize: 13, color: Colors.black87));

          yPos += 30;
        }
      }

      // Bottom border
      canvas.drawLine(Offset(40, yPos), Offset(760, yPos), borderPaint);

      // Draw the complete table border
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

      // Display total quantity and total rate
      yPos += 10;
      _drawText(
          canvas,
          'Total Qty: ${totalQuantity == totalQuantity.roundToDouble() ? totalQuantity.toStringAsFixed(0) : totalQuantity.toStringAsFixed(2)} | Total Rate: Rs ${_currencyFormat.format(totalRate)}',
          Offset(520, yPos),
          const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange));

      yPos += 20;

      // Amounts section
      final amountBoxPaint = Paint()
        ..color = Colors.grey.shade100
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40, yPos, 720, 100),
          const Radius.circular(8),
        ),
        amountBoxPaint,
      );

      final amountBorderPaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40, yPos, 720, 100),
          const Radius.circular(8),
        ),
        amountBorderPaint,
      );

      _drawText(
          canvas,
          'Total:',
          Offset(60, yPos + 20),
          const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
      _drawRightAlignedText(
          canvas,
          'Rs ${_currencyFormat.format(subTotal)}',
          Offset(740, yPos + 20),
          const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87));

      yPos += 120;

      // Supplier Opening Balance - Separate Section with improved styling
      if (openingBalance != null) {
        print('Rendering purchase opening balance: $openingBalance');

        // Section title
        _drawText(
            canvas,
            'Supplier Opening Balance',
            Offset(40, yPos),
            const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black));
        yPos += 30;

        // Opening balance container with orange theme to match purchase invoice
        final openingBalanceBoxPaint = Paint()
          ..color = Colors.orange.shade50
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(40, yPos, 720, 50),
            const Radius.circular(6),
          ),
          openingBalanceBoxPaint,
        );

        final openingBalanceBorderPaint = Paint()
          ..color = Colors.orange.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(40, yPos, 720, 50),
            const Radius.circular(6),
          ),
          openingBalanceBorderPaint,
        );

        _drawText(canvas, 'Opening Balance:', Offset(60, yPos + 15),
            const TextStyle(fontSize: 14, color: Colors.black87));

        _drawText(
            canvas,
            openingBalance >= 0
                ? 'We Owe: Rs ${_currencyFormat.format(openingBalance.abs())}'
                : 'They Owe: Rs ${_currencyFormat.format(openingBalance.abs())}',
            Offset(500, yPos + 15),
            const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black));

        yPos += 80; // More space after opening balance
      }

      // Always show Payment Summary section
      double totalPaid = 0;
      if (paymentLines != null && paymentLines.isNotEmpty) {
        totalPaid = paymentLines.fold(
            0.0, (sum, p) => sum + (p['amount'] as double? ?? 0));
      }

      // Payment Summary - Clean Simple Design
      _drawText(
          canvas,
          'Payment Summary',
          Offset(40, yPos),
          const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black));
      yPos += 30;

      // Simple Payment Summary Box
      final summaryBoxPaint = Paint()
        ..color = Colors.grey.shade100
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40, yPos, 720, 120),
          const Radius.circular(4),
        ),
        summaryBoxPaint,
      );

      final summaryBorderPaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40, yPos, 720, 120),
          const Radius.circular(4),
        ),
        summaryBorderPaint,
      );

      yPos += 20;

      // Total Amount - simple styling
      _drawText(canvas, 'Total Amount:', Offset(60, yPos),
          const TextStyle(fontSize: 14, color: Colors.black87));
      _drawText(
          canvas,
          'Rs ${_currencyFormat.format(invoice.grandTotal)}',
          Offset(600, yPos),
          const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));
      yPos += 25;

      // Paid Amount - simple styling
      _drawText(canvas, 'Paid Amount:', Offset(60, yPos),
          const TextStyle(fontSize: 14, color: Colors.black87));
      _drawText(
          canvas,
          'Rs ${_currencyFormat.format(totalPaid)}',
          Offset(600, yPos),
          const TextStyle(fontSize: 14, color: Colors.black));
      yPos += 25;

      // Balance Amount - simple styling
      final due = invoice.grandTotal - totalPaid;
      _drawText(canvas, 'Balance Amount:', Offset(60, yPos),
          const TextStyle(fontSize: 14, color: Colors.black87));
      _drawText(
          canvas,
          due > 0 ? 'Rs ${_currencyFormat.format(due)}' : 'FULLY PAID',
          Offset(600, yPos),
          const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));

      // Supplier Current Balance - Clean Design
      if (supplierBalance != null) {
        yPos += 30;

        // Simple supplier balance container
        final balanceBoxPaint = Paint()
          ..color = Colors.grey.shade100
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(40, yPos, 720, 50),
            const Radius.circular(4),
          ),
          balanceBoxPaint,
        );

        final balanceBorderPaint = Paint()
          ..color = Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(40, yPos, 720, 50),
            const Radius.circular(4),
          ),
          balanceBorderPaint,
        );

        _drawText(canvas, 'Supplier Current Balance:', Offset(60, yPos + 15),
            const TextStyle(fontSize: 14, color: Colors.black87));

        _drawText(
            canvas,
            supplierBalance >= 0
                ? 'We Owe: Rs ${_currencyFormat.format(supplierBalance.abs())}'
                : 'They Owe: Rs ${_currencyFormat.format(supplierBalance.abs())}',
            Offset(500, yPos + 15),
            const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black));
      }

      final picture = recorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate image data');
      }

      final imageBytes = byteData.buffer.asUint8List();
      print('Generated purchase invoice image with ${imageBytes.length} bytes');
      return imageBytes;
    } catch (e) {
      print('Error generating purchase invoice image: $e');
      rethrow;
    }
  }

  static Future<void> _shareAsImage(
    Company company,
    Party supplier,
    Invoice invoice,
    Transaction transaction,
    List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
    double? supplierBalance,
    double? openingBalance,
  ) async {
    try {
      print(
          'Starting purchase invoice image generation for invoice ${transaction.referenceNo}');
      print('Line items count: ${lineItems.length}');

      final imageBytes = await generatePurchaseInvoiceImage(
        company: company,
        supplier: supplier,
        invoice: invoice,
        transaction: transaction,
        lineItems: lineItems,
        paymentLines: paymentLines,
        supplierBalance: supplierBalance,
        openingBalance: openingBalance,
      );

      print(
          'Purchase invoice image generated successfully, size: ${imageBytes.length} bytes');

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'purchase_invoice_${transaction.referenceNo}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      print('Purchase invoice image saved to: ${file.path}');

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Purchase Invoice - ${transaction.referenceNo}',
      );

      print('Purchase invoice image shared successfully');
    } catch (e) {
      print('Error sharing purchase invoice image: $e');
      rethrow;
    }
  }

  // Share purchase invoice with options
  static Future<void> sharePurchaseInvoice({
    required BuildContext context,
    required Company company,
    required Party supplier,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
    double? supplierBalance,
    double? openingBalance,
  }) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          alignment: Alignment.topCenter,
          insetPadding: const EdgeInsets.only(top: 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Share Purchase Invoice',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.image, color: Colors.blue),
                  title: const Text('Share as Image'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareAsImage(
                        company,
                        supplier,
                        invoice,
                        transaction,
                        lineItems,
                        paymentLines,
                        supplierBalance,
                        openingBalance);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Direct share as image method
  static Future<void> shareAsImage({
    required Company company,
    required Party supplier,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
    double? supplierBalance,
    double? openingBalance,
  }) async {
    await _shareAsImage(company, supplier, invoice, transaction, lineItems,
        paymentLines, supplierBalance, openingBalance);
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

  static void _drawRightAlignedText(
      Canvas canvas, String text, Offset position, TextStyle style) {
    try {
      final textSpan = TextSpan(text: text, style: style);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.right,
      );

      textPainter.layout();

      // Calculate right-aligned position
      final rightAlignedPosition = Offset(
        position.dx - textPainter.width,
        position.dy,
      );

      // Add bounds checking
      if (rightAlignedPosition.dx >= 0 && rightAlignedPosition.dy >= 0) {
        textPainter.paint(canvas, rightAlignedPosition);
      } else {
        print(
            'Warning: Invalid right-aligned text position $rightAlignedPosition for text: $text');
      }
    } catch (e) {
      print('Error drawing right-aligned text "$text" at $position: $e');
    }
  }
}
