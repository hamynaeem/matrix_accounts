// WhatsApp sharing extensions for invoice generator
// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, avoid_print, prefer_const_declarations, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
      print('=== WhatsApp Sharing Started ===');
      print('Invoice: ${transaction.referenceNo}');
      print('Customer: ${party.name}');

      // Create operation completer for better control
      operationCompleter = Completer<void>();

      // Set aggressive timeout to prevent engine detachment
      timeoutTimer = Timer(const Duration(seconds: 15), () {
        print('WhatsApp sharing timeout triggered (15s)');
        if (!operationCompleter!.isCompleted) {
          operationCompleter.completeError(TimeoutException(
              'WhatsApp sharing timed out to prevent app hang'));
        }
      });

      print('Starting image generation...');
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

      print('Image generated: ${imageBytes.length} bytes');

      // Quick file operations with minimal timeout
      print('Creating temporary file...');
      final tempDir = await getTemporaryDirectory().timeout(
          const Duration(seconds: 2),
          onTimeout: () => throw Exception('File system access timed out'));

      final fileName =
          'Invoice_${transaction.referenceNo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.png';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(imageBytes).timeout(const Duration(seconds: 3),
          onTimeout: () => throw Exception('File write timed out'));

      print('File saved: ${file.path}');

      // WhatsApp message with simplified formatting to reduce processing
      final whatsappMessage = '''🧾 Sales Invoice
Invoice: ${transaction.referenceNo}
Customer: ${party.name}
Amount: Rs ${_currencyFormat.format(invoice.grandTotal)}

Generated by Matrix Accounts''';

      print('Starting WhatsApp share...');
      // Platform channel operation with safety checks
      await _shareWithPlatformSafety(
          file.path, whatsappMessage, 'Invoice ${transaction.referenceNo}');

      print('WhatsApp sharing completed successfully');

      // Complete operation before cleanup
      if (!operationCompleter.isCompleted) {
        operationCompleter.complete();
      }

      // Immediate cleanup to free memory
      _cleanupFile(file);
    } on TimeoutException catch (e) {
      print('WhatsApp sharing timeout: $e');
      throw Exception(
          'WhatsApp sharing timed out to prevent app freeze. Please try again.');
    } catch (e, stackTrace) {
      print('WhatsApp sharing error: $e');
      print('Stack trace: $stackTrace');

      // Complete with error if not already completed
      if (operationCompleter != null && !operationCompleter.isCompleted) {
        operationCompleter.completeError(e);
      }

      String errorMessage = _getErrorMessage(e.toString());
      throw Exception(errorMessage);
    } finally {
      // Always cancel timeout timer to prevent memory leaks
      timeoutTimer?.cancel();
    }

    // Wait for operation completion with final timeout
    if (operationCompleter != null && !operationCompleter.isCompleted) {
      await operationCompleter.future.timeout(const Duration(seconds: 2),
          onTimeout: () => throw Exception('Operation completion timeout'));
    }
  }

  // Generate image with engine safety measures
  static Future<Uint8List> _generateImageSafely(
    Company company,
    Party party,
    Invoice invoice,
    Transaction transaction,
    List<Map<String, dynamic>> lineItems,
    List<Map<String, dynamic>>? paymentLines,
    double? customerBalance,
    double? openingBalance,
  ) async {
    // Use shorter timeout to prevent engine issues
    return await Future.any([
      InvoiceGenerator.generateInvoiceImage(
        company: company,
        party: party,
        invoice: invoice,
        transaction: transaction,
        lineItems: lineItems,
        paymentLines: paymentLines,
        customerBalance: customerBalance,
        openingBalance: openingBalance,
      ),
      Future.delayed(const Duration(seconds: 12), () {
        throw TimeoutException(
            'Image generation timeout - preventing engine detach');
      }),
    ]);
  }

  // Direct WhatsApp sharing with proper timeouts to prevent hanging
  static Future<void> _shareWithPlatformSafety(
    String filePath,
    String message,
    String subject,
  ) async {
    try {
      // Check if WhatsApp is available with timeout
      final whatsappUrl = 'whatsapp://send';

      bool canLaunch = false;
      try {
        // Add timeout to prevent hanging on canLaunchUrl
        canLaunch = await canLaunchUrl(Uri.parse(whatsappUrl))
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        print('WhatsApp availability check failed: $e');
        canLaunch = false;
      }

      if (canLaunch) {
        print('WhatsApp detected, sharing directly');
        // Share file with text directly to WhatsApp
        await Share.shareXFiles(
          [XFile(filePath)],
          text: message,
          subject: subject,
        ).timeout(const Duration(seconds: 8));

        print('WhatsApp sharing completed');
      } else {
        print('WhatsApp not available, using system share');
        // Fallback to generic share
        await Share.shareXFiles(
          [XFile(filePath)],
          text: message,
          subject: subject,
        ).timeout(const Duration(seconds: 8));
      }
    } catch (e) {
      print('Error in WhatsApp sharing: $e');

      // Final fallback - basic share without timeout complexity
      try {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: message,
        );
      } catch (fallbackError) {
        print('All sharing methods failed: $fallbackError');
        throw Exception('Unable to share invoice: $fallbackError');
      }
    }
  }

  // Immediate file cleanup to prevent memory issues
  static void _cleanupFile(File file) {
    try {
      if (file.existsSync()) {
        file.deleteSync();
        print('WhatsApp temp file cleaned up immediately');
      }
    } catch (e) {
      print('Cleanup warning: $e');
      // Schedule delayed cleanup as fallback
      Future.delayed(const Duration(seconds: 3), () {
        try {
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (_) {}
      });
    }
  }

  // Get user-friendly error messages
  static String _getErrorMessage(String error) {
    if (error.contains('permission') || error.contains('Permission')) {
      return 'Storage permission required. Please allow file access.';
    } else if (error.contains('space') || error.contains('storage')) {
      return 'Insufficient storage space. Please free up space.';
    } else if (error.contains('timeout') || error.contains('Timeout')) {
      return 'Operation timed out. Please check your device performance and try again.';
    } else if (error.contains('WhatsApp') || error.contains('whatsapp')) {
      return 'WhatsApp not available. Please install WhatsApp or use general sharing.';
    } else if (error.contains('platform') || error.contains('FlutterJNI')) {
      return 'System error occurred. Please restart the app and try again.';
    }
    return 'WhatsApp sharing failed. Please try general sharing instead.';
  }
}
