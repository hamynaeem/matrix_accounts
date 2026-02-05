import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/whatsapp_config.dart';

/// Service for WhatsApp integration and sharing functionality
class WhatsAppService {
  // WhatsApp URL schemes for different platforms
  static const String _whatsappUrlScheme = 'whatsapp://';
  static const String _whatsappWebUrl = 'https://web.whatsapp.com/';
  static const String _whatsappApiUrl = 'https://api.whatsapp.com/';

  /// Check if WhatsApp is installed on the device
  /// This is a simplified check that assumes WhatsApp is available
  /// For more accurate detection, add url_launcher dependency
  Future<bool> isWhatsAppInstalled() async {
    try {
      // Simplified check - assumes WhatsApp is available on mobile platforms
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Share text content to WhatsApp
  /// [text] - The text content to share
  /// [phoneNumber] - Optional phone number to send directly to a contact
  Future<bool> shareText(String text, {String? phoneNumber}) async {
    try {
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Try API first, fallback to direct sharing
        return await sendMessageViaAPI(phoneNumber, text) ||
            await _shareToContact(text, phoneNumber);
      } else {
        return await _shareToWhatsApp(text);
      }
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
      return false;
    }
  }

  /// Send message via WhatsApp API
  /// [phoneNumber] - Phone number to send to
  /// [message] - Message content
  Future<bool> sendMessageViaAPI(String phoneNumber, String message) async {
    if (!WhatsAppConfig.enableApiIntegration) {
      return await _openWhatsAppDirectly(phoneNumber, message);
    }

    try {
      final cleanNumber = _cleanPhoneNumber(phoneNumber);

      final response = await http
          .post(
            Uri.parse('${WhatsAppConfig.apiBaseUrl}/v1/send'),
            headers: {
              'X-API-Key': WhatsAppConfig.apiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'to': cleanNumber,
              'message': message,
            }),
          )
          .timeout(Duration(seconds: WhatsAppConfig.apiTimeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('WhatsApp API message sent successfully');
        return true;
      } else {
        print('WhatsApp API Error: ${response.statusCode} - ${response.body}');
        // Fallback to direct WhatsApp opening
        return await _openWhatsAppDirectly(cleanNumber, message);
      }
    } catch (e) {
      print('WhatsApp API Exception: $e');
      // Fallback to direct WhatsApp opening
      return await _openWhatsAppDirectly(
          _cleanPhoneNumber(phoneNumber), message);
    }
  }

  /// Open WhatsApp directly with message
  Future<bool> _openWhatsAppDirectly(String phoneNumber, String message) async {
    try {
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl =
          'https://wa.me/${phoneNumber.replaceAll('+', '')}?text=$encodedMessage';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        // Fallback to share
        await Share.share('$message\n\nContact: $phoneNumber');
        return true;
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      return false;
    }
  }

  /// Extract phone number from text using various patterns
  static String? extractPhoneNumber(String? text) {
    if (text == null || text.isEmpty) return null;

    // Pakistani mobile number patterns and international formats
    final patterns = [
      RegExp(r'\+92[0-9]{10}'), // +92xxxxxxxxxx
      RegExp(r'92[0-9]{10}'), // 92xxxxxxxxxx
      RegExp(r'03[0-9]{9}'), // 03xxxxxxxxx
      RegExp(r'\b[0-9]{11}\b'), // 11 digit numbers
      RegExp(r'\+[0-9]{10,15}'), // International format
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0);
      }
    }

    return null;
  }

  /// Share a file to WhatsApp
  /// [filePath] - Path to the file to share
  /// [text] - Optional text to accompany the file
  Future<bool> shareFile(String filePath, {String? text}) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: text,
        sharePositionOrigin: null,
      );
      return true;
    } catch (e) {
      print('Error sharing file to WhatsApp: $e');
      return false;
    }
  }

  /// Share multiple files to WhatsApp
  /// [filePaths] - List of file paths to share
  /// [text] - Optional text to accompany the files
  Future<bool> shareFiles(List<String> filePaths, {String? text}) async {
    try {
      final files = filePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(
        files,
        text: text,
        sharePositionOrigin: null,
      );
      return true;
    } catch (e) {
      print('Error sharing files to WhatsApp: $e');
      return false;
    }
  }

  /// Share content directly to a WhatsApp contact
  /// [text] - The text content to share
  /// [phoneNumber] - The contact's phone number (with country code, e.g., +1234567890)
  Future<bool> shareToContact(String text, String phoneNumber) async {
    return await _shareToContact(text, phoneNumber);
  }

  /// Open WhatsApp chat with a specific contact
  /// [phoneNumber] - The contact's phone number (with country code)
  /// [prefilledText] - Optional text to prefill in the chat input
  /// Note: For full functionality, add url_launcher dependency
  Future<bool> openChatWithContact(String phoneNumber,
      {String? prefilledText}) async {
    try {
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      String textToShare = prefilledText ?? '';

      if (textToShare.isNotEmpty) {
        textToShare += '\n\nContact: $cleanNumber';
      } else {
        textToShare = 'Contact: $cleanNumber';
      }

      // Use share_plus as fallback
      await Share.share(textToShare, sharePositionOrigin: null);
      return true;
    } catch (e) {
      print('Error opening WhatsApp chat: $e');
      return false;
    }
  }

  /// Open WhatsApp group chat
  /// [groupInviteCode] - The group invite code from WhatsApp link
  /// Note: For full functionality, add url_launcher dependency
  Future<bool> openGroupChat(String groupInviteCode) async {
    try {
      final shareText =
          'Join WhatsApp Group: https://chat.whatsapp.com/$groupInviteCode';
      await Share.share(shareText, sharePositionOrigin: null);
      return true;
    } catch (e) {
      print('Error opening WhatsApp group: $e');
      return false;
    }
  }

  /// Share business card or contact information
  /// [contactName] - Name of the contact
  /// [phoneNumber] - Phone number of the contact
  /// [email] - Optional email address
  /// [organization] - Optional organization/company name
  Future<bool> shareBusinessCard({
    required String contactName,
    required String phoneNumber,
    String? email,
    String? organization,
  }) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('📇 Contact Information');
      buffer.writeln('Name: $contactName');
      buffer.writeln('Phone: $phoneNumber');

      if (email != null && email.isNotEmpty) {
        buffer.writeln('Email: $email');
      }

      if (organization != null && organization.isNotEmpty) {
        buffer.writeln('Company: $organization');
      }

      return await shareText(buffer.toString());
    } catch (e) {
      print('Error sharing business card: $e');
      return false;
    }
  }

  /// Share invoice or receipt information with automatic phone detection
  /// [invoiceNumber] - Invoice/receipt number
  /// [amount] - Total amount
  /// [currency] - Currency symbol
  /// [customerName] - Customer name
  /// [customerPhone] - Customer phone number
  /// [invoiceType] - Type of invoice (Sales/Purchase)
  /// [additionalDetails] - Optional additional details
  Future<bool> shareInvoice({
    required String invoiceNumber,
    required double amount,
    required String currency,
    required String customerName,
    String? customerPhone,
    String? invoiceType,
    String? additionalDetails,
  }) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('🧾 ${invoiceType ?? 'Invoice'} Details');
      buffer.writeln('');
      buffer.writeln('Dear $customerName,');
      buffer.writeln('');
      buffer.writeln('Invoice #: $invoiceNumber');
      buffer.writeln('Amount: $currency ${amount.toStringAsFixed(2)}');

      if (additionalDetails != null && additionalDetails.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('Details:');
        buffer.writeln(additionalDetails);
      }

      buffer.writeln('');
      buffer.writeln('Thank you for your business!');
      buffer.writeln('');
      buffer.writeln('Best regards,');
      buffer.writeln('Matrix Accounts');

      final message = buffer.toString();

      // Try to extract phone number from customer data
      String? phoneNumber = customerPhone;
      if (phoneNumber == null || phoneNumber.isEmpty) {
        // Try to extract from customer name or additional details
        phoneNumber = extractPhoneNumber(customerName) ??
            extractPhoneNumber(additionalDetails);
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        print('Sending invoice via WhatsApp to: $phoneNumber');
        return await shareText(message, phoneNumber: phoneNumber);
      } else {
        print('No phone number found, using regular share');
        return await shareText(message);
      }
    } catch (e) {
      print('Error sharing invoice: $e');
      return false;
    }
  }

  /// Share invoice with auto-detected phone number from party data
  /// [invoiceData] - Map containing invoice information
  Future<bool> shareInvoiceAuto(Map<String, dynamic> invoiceData) async {
    return await shareInvoice(
      invoiceNumber: invoiceData['invoiceNumber'] ?? '',
      amount: invoiceData['amount']?.toDouble() ?? 0.0,
      currency: invoiceData['currency'] ?? 'Rs',
      customerName: invoiceData['customerName'] ?? 'Customer',
      customerPhone: invoiceData['customerPhone'],
      invoiceType: invoiceData['invoiceType'],
      additionalDetails: invoiceData['additionalDetails'],
    );
  }

  /// Internal method to share content to WhatsApp
  Future<bool> _shareToWhatsApp(String text) async {
    try {
      await Share.share(text, sharePositionOrigin: null);
      return true;
    } catch (e) {
      print('Error in _shareToWhatsApp: $e');
      return false;
    }
  }

  /// Internal method to share content to a specific WhatsApp contact
  Future<bool> _shareToContact(String text, String phoneNumber) async {
    try {
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      final shareText = '$text\n\nContact: $cleanNumber';

      // Use share_plus to share the content
      await Share.share(shareText, sharePositionOrigin: null);
      return true;
    } catch (e) {
      print('Error in _shareToContact: $e');
      return false;
    }
  }

  /// Clean phone number by removing non-numeric characters except +
  /// Handles Pakistani phone number formats specifically
  String _cleanPhoneNumber(String phoneNumber) {
    // Remove all characters except numbers and +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Handle Pakistani numbers specifically (or use configured country code)
    final countryCode = WhatsAppConfig.defaultCountryCode.replaceAll('+', '');

    if (cleaned.startsWith('03')) {
      // Convert 03xxxxxxxxx to +92xxxxxxxxx (Pakistani format)
      cleaned = '+$countryCode${cleaned.substring(1)}';
    } else if (cleaned.startsWith(countryCode) &&
        !cleaned.startsWith('+$countryCode')) {
      // Add + if missing
      cleaned = '+$cleaned';
    } else if (!cleaned.startsWith('+')) {
      // If no country code, assume Pakistani
      if (cleaned.length == 11 && cleaned.startsWith('03')) {
        cleaned = '+$countryCode${cleaned.substring(1)}';
      } else if (cleaned.length == 10) {
        cleaned = '+$countryCode$cleaned';
      } else {
        cleaned = '+$cleaned';
      }
    }

    return cleaned;
  }

  /// Generate a WhatsApp sharing URL for web sharing
  /// [text] - The text to share
  /// [phoneNumber] - Optional phone number
  String generateWhatsAppUrl(String text, {String? phoneNumber}) {
    final encodedText = Uri.encodeComponent(text);

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      return '${_whatsappApiUrl}send?phone=$cleanNumber&text=$encodedText';
    } else {
      return '${_whatsappApiUrl}send?text=$encodedText';
    }
  }

  /// Copy WhatsApp sharing URL to clipboard
  /// [text] - The text to share
  /// [phoneNumber] - Optional phone number
  Future<bool> copyWhatsAppUrlToClipboard(String text,
      {String? phoneNumber}) async {
    try {
      final url = generateWhatsAppUrl(text, phoneNumber: phoneNumber);
      await Clipboard.setData(ClipboardData(text: url));
      return true;
    } catch (e) {
      print('Error copying WhatsApp URL to clipboard: $e');
      return false;
    }
  }
}
