// WhatsApp sharing extensions for invoice generator
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/company_model.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/transaction_model.dart';
import 'invoice_generator.dart';

enum ShareType { general, whatsapp }

class InvoiceSharingExtensions {
  static final _dateFormat = DateFormat('dd MMM, yyyy hh:mm a');
  static final _currencyFormat = NumberFormat('#,##,##0.00');

  // Show progress dialog and handle sharing with better error management
  static Future<void> showProgressAndShare({
    required BuildContext context,
    required Company company,
    required Party party,
    required Invoice invoice,
    required Transaction transaction,
    required List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
    double? customerBalance,
    double? openingBalance,
    required ShareType shareType,
  }) async {
    // Show progress dialog to prevent user interaction during processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  shareType == ShareType.whatsapp
                      ? 'Preparing invoice for WhatsApp...'
                      : 'Generating invoice image...',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please wait, this may take a few seconds',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      if (shareType == ShareType.whatsapp) {
        await shareToWhatsApp(
          company,
          party,
          invoice,
          transaction,
          lineItems,
          paymentLines,
          customerBalance,
          openingBalance,
        );
      } else {
        await InvoiceGenerator.shareAsImage(
          company: company,
          party: party,
          invoice: invoice,
          transaction: transaction,
          lineItems: lineItems,
          paymentLines: paymentLines,
          customerBalance: customerBalance,
          openingBalance: openingBalance,
        );
      }

      // Close progress dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Close progress dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error dialog
      showErrorDialog(context, e.toString());
    }
  }

  // Show error dialog with user-friendly message
  static void showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sharing Failed'),
          content: Text(error),
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

  // WhatsApp-specific sharing method with engine safety fixes
  static Future<void> shareToWhatsApp(
    Company company,
    Party party,
    Invoice invoice,
    Transaction transaction,
    List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
    double? customerBalance,
    double? openingBalance,
  ) async {
    Completer<void>? operationCompleter;
    Timer? timeoutTimer;
    
    try {
      print('Starting WhatsApp sharing for invoice ${transaction.referenceNo}');
      
      // Create operation completer for better control
      operationCompleter = Completer<void>();
      
      // Set aggressive timeout to prevent engine detachment
      timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (!operationCompleter!.isCompleted) {
          operationCompleter.completeError(
            TimeoutException('WhatsApp sharing timed out to prevent app hang')
          );
        }
      });

      // Run image generation in compute isolate to prevent main thread blocking
      final imageBytes = await _generateImageSafely(
        company,
        party, 
        invoice,
        transaction,
        lineItems,
        paymentLines,
        customerBalance,
        openingBalance,
      );

      print('WhatsApp image generated safely, size: ${imageBytes.length} bytes');

      // Quick file operations with minimal timeout
      final tempDir = await getTemporaryDirectory().timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw Exception('File system access timed out')
      );
      
      final fileName = 'Invoice_${transaction.referenceNo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.png';
      final file = File('${tempDir.path}/$fileName');
      
      await file.writeAsBytes(imageBytes).timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('File write timed out')
      );
      
      print('WhatsApp image saved to: ${file.path}');

      // WhatsApp message with simplified formatting to reduce processing
      final whatsappMessage = '''🧾 Sales Invoice
Invoice: ${transaction.referenceNo}
Customer: ${party.name}
Amount: Rs ${_currencyFormat.format(invoice.grandTotal)}

Generated by Matrix Accounts''';

      // Platform channel operation with safety checks
      await _shareWithPlatformSafety(
        file.path,
        whatsappMessage,
        'Invoice ${transaction.referenceNo}'
      );

      print('WhatsApp sharing completed successfully');
      
      // Complete operation before cleanup
      if (!operationCompleter.isCompleted) {
        operationCompleter.complete();
      }
      
      // Immediate cleanup to free memory
      _cleanupFile(file);
      
    } on TimeoutException catch (e) {
      print('WhatsApp sharing timeout: $e');
      throw Exception('WhatsApp sharing timed out to prevent app freeze. Please try again.');
    } catch (e, stackTrace) {
      print('WhatsApp sharing error: $e');
      print('Stack trace: $stackTrace');
      
      // Complete with error if not already completed
      if (operationCompleter != null && !operationCo