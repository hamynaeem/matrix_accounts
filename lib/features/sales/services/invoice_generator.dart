// ignore_for_file: avoid_print, unused_element

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/company_model.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/transaction_model.dart';

enum ShareType { general, whatsapp }

class InvoiceGenerator {
  static final _dateFormat = DateFormat('dd MMM, yyyy hh:mm a');
  static final _currencyFormat = NumberFormat('#,##,##0.00');

  // Helper method to calculate total paid amount
  static double _calculateTotalPaid(List<Map<String, dynamic>>? paymentLines) {
    if (paymentLines == null || paymentLines.isEmpty) {
      print('=== PAYMENT CALCULATION DEBUG ===');
      print('No payment lines provided');
      print('Final totalPaid: 0.0');
      print('================================');
      return 0.0;
    }

    double totalPaid = 0.0;
    print('=== PAYMENT CALCULATION DEBUG ===');
    print('paymentLines input: $paymentLines');

    // Track accounts to avoid double counting
    Set<String> processedAccounts = <String>{};

    for (int i = 0; i < paymentLines.length; i++) {
      final paymentLine = paymentLines[i];
      print('Payment line $i: $paymentLine');

      // Get account name for deduplication
      final accountName = paymentLine['accountName']?.toString() ?? 'Unknown';

      // Try different possible key names for amount
      dynamic amountValue = paymentLine['amount'] ??
          paymentLine['paid_amount'] ??
          paymentLine['paymentAmount'] ??
          0;

      print(
          'Account: $accountName, Amount raw value: $amountValue (${amountValue.runtimeType})');

      // Handle different number types more robustly
      double paymentAmount = 0.0;
      if (amountValue is double) {
        paymentAmount = amountValue;
      } else if (amountValue is int) {
        paymentAmount = amountValue.toDouble();
      } else if (amountValue is num) {
        paymentAmount = amountValue.toDouble();
      } else if (amountValue is String && amountValue.isNotEmpty) {
        paymentAmount = double.tryParse(amountValue) ?? 0.0;
      }

      // Only add positive amounts and avoid duplicate accounts
      if (paymentAmount > 0) {
        // For same account type, use the latest/highest amount (avoid duplicates)
        if (processedAccounts.contains(accountName)) {
          print(
              'Duplicate account $accountName found, skipping or updating...');
          // Skip duplicate - the latest entry should be the correct one
          continue;
        }

        processedAccounts.add(accountName);
        totalPaid += paymentAmount;
        print(
            'Added payment: $accountName = $paymentAmount, running total: $totalPaid');
      } else {
        print(
            'Skipping zero or negative payment: $accountName = $paymentAmount');
      }
    }

    print('Final totalPaid: $totalPaid');
    print('Processed accounts: $processedAccounts');
    print('================================');
    return totalPaid;
  }

  // Generate invoice as image
  static Future<Uint8List> generateInvoiceImage({
    required Company company,
    required Party party,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>>
        lineItems, // product name, qty, rate, amount
    List<Map<String, dynamic>>? paymentLines,
    double? customerBalance,
    double? openingBalance,
  }) async {
    try {
      // Debug: Print opening balance parameter
      print('=== OPENING BALANCE DEBUG ===');
      print('openingBalance parameter: $openingBalance');
      print('============================');

      // Debug: Print payment lines data
      print('=== PAYMENT LINES DEBUG ===');
      print('paymentLines parameter: $paymentLines');
      if (paymentLines != null && paymentLines.isNotEmpty) {
        for (int i = 0; i < paymentLines.length; i++) {
          print('Payment $i: ${paymentLines[i]}');
        }
      } else {
        print('No payment lines provided or empty');
      }
      print('===============================');

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

      // Phone number
      if (party.phone != null && party.phone!.isNotEmpty) {
        _drawText(
          canvas,
          'Phone: ${party.phone}',
          const Offset(40, 270),
          TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(40, yPos, 720, 35), headerPaint);

      // Table headers with better alignment
      _drawText(
          canvas,
          'Item',
          Offset(50, yPos + 8),
          const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
      _drawText(
          canvas,
          'Qty',
          Offset(430, yPos + 8),
          const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
      _drawText(
          canvas,
          'Rate',
          Offset(520, yPos + 8),
          const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
      _drawText(
          canvas,
          'Amount',
          Offset(640, yPos + 8),
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
          totalQuantity += qty;

          print(
              'Rendering: $productName, Qty: $qty, Rate: $rate, Amount: $amount');
          print('Running subtotal: $subTotal');

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

      // Add total row to match invoice screenshot
      final totalBgPaint = Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTWH(40, yPos, 720, 30), totalBgPaint);

      _drawText(
          canvas,
          'Total',
          Offset(50, yPos + 8),
          const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
      _drawRightAlignedText(
          canvas,
          'Rs ${_currencyFormat.format(subTotal)}',
          Offset(750, yPos + 8),
          const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87));

      yPos += 30;

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

      // Display totals as separate sections - clean styling
      yPos += 20;

      // Total Quantity Section
      final totalQtyBoxPaint = Paint()
        ..color = Colors.blue.shade50
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40, yPos, 300, 40),
          const Radius.circular(6),
        ),
        totalQtyBoxPaint,
      );

      final totalQtyBorderPaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40, yPos, 300, 40),
          const Radius.circular(6),
        ),
        totalQtyBorderPaint,
      );

      _drawText(
          canvas,
          'Total Quantity',
          Offset(55, yPos + 8),
          const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87));
      _drawRightAlignedText(
          canvas,
          totalQuantity == totalQuantity.roundToDouble()
              ? totalQuantity.toStringAsFixed(0)
              : totalQuantity.toStringAsFixed(2),
          Offset(325, yPos + 22),
          const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));

      // Total Amount Section
      final totalAmountBoxPaint = Paint()
        ..color = Colors.orange.shade50
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(460, yPos, 300, 40),
          const Radius.circular(6),
        ),
        totalAmountBoxPaint,
      );

      final totalAmountBorderPaint = Paint()
        ..color = Colors.orange.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(460, yPos, 300, 40),
          const Radius.circular(6),
        ),
        totalAmountBorderPaint,
      );

      _drawText(
          canvas,
          'Total Amount',
          Offset(475, yPos + 8),
          const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87));
      _drawRightAlignedText(
          canvas,
          'Rs ${_currencyFormat.format(subTotal)}',
          Offset(745, yPos + 22),
          const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));

      yPos += 60;

      // Calculate total paid amount using helper method
      double totalPaid = _calculateTotalPaid(paymentLines);

      // Customer Opening Balance - Separate Section
      if (openingBalance != null) {
        // Section title
        _drawText(
            canvas,
            'Customer Opening Balance',
            Offset(40, yPos),
            const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black));
        yPos += 30;

        // Opening balance container
        final openingBoxPaint = Paint()
          ..color = Colors.blue.shade50
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(40, yPos, 720, 50),
            const Radius.circular(6),
          ),
          openingBoxPaint,
        );

        final openingBorderPaint = Paint()
          ..color = Colors.blue.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(40, yPos, 720, 50),
            const Radius.circular(6),
          ),
          openingBorderPaint,
        );

        _drawText(canvas, 'Opening Balance:', Offset(60, yPos + 15),
            const TextStyle(fontSize: 14, color: Colors.black87));

        _drawText(
            canvas,
            openingBalance >= 0
                ? 'Credit: Rs ${_currencyFormat.format(openingBalance.abs())}'
                : 'Due: Rs ${_currencyFormat.format(openingBalance.abs())}',
            Offset(500, yPos + 15),
            const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black));

        yPos += 80; // Space after opening balance
      }

      // Payment Summary - Separate Section
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

      // Total Amount - use calculated subtotal instead of stored grandTotal for accuracy
      final calculatedTotal =
          subTotal; // Use calculated subtotal from line items
      print(
          'Using calculated total: $calculatedTotal vs stored grandTotal: ${invoice.grandTotal}');

      _drawText(canvas, 'Total Amount:', Offset(60, yPos),
          const TextStyle(fontSize: 14, color: Colors.black87));
      _drawText(
          canvas,
          'Rs ${_currencyFormat.format(calculatedTotal)}',
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

      // Balance Amount - use calculated total for accurate balance
      final due = calculatedTotal - totalPaid;
      print('Balance calculation: $calculatedTotal - $totalPaid = $due');
      _drawText(canvas, 'Balance Amount:', Offset(60, yPos),
          const TextStyle(fontSize: 14, color: Colors.black87));
      _drawText(
          canvas,
          due > 0 ? 'Rs ${_currencyFormat.format(due)}' : 'FULLY PAID',
          Offset(600, yPos),
          const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));

      yPos += 40;

      final picture = recorder.endRecording();

      // Add timeout for image conversion operations
      final img = await Future.any([
        picture.toImage(size.width.toInt(), size.height.toInt()),
        Future.delayed(const Duration(seconds: 15), () {
          throw TimeoutException('Image conversion timed out');
        }),
      ]);

      final byteData = await Future.any([
        img.toByteData(format: ui.ImageByteFormat.png),
        Future.delayed(const Duration(seconds: 10), () {
          throw TimeoutException('Image byte data conversion timed out');
        }),
      ]);

      if (byteData == null) {
        throw Exception('Failed to generate image data');
      }

      final imageBytes = byteData.buffer.asUint8List();
      print('Generated image with ${imageBytes.length} bytes');

      // Dispose of resources to prevent memory leaks
      picture.dispose();
      img.dispose();

      return imageBytes;
    } catch (e) {
      print('Error generating invoice image: $e');
      rethrow;
    }
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
    double? customerBalance,
    double? openingBalance,
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
                subtitle: const Text('Share to any app'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Generating invoice image...',
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please wait, this may take a few seconds',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    await _shareAsImage(
                      company,
                      party,
                      invoice,
                      transaction,
                      lineItems,
                      paymentLines,
                      customerBalance,
                      openingBalance,
                    );

                    // Close loading dialog
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    // Close loading dialog if open
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }

                    // Show error dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Sharing Failed'),
                          content: Text(e.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.green[600]),
                title: const Text('Share to WhatsApp'),
                subtitle: const Text('Direct WhatsApp sharing'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Preparing invoice for WhatsApp...',
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please wait, this may take a few seconds',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    await _shareAsImage(
                      company,
                      party,
                      invoice,
                      transaction,
                      lineItems,
                      paymentLines,
                      customerBalance,
                      openingBalance,
                    );

                    // Close loading dialog
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    // Close loading dialog if open
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }

                    // Show error dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('WhatsApp Sharing Failed'),
                          content: Text(e.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
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
    double? customerBalance,
    double? openingBalance,
  ) async {
    try {
      print('Starting image generation for invoice ${transaction.referenceNo}');
      print('Line items count: ${lineItems.length}');

      // Add timeout to prevent hanging during image generation
      final imageBytes = await Future.any([
        generateInvoiceImage(
          company: company,
          party: party,
          invoice: invoice,
          transaction: transaction,
          lineItems: lineItems,
          paymentLines: paymentLines,
          customerBalance: customerBalance,
          openingBalance: openingBalance,
        ),
        Future.delayed(const Duration(seconds: 30), () {
          throw TimeoutException(
              'Invoice image generation timed out after 30 seconds');
        }),
      ]);

      print('Image generated successfully, size: ${imageBytes.length} bytes');

      // Add timeout for file operations
      final tempDir =
          await getTemporaryDirectory().timeout(const Duration(seconds: 5));
      final fileName =
          'invoice_${transaction.referenceNo}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(imageBytes).timeout(const Duration(seconds: 10));
      print('Image saved to: ${file.path}');

      // Add timeout for sharing operation
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '''🧾 Sales Invoice - ${transaction.referenceNo}\n👤 Customer: ${party.name}\n📅 Date: ${_dateFormat.format(invoice.invoiceDate)}\n💰 Amount: Rs ${_currencyFormat.format(invoice.grandTotal)}\n\n📱 Generated by Matrix Accounts''',
      ).timeout(const Duration(seconds: 15));

      print('Image shared successfully');

      // Cleanup temporary file after some delay
      Future.delayed(const Duration(seconds: 30), () {
        try {
          if (file.existsSync()) {
            file.deleteSync();
            print('Temporary file cleaned up: ${file.path}');
          }
        } catch (e) {
          print('Warning: Could not cleanup temporary file: $e');
        }
      });
    } on TimeoutException catch (e) {
      print('Timeout error during invoice sharing: $e');
      throw Exception('Invoice sharing timed out. Please try again.');
    } catch (e) {
      print('Error sharing image: $e');
      // Provide more specific error messages
      String errorMessage = 'Failed to share invoice';
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please check storage permissions.';
      } else if (e.toString().contains('space')) {
        errorMessage = 'Insufficient storage space.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      throw Exception(errorMessage);
    }
  }

  static Future<void> _attachAsImage(
    Company company,
    Party party,
    Invoice invoice,
    Transaction transaction,
    List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
  ) async {
    // Show dialog to select attachment source
    final BuildContext? context = _getCurrentContext();
    if (context == null) {
      print('Error: Unable to get context for dialog');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Attach Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Generated Invoice Image'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _attachGeneratedImage(
                    company,
                    party,
                    invoice,
                    transaction,
                    lineItems,
                    paymentLines,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text('Select from Gallery'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _attachFromGallery(transaction.referenceNo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder, color: Colors.orange),
                title: const Text('Select File'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _attachFromFilePicker(transaction.referenceNo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _attachAsImageWithContext(
    BuildContext context,
    Company company,
    Party party,
    Invoice invoice,
    Transaction transaction,
    List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
  ) async {
    // Show dialog to select attachment source
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Attach Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Generated Invoice Image'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _attachGeneratedImage(
                    company,
                    party,
                    invoice,
                    transaction,
                    lineItems,
                    paymentLines,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text('Select from Gallery'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _attachFromGallery(transaction.referenceNo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder, color: Colors.orange),
                title: const Text('Select File'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _attachFromFilePicker(transaction.referenceNo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _attachGeneratedImage(
    Company company,
    Party party,
    Invoice invoice,
    Transaction transaction,
    List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
  ) async {
    try {
      print(
          'Starting attachment generation for invoice ${transaction.referenceNo}');

      final imageBytes = await generateInvoiceImage(
        company: company,
        party: party,
        invoice: invoice,
        transaction: transaction,
        lineItems: lineItems,
        paymentLines: paymentLines,
      );

      print('Image generated successfully, size: ${imageBytes.length} bytes');

      // Save to documents directory for attachment
      final directory = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory('${directory.path}/invoices');

      // Create invoices directory if it doesn't exist
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      final fileName = 'invoice_${transaction.referenceNo}.png';
      final file = File('${invoicesDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      print('Image saved to: ${file.path}');
      print('Invoice image attached successfully at: ${file.path}');
    } catch (e) {
      print('Error attaching generated image: $e');
      rethrow;
    }
  }

  static Future<void> _attachFromGallery(String referenceNo) async {
    try {
      print('Opening image picker for gallery');
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        print('No image selected from gallery');
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory('${directory.path}/invoices');

      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      // Get file extension
      final fileName =
          'invoice_${referenceNo}_gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destinationPath = '${invoicesDir.path}/$fileName';

      // Copy file to invoices directory
      final File pickedFileObj = File(pickedFile.path);
      await pickedFileObj.copy(destinationPath);

      print('Image attached from gallery to: $destinationPath');
    } catch (e) {
      print('Error attaching image from gallery: $e');
      rethrow;
    }
  }

  static Future<void> _attachFromFilePicker(String referenceNo) async {
    try {
      print('Opening file picker');

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'png'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        print('No file selected');
        return;
      }

      final PlatformFile pickedFile = result.files.first;
      final File sourceFile = File(pickedFile.path!);

      final directory = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory('${directory.path}/invoices');

      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      // Copy file to invoices directory
      final fileName =
          'invoice_${referenceNo}_file_${DateTime.now().millisecondsSinceEpoch}.${pickedFile.extension}';
      final destinationPath = '${invoicesDir.path}/$fileName';

      await sourceFile.copy(destinationPath);

      print('File attached to: $destinationPath');
    } catch (e) {
      print('Error attaching file: $e');
      rethrow;
    }
  }

  static BuildContext? _getCurrentContext() {
    // This is a workaround to get context in a static method
    // In production, consider using a different approach like passing context as parameter
    try {
      final key = GlobalKey<NavigatorState>();
      return key.currentContext;
    } catch (e) {
      return null;
    }
  }

  static void _drawText(
      Canvas canvas, String text, Offset position, TextStyle style) {
    try {
      // Validate inputs
      if (text.isEmpty) {
        print('Warning: Empty text provided to _drawText');
        return;
      }

      final textSpan = TextSpan(text: text, style: style);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.left,
        maxLines: 1, // Prevent multi-line text issues
        ellipsis: '...', // Handle overflow gracefully
      );

      // Add timeout for layout operation
      textPainter.layout(
          minWidth: 0, maxWidth: 800); // Set reasonable max width

      // Enhanced bounds checking with canvas size validation
      if (position.dx >= 0 &&
          position.dy >= 0 &&
          position.dx < 800 &&
          position.dy < 1400) {
        textPainter.paint(canvas, position);
      } else {
        print('Warning: Invalid text position $position for text: "$text"');
      }
    } catch (e) {
      print('Error drawing text "$text" at $position: $e');
      // Don't rethrow - continue with other drawing operations
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

  // Direct share as image method
  static Future<void> shareAsImage({
    required Company company,
    required Party party,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
    double? customerBalance,
    double? openingBalance,
  }) async {
    try {
      await _shareAsImage(company, party, invoice, transaction, lineItems,
          paymentLines, customerBalance, openingBalance);
    } catch (e) {
      print('Error in shareAsImage: $e');
      rethrow; // Let the calling code handle the error display
    }
  }

  // // Direct share as PDF method
  // static Future<void> shareAsPdf({
  //   required Company company,
  //   required Party party,
  //   required Invoice invoice,
  //   required Transaction transaction,
  //   required List<Map<String, dynamic>> lineItems,
  //   List<Map<String, dynamic>>? paymentLines,
  //   double? customerBalance,
  //   double? openingBalance,
  // }) async {
  //   await _shareAsPdf(company, party, invoice, transaction, lineItems,
  //       paymentLines, customerBalance, openingBalance);
  // }
}
