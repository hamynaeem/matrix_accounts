// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix_accounts/features/settings/presentation/company_settings_screen.dart'
    show CompanySettingsScreen;
import 'package:matrix_accounts/presentation/screens/login_screen.dart';
import 'package:matrix_accounts/settings/financial_year_settings_screen.dart';
import 'package:matrix_accounts/settings/lock_screen.dart';
import 'package:matrix_accounts/settings/share_user_screen.dart';
import 'package:matrix_accounts/settings/tax_settings_screen.dart';
import 'package:matrix_accounts/settings/theme_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/providers.dart';
import '../../core/mixins/app_lifecycle_mixin.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;
  bool _enableNotifications = true;
  bool _autoBackup = true;
  String _currency = 'INR';
  String _dateFormat = 'DD/MM/YYYY';
  String _language = 'English';
  int _autoLockDuration = 5; // Auto-lock after 5 minutes

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final biometricService = ref.read(biometricServiceProvider);

    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _enableNotifications = prefs.getBool('enableNotifications') ?? true;
      _autoBackup = prefs.getBool('autoBackup') ?? true;
      _currency = prefs.getString('currency') ?? 'INR';
      _dateFormat = prefs.getString('dateFormat') ?? 'DD/MM/YYYY';
      _language = prefs.getString('language') ?? 'English';
      _autoLockDuration = biometricService.autoLockDuration;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'PKR - Pakistani Rupee',
            'USD - US Dollar',
          ].map((currency) {
            final currencyCode = currency.split(' - ')[0];
            return RadioListTile<String>(
              title: Text(currency),
              value: currencyCode,
              groupValue: _currency,
              onChanged: (value) {
                setState(() {
                  _currency = value!;
                });
                _saveSetting('currency', value!);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDateFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'DD/MM/YYYY',
            'MM/DD/YYYY',
            'YYYY-MM-DD',
          ].map((format) {
            return RadioListTile<String>(
              title: Text(format),
              value: format,
              groupValue: _dateFormat,
              onChanged: (value) {
                setState(() {
                  _dateFormat = value!;
                });
                _saveSetting('dateFormat', value!);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'English',
            'Urdu',
          ].map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                _saveSetting('language', value!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language will be applied on next restart'),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _enableBiometricAuth() async {
    try {
      final biometricService = ref.read(biometricServiceProvider);
      final success = await biometricService.setBiometricEnabled(true);

      if (success) {
        setState(() {
          // Refresh the UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication enabled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to enable biometric authentication'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disableBiometricAuth() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Biometric Authentication'),
        content: const Text(
          'Are you sure you want to disable biometric authentication? '
          'This will also disable auto-lock functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final biometricService = ref.read(biometricServiceProvider);
      final success = await biometricService.setBiometricEnabled(false);

      if (success) {
        setState(() {
          // Refresh the UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication disabled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _getAutoLockText(int minutes) {
    if (minutes <= 0) return 'Disabled';
    if (minutes == 1) return 'After 1 minute';
    return 'After $minutes minutes';
  }

  void _showAutoLockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Lock Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Select when to automatically lock the app after going to background:'),
            const SizedBox(height: 16),
            ...[-1, 0, 1, 2, 5, 10, 15, 30].map((minutes) {
              String text;
              if (minutes == -1) {
                text = 'Immediately';
              } else if (minutes == 0) {
                text = 'Never';
              } else if (minutes == 1) {
                text = 'After 1 minute';
              } else {
                text = 'After $minutes minutes';
              }

              return RadioListTile<int>(
                title: Text(text),
                value: minutes,
                groupValue: _autoLockDuration,
                onChanged: (value) async {
                  if (value != null) {
                    final biometricService = ref.read(biometricServiceProvider);
                    await biometricService.setAutoLockDuration(value);
                    setState(() {
                      _autoLockDuration = value;
                    });
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: colorScheme.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildModernCard(
            children: [
              _buildModernListTile(
                title: 'Language',
                subtitle: _language,
                icon: Icons.language,
                onTap: _showLanguageDialog,
                isFirst: true,
              ),
              const Divider(height: 1, indent: 56),
              _buildModernListTile(
                title: 'Theme',
                subtitle: 'Customize app appearance',
                icon: Icons.palette_outlined,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ThemeSettingsScreen()));
                },
              ),
              const Divider(height: 1, indent: 56),
              const Divider(height: 1, indent: 56),
              _buildModernListTile(
                title: 'Company Settings',
                subtitle: 'Manage company information',
                icon: Icons.business,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CompanySettingsScreen()));
                },
              ),
              const Divider(height: 1, indent: 56),
            ],
          ),

          // User Profile Section
          _buildSectionHeader('User Profile'),
          _buildModernCard(
            children: [
              _buildModernListTile(
                title: 'User Settings',
                subtitle: 'Manage your profile and preferences',
                icon: Icons.account_circle_outlined,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShareUserScreen(),
                    ),
                  );
                },
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          _buildModernCard(
            children: [
              _buildModernListTile(
                title: 'User Settings',
                subtitle: 'Manage your profile and preferences',
                icon: Icons.account_circle_outlined,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          // General Section
          _buildSectionHeader('General'),
          _buildModernCard(
            children: [
              _buildModernSwitchTile(
                title: 'Notifications',
                subtitle: 'Receive app notifications',
                value: _enableNotifications,
                icon: Icons.notifications_outlined,
                onChanged: (value) {
                  setState(() {
                    _enableNotifications = value;
                  });
                  _saveSetting('enableNotifications', value);
                },
                isFirst: true,
              ),
              const Divider(height: 1, indent: 56),
              _buildModernListTile(
                title: 'Currency',
                subtitle: _currency == 'PKR' ? 'Pakistani Rupee' : 'US Dollar',
                icon: Icons.monetization_on_outlined,
                onTap: _showCurrencyDialog,
              ),
              const Divider(height: 1, indent: 56),
            ],
          ),

          // Support Section
          _buildSectionHeader('Support'),
          _buildModernCard(
            children: [
              _buildModernListTile(
                title: 'Help & FAQ',
                subtitle: 'Get help and find answers',
                icon: Icons.help_outline,
                iconColor: Colors.blue,
                onTap: () {
                  context.push('/help');
                },
                isFirst: true,
              ),
              const Divider(height: 1, indent: 56),
              _buildModernListTile(
                title: 'Contact Support',
                subtitle: 'Get in touch with our team',
                icon: Icons.support_agent_outlined,
                iconColor: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Contact: support@matrix-solutions.com')),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildModernListTile(
                title: 'About',
                subtitle: 'App version and info',
                icon: Icons.info_outline,
                iconColor: Colors.orange,
                onTap: () {
                  context.push('/about');
                },
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Reset Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text(
                      'This will reset all settings to their default values. '
                      'Your accounting data will not be affected.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings reset successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadSettings();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset All Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModernCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModernListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).colorScheme.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
    bool? enabled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ?? true ? onChanged : null,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
