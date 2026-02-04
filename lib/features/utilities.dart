// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

// Export commonly used utilities for easy access
export 'package:intl/intl.dart' show DateFormat, NumberFormat;

/// Comprehensive utilities for the Matrix Accounts application
/// Contains helper functions for formatting, validation, calculations, and common operations

/// Route constants for navigation
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String company = '/company';
  static const String dashboard = '/dashboard';
  static const String sales = '/sales';
  static const String purchases = '/purchases';
  static const String expenses = '/expenses';
  static const String settings = '/settings';
  static const String companySettings = '/settings/company';
  static const String themeSettings = '/settings/theme';
  static const String languageSettings = '/settings/language';
  static const String stockReport = '/reports/stock';
  static const String profitReport = '/reports/profit';
  static const String balanceSheet = '/reports/balance-sheet';
  static const String cashflow = '/reports/cashflow';
  static const String daybook = '/reports/daybook';
}

/// Utility class for breadcrumb generation
class BreadcrumbUtils {
  static String getRouteName(String route) {
    switch (route) {
      case '/dashboard':
        return 'Dashboard';
      case '/sales':
        return 'Sales';
      case '/purchases':
        return 'Purchases';
      case '/expenses':
        return 'Expenses';
      case '/settings':
        return 'Settings';
      case '/reports/stock':
        return 'Stock Report';
      case '/reports/profit':
        return 'Profit Report';
      case '/reports/balance-sheet':
        return 'Balance Sheet';
      case '/reports/cashflow':
        return 'Cash Flow';
      case '/reports/daybook':
        return 'Daybook';
      default:
        return route.replaceAll('/', ' ').trim();
    }
  }

  static List<String> generateBreadcrumb(String route) {
    final parts = route.split('/').where((part) => part.isNotEmpty).toList();
    final breadcrumbs = <String>[];
    String currentPath = '';
    for (final part in parts) {
      currentPath += '/$part';
      breadcrumbs.add(getRouteName(currentPath));
    }
    return breadcrumbs;
  }
}

/// Route validator utility
class RouteValidator {
  static bool isValidRoute(String route) {
    const validRoutes = [
      '/splash',
      '/login',
      '/company',
      '/dashboard',
      '/sales',
      '/purchases',
      '/expenses',
      '/settings',
      '/reports/stock',
      '/reports/profit',
    ];
    return validRoutes.contains(route) ||
        route.startsWith('/') && route.length > 1;
  }
}

class AppUtilities {
  // Private constructor to prevent instantiation
  AppUtilities._();

  // ===========================================================================
  // FORMATTING UTILITIES
  // ===========================================================================

  /// Currency formatter for Pakistani Rupees
  static final NumberFormat currencyPKR = NumberFormat.currency(
    symbol: 'PKR ',
    decimalDigits: 2,
    locale: 'en_PK',
  );

  /// Currency formatter for Rupees (generic)
  static final NumberFormat currencyRs = NumberFormat.currency(
    symbol: 'Rs ',
    decimalDigits: 2,
  );

  /// Number formatter for quantities with 2 decimal places
  static final NumberFormat quantityFormat = NumberFormat('#,##0.00');

  /// Number formatter for quantities without decimals
  static final NumberFormat wholeNumberFormat = NumberFormat('#,##0');

  /// Percentage formatter
  static final NumberFormat percentageFormat = NumberFormat('#0.00%');

  /// Date formatter for display (dd MMM yyyy)
  static final DateFormat displayDateFormat = DateFormat('dd MMM yyyy');

  /// Date formatter with time (dd MMM, yyyy hh:mm a)
  static final DateFormat dateTimeFormat = DateFormat('dd MMM, yyyy hh:mm a');

  /// Date formatter for file names (yyyy-MM-dd)
  static final DateFormat filenameDateFormat = DateFormat('yyyy-MM-dd');

  /// Time formatter (hh:mm a)
  static final DateFormat timeFormat = DateFormat('hh:mm a');

  /// Format currency amount with symbol and locale support
  static String formatCurrency(double amount,
      {String symbol = 'PKR ', String? locale}) {
    try {
      return NumberFormat.currency(
        symbol: symbol,
        decimalDigits: 2,
        locale: locale ?? 'en_PK',
      ).format(amount);
    } catch (e) {
      // Fallback formatting
      return '$symbol${quantityFormat.format(amount)}';
    }
  }

  /// Format currency for different supported currencies
  static String formatCurrencyByType(double amount, String currencyType) {
    switch (currencyType.toUpperCase()) {
      case 'PKR':
        return formatCurrency(amount, symbol: 'PKR ');
      case 'USD':
        return formatCurrency(amount, symbol: '\$', locale: 'en_US');
      case 'EUR':
        return formatCurrency(amount, symbol: '€', locale: 'en_EU');
      case 'GBP':
        return formatCurrency(amount, symbol: '£', locale: 'en_GB');
      case 'RS':
      default:
        return formatCurrency(amount, symbol: 'Rs ');
    }
  }

  /// Format number as percentage
  static String formatPercentage(double value) {
    return percentageFormat.format(value / 100);
  }

  /// Format quantity with appropriate decimal places
  static String formatQuantity(double quantity, {int? decimalPlaces}) {
    if (decimalPlaces != null) {
      return NumberFormat('#,##0.${'0' * decimalPlaces}').format(quantity);
    }
    // Auto-detect if decimal places are needed
    if (quantity == quantity.roundToDouble()) {
      return wholeNumberFormat.format(quantity);
    }
    return quantityFormat.format(quantity);
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return displayDateFormat.format(date);
  }

  /// Format date with time
  static String formatDateTime(DateTime dateTime) {
    return dateTimeFormat.format(dateTime);
  }

  /// Format file-safe date
  static String formatFilenameDate(DateTime date) {
    return filenameDateFormat.format(date);
  }

  // ===========================================================================
  // VALIDATION UTILITIES
  // ===========================================================================

  /// Validate email address
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate Pakistani phone number
  static bool isValidPakistaniPhone(String phone) {
    // Remove spaces and special characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Pakistani mobile numbers: 03xxxxxxxxx or +923xxxxxxxxx
    return RegExp(r'^(\+92|0)?3[0-9]{9}$').hasMatch(cleanPhone);
  }

  /// Validate CNIC (Pakistani National ID)
  static bool isValidCNIC(String cnic) {
    // CNIC format: 12345-6789012-3
    return RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(cnic);
  }

  /// Validate positive number
  static bool isPositiveNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0;
  }

  /// Validate non-negative number
  static bool isNonNegativeNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number >= 0;
  }

  /// Validate percentage (0-100)
  static bool isValidPercentage(String value) {
    final number = double.tryParse(value);
    return number != null && number >= 0 && number <= 100;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate email field
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate phone field
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (!isValidPakistaniPhone(value)) {
      return 'Please enter a valid Pakistani phone number';
    }
    return null;
  }

  /// Validate amount field
  static String? validateAmount(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Amount is required' : null;
    }
    if (!isNonNegativeNumber(value)) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  // ===========================================================================
  // CALCULATION UTILITIES
  // ===========================================================================

  /// Calculate percentage of a value
  static double calculatePercentage(double value, double percentage) {
    return value * (percentage / 100);
  }

  /// Calculate discount amount
  static double calculateDiscount(
      double amount, double discount, bool isPercentage) {
    if (isPercentage) {
      return calculatePercentage(amount, discount);
    }
    return discount;
  }

  /// Calculate tax amount
  static double calculateTax(double taxableAmount, double taxRate) {
    return calculatePercentage(taxableAmount, taxRate);
  }

  /// Calculate line total (quantity * rate)
  static double calculateLineTotal(double quantity, double rate) {
    return quantity * rate;
  }

  /// Calculate net amount after discount
  static double calculateNetAmount(double grossAmount, double discountAmount) {
    return grossAmount - discountAmount;
  }

  /// Calculate total with tax
  static double calculateTotalWithTax(double amount, double taxAmount) {
    return amount + taxAmount;
  }

  /// Calculate profit margin
  static double calculateProfitMargin(double sellingPrice, double costPrice) {
    if (sellingPrice == 0) return 0;
    return ((sellingPrice - costPrice) / sellingPrice) * 100;
  }

  /// Calculate markup percentage
  static double calculateMarkup(double sellingPrice, double costPrice) {
    if (costPrice == 0) return 0;
    return ((sellingPrice - costPrice) / costPrice) * 100;
  }

  /// Round to specified decimal places
  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    final multiplier = math.pow(10, decimalPlaces);
    return (value * multiplier).round() / multiplier;
  }

  /// Sum a list of amounts
  static double sumAmounts(List<double> amounts) {
    return amounts.fold(0.0, (sum, amount) => sum + amount);
  }

  // ===========================================================================
  // DATE UTILITIES
  // ===========================================================================

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get financial year start (assuming April as start month)
  static DateTime getFinancialYearStart(DateTime date, {int startMonth = 4}) {
    if (date.month >= startMonth) {
      return DateTime(date.year, startMonth, 1);
    } else {
      return DateTime(date.year - 1, startMonth, 1);
    }
  }

  /// Get financial year end
  static DateTime getFinancialYearEnd(DateTime date, {int startMonth = 4}) {
    final fyStart = getFinancialYearStart(date, startMonth: startMonth);
    return DateTime(fyStart.year + 1, startMonth, 0, 23, 59, 59, 999);
  }

  /// Calculate age in years
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Calculate days between dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // ===========================================================================
  // STRING UTILITIES
  // ===========================================================================

  /// Capitalize first letter of each word
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Remove extra spaces and trim
  static String cleanString(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Generate random string with specified length
  static String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  /// Generate invoice/voucher number
  static String generateVoucherNumber(String prefix, int serialNumber,
      {int padLength = 4}) {
    return '$prefix${serialNumber.toString().padLeft(padLength, '0')}';
  }

  /// Extract numeric value from string
  static double? extractNumericValue(String text) {
    final numericRegex = RegExp(r'[\d.]+');
    final match = numericRegex.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(0)!);
    }
    return null;
  }

  /// Convert number to words (for check writing)
  static String numberToWords(double number) {
    // Basic implementation for Pakistani Rupees
    final rupees = number.floor();
    final paisa = ((number - rupees) * 100).round();

    if (rupees == 0 && paisa == 0) return 'Zero';

    String result = '';
    if (rupees > 0) {
      result += '${_numberToWordsHelper(rupees)} Rupee${rupees > 1 ? 's' : ''}';
    }
    if (paisa > 0) {
      if (result.isNotEmpty) result += ' and ';
      result += '${_numberToWordsHelper(paisa)} Paisa';
    }
    return result;
  }

  static String _numberToWordsHelper(int number) {
    // Simplified implementation - you can expand this
    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine'
    ];
    const teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    if (number == 0) return '';
    if (number < 10) return ones[number];
    if (number < 20) return teens[number - 10];
    if (number < 100) {
      return '${tens[number ~/ 10]}${ones[number % 10].isNotEmpty ? ' ${ones[number % 10]}' : ''}';
    }
    if (number < 1000) {
      return '${ones[number ~/ 100]} Hundred${number % 100 != 0 ? ' ${_numberToWordsHelper(number % 100)}' : ''}';
    }

    // Add more cases for thousands, lakhs, crores as needed
    return number.toString(); // Fallback
  }

  // ===========================================================================
  // FILE AND STORAGE UTILITIES
  // ===========================================================================

  /// Get app documents directory
  static Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get temporary directory
  static Future<Directory> getAppTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Generate unique filename
  static String generateUniqueFilename(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.$extension';
  }

  /// Get file size in human readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Share file
  static Future<void> shareFile(String filePath, String subject) async {
    await Share.shareXFiles([XFile(filePath)], subject: subject);
  }

  /// Share text
  static Future<void> shareText(String text, String subject) async {
    await Share.share(text, subject: subject);
  }

  // ===========================================================================
  // UI UTILITIES
  // ===========================================================================

  /// Show snack bar with success message
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show snack bar with error message
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context,
      {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  /// Get theme colors based on amount (positive/negative)
  static Color getAmountColor(double amount) {
    if (amount > 0) return Colors.green;
    if (amount < 0) return Colors.red;
    return Colors.grey;
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'active':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
      case 'inactive':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // ===========================================================================
  // DEVICE UTILITIES
  // ===========================================================================

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.shortestSide >= 600;
  }

  /// Get device orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Vibrate device
  static Future<void> vibrate() async {
    await HapticFeedback.mediumImpact();
  }

  /// Copy to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // ===========================================================================
  // BUSINESS LOGIC UTILITIES
  // ===========================================================================

  /// Calculate due date from invoice date and payment terms
  static DateTime calculateDueDate(DateTime invoiceDate, int paymentTermsDays) {
    return invoiceDate.add(Duration(days: paymentTermsDays));
  }

  /// Check if payment is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  /// Calculate days overdue
  static int daysOverdue(DateTime dueDate) {
    if (!isOverdue(dueDate)) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  /// Get payment status based on amounts
  static String getPaymentStatus(double totalAmount, double paidAmount) {
    if (paidAmount == 0) return 'Unpaid';
    if (paidAmount >= totalAmount) return 'Paid';
    return 'Partial';
  }

  /// Calculate outstanding balance
  static double calculateOutstandingBalance(
      double totalAmount, double paidAmount) {
    return math.max(0, totalAmount - paidAmount);
  }

  /// Generate barcode/QR code data
  static String generateBarcodeData(String type, String number, double amount) {
    return '$type:$number:${amount.toStringAsFixed(2)}:${DateTime.now().millisecondsSinceEpoch}';
  }

  // ===========================================================================
  // REPORT UTILITIES
  // ===========================================================================

  /// Get date range display text
  static String getDateRangeText(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return 'All Time';
    if (startDate == null) return 'Up to ${formatDate(endDate!)}';
    if (endDate == null) return 'From ${formatDate(startDate)}';
    if (startDate == endDate) return formatDate(startDate);
    return '${formatDate(startDate)} - ${formatDate(endDate)}';
  }

  /// Get period name for reports
  static String getPeriodName(DateTime startDate, DateTime endDate) {
    final start = startOfDay(startDate);
    final end = endOfDay(endDate);
    final now = DateTime.now();

    if (isToday(start) && isToday(end)) return 'Today';
    if (isYesterday(start) && isYesterday(end)) return 'Yesterday';

    // Check if it's current month
    final currentMonthStart = startOfMonth(now);
    final currentMonthEnd = endOfMonth(now);
    if (start == currentMonthStart && end.day == currentMonthEnd.day) {
      return DateFormat('MMMM yyyy').format(now);
    }

    // Check if it's current financial year
    final fyStart = getFinancialYearStart(now);
    final fyEnd = getFinancialYearEnd(now);
    if (start == fyStart && end.day == fyEnd.day) {
      return 'FY ${fyStart.year}-${fyEnd.year}';
    }

    return getDateRangeText(startDate, endDate);
  }

  // ===========================================================================
  // ROUTE AND NAVIGATION UTILITIES
  // ===========================================================================

  /// Navigate to dashboard
  static void goToDashboard(BuildContext context) {
    context.go(AppRoutes.dashboard);
  }

  /// Navigate to specific screen with parameters
  static void navigateToScreen(BuildContext context, String route,
      {Map<String, String>? queryParams}) {
    if (queryParams != null && queryParams.isNotEmpty) {
      final uri = Uri.parse(route).replace(queryParameters: queryParams);
      context.go(uri.toString());
    } else {
      context.go(route);
    }
  }

  /// Navigate to form screen with ID
  static void navigateToForm(BuildContext context, String baseRoute,
      {int? id, Map<String, String>? additionalParams}) {
    final params = <String, String>{};
    if (id != null) params['id'] = id.toString();
    if (additionalParams != null) params.addAll(additionalParams);

    navigateToScreen(context, baseRoute, queryParams: params);
  }

  /// Safe back navigation with fallback
  static void goBack(BuildContext context, {String? fallbackRoute}) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute ?? AppRoutes.dashboard);
    }
  }

  /// Navigate with confirmation dialog
  static Future<void> navigateWithConfirmation(
    BuildContext context,
    String route, {
    String title = 'Navigate Away',
    String message = 'Are you sure you want to leave this page?',
    Map<String, String>? queryParams,
  }) async {
    final shouldNavigate = await showConfirmationDialog(
      context,
      title: title,
      message: message,
    );

    if (shouldNavigate) {
      navigateToScreen(context, route, queryParams: queryParams);
    }
  }

  /// Get current route name for breadcrumbs
  static String getCurrentRouteName(BuildContext context) {
    final location = GoRouterState.of(context).fullPath;
    return BreadcrumbUtils.getRouteName(location ?? '');
  }

  /// Generate breadcrumb trail
  static List<String> getBreadcrumbTrail(BuildContext context) {
    final location = GoRouterState.of(context).fullPath;
    if (location == null) return [];
    return BreadcrumbUtils.generateBreadcrumb(location);
  }

  /// Check if current route matches pattern
  static bool isCurrentRoute(BuildContext context, String routePattern) {
    final location = GoRouterState.of(context).fullPath;
    return location?.startsWith(routePattern) ?? false;
  }

  /// Navigate to settings with specific section
  static void navigateToSettings(BuildContext context, {String? section}) {
    String route = AppRoutes.settings;
    if (section != null) {
      switch (section.toLowerCase()) {
        case 'company':
          route = AppRoutes.companySettings;
          break;
        case 'theme':
          route = AppRoutes.themeSettings;
          break;
        case 'language':
          route = AppRoutes.languageSettings;
          break;
        default:
          route = AppRoutes.settings;
      }
    }
    context.go(route);
  }

  /// Navigate to reports with date range
  static void navigateToReport(BuildContext context, String reportType,
      {DateTime? startDate, DateTime? endDate}) {
    final params = <String, String>{};
    if (startDate != null) {
      params['start'] = filenameDateFormat.format(startDate);
    }
    if (endDate != null) {
      params['end'] = filenameDateFormat.format(endDate);
    }

    String route;
    switch (reportType.toLowerCase()) {
      case 'stock':
        route = AppRoutes.stockReport;
        break;
      case 'profit':
        route = AppRoutes.profitReport;
        break;
      case 'balance':
        route = AppRoutes.balanceSheet;
        break;
      case 'cashflow':
        route = AppRoutes.cashflow;
        break;
      default:
        route = AppRoutes.daybook;
    }

    navigateToScreen(context, route, queryParams: params);
  }

  /// Navigate to transaction form (sales, purchase, etc.)
  static void navigateToTransactionForm(BuildContext context, String type,
      {int? id}) {
    final Map<String, String> params = {};
    if (id != null) params['id'] = id.toString();

    switch (type.toLowerCase()) {
      case 'sales':
      case 'invoice':
        final uri =
            Uri.parse('/sales/invoice/form').replace(queryParameters: params);
        context.go(uri.toString());
        break;
      case 'purchase':
        final uri = Uri.parse('/purchases/invoice/form')
            .replace(queryParameters: params);
        context.go(uri.toString());
        break;
      case 'expense':
        final uri =
            Uri.parse('/expenses/form').replace(queryParameters: params);
        context.go(uri.toString());
        break;
      default:
        navigateToForm(context, '/transactions/form', id: id);
    }
  }

  // ===========================================================================
  // CONSTANTS AND ENUMS
  // ===========================================================================

  /// Pakistani tax rates
  static const double gstRate = 17.0; // General Sales Tax
  static const double salesTaxRate = 17.0; // Provincial Sales Tax
  static const double incomeTaxRate = 1.0; // Advance tax on services
  static const double withholdingTaxRate = 10.0; // Withholding tax
  static const double zakatRate = 2.5; // Zakat rate

  /// Pakistani business constants
  static const double nisabAmountPKR = 87000; // Zakat nisab in PKR (approx)
  static const List<String> pakistaniCities = [
    'Karachi',
    'Lahore',
    'Faisalabad',
    'Rawalpindi',
    'Gujranwala',
    'Peshawar',
    'Multan',
    'Hyderabad',
    'Islamabad',
    'Quetta'
  ];

  /// Payment methods common in Pakistan
  static const List<String> paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Cheque',
    'Online Banking',
    'JazzCash',
    'EasyPaisa',
    'Credit Card',
    'Debit Card'
  ];

  /// Common Pakistani bank names
  static const List<String> pakistaniBanks = [
    'Habib Bank Limited (HBL)',
    'United Bank Limited (UBL)',
    'Muslim Commercial Bank (MCB)',
    'Allied Bank Limited (ABL)',
    'Standard Chartered Bank',
    'National Bank of Pakistan',
    'Bank Alfalah',
    'Askari Bank',
    'Faysal Bank',
    'Meezan Bank'
  ];

  /// Payment terms in days
  static const List<int> commonPaymentTerms = [0, 7, 15, 30, 45, 60, 90];

  /// Common currencies with symbols
  static const Map<String, String> supportedCurrencies = {
    'PKR': 'PKR ',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'RS': 'Rs ',
  };

  /// Financial year months (Pakistan follows April-March)
  static const int financialYearStartMonth = 4; // April
  static const int financialYearEndMonth = 3; // March

  /// Common invoice/voucher prefixes
  static const Map<String, String> voucherPrefixes = {
    'sales': 'SI',
    'purchase': 'PI',
    'payment': 'PV',
    'receipt': 'RV',
    'journal': 'JV',
    'credit_note': 'CN',
    'debit_note': 'DN',
  };

  /// File extensions for exports
  static const Map<String, String> fileExtensions = {
    'pdf': '.pdf',
    'excel': '.xlsx',
    'csv': '.csv',
    'image': '.png',
    'backup': '.bak',
    'json': '.json',
  };

  /// App-specific constants
  static const String appVersion = '1.0.0';
  static const String companyName = 'Matrix Accounts';
  static const String supportEmail = 'support@matrixaccounts.com';
  static const String websiteUrl = 'https://matrixaccounts.com';
}

/// Extension methods for common operations
extension DoubleExtensions on double {
  /// Round to 2 decimal places
  double get rounded2 => AppUtilities.roundToDecimalPlaces(this, 2);

  /// Format as currency
  String get toCurrency => AppUtilities.formatCurrency(this);

  /// Format as percentage
  String get toPercentage => AppUtilities.formatPercentage(this);

  /// Check if positive
  bool get isPositive => this > 0;

  /// Check if negative
  bool get isNegative => this < 0;

  /// Check if zero
  bool get isZero => this == 0;
}

extension DateTimeExtensions on DateTime {
  /// Format for display
  String get toDisplayString => AppUtilities.formatDate(this);

  /// Format with time
  String get toDateTimeString => AppUtilities.formatDateTime(this);

  /// Check if today
  bool get isToday => AppUtilities.isToday(this);

  /// Check if yesterday
  bool get isYesterday => AppUtilities.isYesterday(this);

  /// Get start of day
  DateTime get startOfDay => AppUtilities.startOfDay(this);

  /// Get end of day
  DateTime get endOfDay => AppUtilities.endOfDay(this);
}

extension StringExtensions on String {
  /// Capitalize first letter
  String get toTitleCase => AppUtilities.toTitleCase(this);

  /// Clean extra spaces
  String get cleaned => AppUtilities.cleanString(this);

  /// Check if valid email
  bool get isValidEmail => AppUtilities.isValidEmail(this);

  /// Check if valid phone
  bool get isValidPhone => AppUtilities.isValidPakistaniPhone(this);

  /// Extract numeric value
  double? get numericValue => AppUtilities.extractNumericValue(this);

  /// Check if string is a valid route
  bool get isValidRoute => RouteValidator.isValidRoute(this);

  /// Get human-readable route name
  String get routeName => BreadcrumbUtils.getRouteName(this);
}

/// Extension methods for BuildContext navigation
extension ContextNavigationExtensions on BuildContext {
  /// Quick navigation to common screens
  void navigateToDashboard() => AppUtilities.goToDashboard(this);
  void navigateToSettings({String? section}) =>
      AppUtilities.navigateToSettings(this, section: section);
  void navigateToReport(String type, {DateTime? start, DateTime? end}) =>
      AppUtilities.navigateToReport(this, type, startDate: start, endDate: end);

  /// Safe back navigation
  void goBackSafely({String? fallback}) =>
      AppUtilities.goBack(this, fallbackRoute: fallback);

  /// Get current route information
  String get currentRouteName => AppUtilities.getCurrentRouteName(this);
  List<String> get breadcrumbTrail => AppUtilities.getBreadcrumbTrail(this);

  /// Check current route
  bool isRoute(String pattern) => AppUtilities.isCurrentRoute(this, pattern);

  /// Navigation helper methods
  void goToSalesForm({int? invoiceId}) {
    final params =
        invoiceId != null ? {'id': invoiceId.toString()} : <String, String>{};
    final uri =
        Uri.parse('/sales/invoice/form').replace(queryParameters: params);
    go(uri.toString());
  }

  void goToPurchaseForm({int? invoiceId}) {
    final params =
        invoiceId != null ? {'id': invoiceId.toString()} : <String, String>{};
    final uri =
        Uri.parse('/purchases/invoice/form').replace(queryParameters: params);
    go(uri.toString());
  }

  void goToExpenseForm({int? expenseId}) {
    final params =
        expenseId != null ? {'id': expenseId.toString()} : <String, String>{};
    final uri = Uri.parse('/expenses/form').replace(queryParameters: params);
    go(uri.toString());
  }

  void goToDashboard() {
    go(AppRoutes.dashboard);
  }
}
