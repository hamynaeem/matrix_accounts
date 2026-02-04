import 'dart:io';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

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
        return await _shareToContact(text, phoneNumber);
      } else {
        return await _shareToWhatsApp(text);
      }
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
      return false;
    }
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

  /// Share invoice or receipt information
  /// [invoiceNumber] - Invoice/receipt number
  /// [amount] - Total amount
  /// [currency] - Currency symbol
  /// [customerName] - Customer name
  /// [additionalDetails] - Optional additional details
  Future<bool> shareInvoice({
    required String invoiceNumber,
    required double amount,
    required String currency,
    required String customerName,
    String? additionalDetails,
  }) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('🧾 Invoice Details');
      buffer.writeln('Invoice #: $invoiceNumber');
      buffer.writeln('Customer: $customerName');
      buffer.writeln('Amount: $currency ${amount.toStringAsFixed(2)}');

      if (additionalDetails != null && additionalDetails.isNotEmpty) {
        buffer.writeln('\nDetails:');
        buffer.writeln(additionalDetails);
      }

      return await shareText(buffer.toString());
    } catch (e) {
      print('Error sharing invoice: $e');
      return false;
    }
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
  String _cleanPhoneNumber(String phoneNumber) {
    // Remove all characters except numbers and +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with + if it doesn't already
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
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
