// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// App Settings Model
class AppSettings {
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final String financialYearStart;
  final String financialYearEnd;
  final String defaultCurrency;
  final String defaultLanguage;
  final bool isDarkMode;
  final String themeColor;
  final bool enableNotifications;
  final bool enableAutoBackup;
  final String taxRate;
  final String invoicePrefix;
  final int invoiceStartNumber;

  AppSettings({
    this.companyName = 'Matrix Accounts',
    this.companyAddress = '123 Business Street, City',
    this.companyPhone = '+92 300 1234567',
    this.companyEmail = 'info@matrixaccounts.com',
    this.financialYearStart = 'April',
    this.financialYearEnd = 'March',
    this.defaultCurrency = 'PKR',
    this.defaultLanguage = 'English',
    this.isDarkMode = false,
    this.themeColor = 'blue',
    this.enableNotifications = true,
    this.enableAutoBackup = false,
    this.taxRate = '17.0',
    this.invoicePrefix = 'INV',
    this.invoiceStartNumber = 1001,
  });

  AppSettings copyWith({
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? financialYearStart,
    String? financialYearEnd,
    String? defaultCurrency,
    String? defaultLanguage,
    bool? isDarkMode,
    String? themeColor,
    bool? enableNotifications,
    bool? enableAutoBackup,
    String? taxRate,
    String? invoicePrefix,
    int? invoiceStartNumber,
  }) {
    return AppSettings(
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      financialYearStart: financialYearStart ?? this.financialYearStart,
      financialYearEnd: financialYearEnd ?? this.financialYearEnd,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeColor: themeColor ?? this.themeColor,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      taxRate: taxRate ?? this.taxRate,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      invoiceStartNumber: invoiceStartNumber ?? this.invoiceStartNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'companyAddress': companyAddress,
        'companyPhone': companyPhone,
        'companyEmail': companyEmail,
        'financialYearStart': financialYearStart,
        'financialYearEnd': financialYearEnd,
        'defaultCurrency': defaultCurrency,
        'defaultLanguage': defaultLanguage,
        'isDarkMode': isDarkMode,
        'themeColor': themeColor,
        'enableNotifications': enableNotifications,
        'enableAutoBackup': enableAutoBackup,
        'taxRate': taxRate,
        'invoicePrefix': invoicePrefix,
        'invoiceStartNumber': invoiceStartNumber,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      companyName: json['companyName'] as String? ?? 'Matrix Accounts',
      companyAddress:
          json['companyAddress'] as String? ?? '123 Business Street, City',
      companyPhone: json['companyPhone'] as String? ?? '+92 300 1234567',
      companyEmail:
          json['companyEmail'] as String? ?? 'info@matrixaccounts.com',
      financialYearStart: json['financialYearStart'] as String? ?? 'April',
      financialYearEnd: json['financialYearEnd'] as String? ?? 'March',
      defaultCurrency: json['defaultCurrency'] as String? ?? 'PKR',
      defaultLanguage: json['defaultLanguage'] as String? ?? 'English',
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      themeColor: json['themeColor'] as String? ?? 'blue',
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableAutoBackup: json['enableAutoBackup'] as bool? ?? false,
      taxRate: json['taxRate'] as String? ?? '17.0',
      invoicePrefix: json['invoicePrefix'] as String? ?? 'INV',
      invoiceStartNumber: json['invoiceStartNumber'] as int? ?? 1001,
    );
  }
}

// Settings Provider
class SettingsNotifier extends StateNotifier<AppSettings> {
  static const String _storageKey = 'app_settings';

  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = AppSettings.fromJson(json);
      }
    } catch (e) {
      // If error, keep default settings
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Company Settings Updates
  Future<void> updateCompanyInfo({
    String? name,
    String? address,
    String? phone,
    String? email,
  }) async {
    state = state.copyWith(
      companyName: name,
      companyAddress: address,
      companyPhone: phone,
      companyEmail: email,
    );
    await _saveSettings();
  }

  // Financial Year Settings
  Future<void> updateFinancialYear({
    String? startMonth,
    String? endMonth,
  }) async {
    state = state.copyWith(
      financialYearStart: startMonth,
      financialYearEnd: endMonth,
    );
    await _saveSettings();
  }

  // Currency and Language
  Future<void> updateLocalization({
    String? currency,
    String? language,
  }) async {
    state = state.copyWith(
      defaultCurrency: currency,
      defaultLanguage: language,
    );
    await _saveSettings();
  }

  // Theme Settings
  Future<void> updateTheme({
    bool? isDark,
    String? color,
  }) async {
    state = state.copyWith(
      isDarkMode: isDark,
      themeColor: color,
    );
    await _saveSettings();
  }

  // System Settings
  Future<void> updateSystemSettings({
    bool? notifications,
    bool? autoBackup,
  }) async {
    state = state.copyWith(
      enableNotifications: notifications,
      enableAutoBackup: autoBackup,
    );
    await _saveSettings();
  }

  // Tax Settings
  Future<void> updateTaxSettings({
    String? taxRate,
  }) async {
    state = state.copyWith(
      taxRate: taxRate,
    );
    await _saveSettings();
  }

  // Invoice Settings
  Future<void> updateInvoiceSettings({
    String? prefix,
    int? startNumber,
  }) async {
    state = state.copyWith(
      invoicePrefix: prefix,
      invoiceStartNumber: startNumber,
    );
    await _saveSettings();
  }
}

// Global Settings Provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

// Theme Provider
final themeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(settingsProvider);

  final colorSeed = _getColorFromString(settings.themeColor);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: colorSeed,
    brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Roboto',
  );
});

Color _getColorFromString(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    case 'red':
      return Colors.red;
    case 'teal':
      return Colors.teal;
    case 'indigo':
      return Colors.indigo;
    default:
      return Colors.blue;
  }
}

// Constants for settings options
class SettingsConstants {
  static const List<String> currencies = [
    'PKR',
    'USD',
    'EUR',
    'GBP',
    'INR',
    'SAR',
    'AED'
  ];

  static const List<String> languages = ['English', 'Urdu', 'Arabic', 'Hindi'];

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static const List<String> themeColors = [
    'blue',
    'green',
    'purple',
    'orange',
    'red',
    'teal',
    'indigo'
  ];

  static const Map<String, String> currencySymbols = {
    'PKR': '₨',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'SAR': 'ر.س',
    'AED': 'د.إ',
  };
}
