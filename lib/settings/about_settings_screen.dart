import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutSettingsScreen extends ConsumerStatefulWidget {
  const AboutSettingsScreen({super.key});

  @override
  ConsumerState<AboutSettingsScreen> createState() =>
      _AboutSettingsScreenState();
}

class _AboutSettingsScreenState extends ConsumerState<AboutSettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Card
            _buildAppInfoCard(context),
            const SizedBox(height: 24),

            // Version Information
            _buildSectionHeader(
                context, 'Version Information', Icons.info_outline),
            const SizedBox(height: 16),
            _buildVersionInfo(context),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader(context, 'Support', Icons.help_outline),
            const SizedBox(height: 16),
            _buildSupportSection(context),
            const SizedBox(height: 24),

            // Legal Section
            _buildSectionHeader(context, 'Legal', Icons.gavel),
            const SizedBox(height: 16),
            _buildLegalSection(context),
            const SizedBox(height: 24),

            // Developer Information
            _buildSectionHeader(context, 'Developer', Icons.code),
            const SizedBox(height: 16),
            _buildDeveloperInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _packageInfo?.appName ?? 'Matrix Accounts',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete Accounting Solution',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Version ${_packageInfo?.version ?? '1.0.0'} (${_packageInfo?.buildNumber ?? '1'})',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    final items = [
      {
        'title': 'App Version',
        'value': _packageInfo?.version ?? '1.0.0',
        'icon': Icons.smartphone
      },
      {
        'title': 'Build Number',
        'value': _packageInfo?.buildNumber ?? '1',
        'icon': Icons.build
      },
      {
        'title': 'Package Name',
        'value': _packageInfo?.packageName ?? 'com.matrix.accounts',
        'icon': Icons.inventory
      },
      {'title': 'Last Updated', 'value': 'January 2026', 'icon': Icons.update},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(item['title'] as String),
                subtitle: Text(item['value'] as String),
                contentPadding: EdgeInsets.zero,
              ),
              if (item != items.last) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final supportItems = [
      {
        'title': 'Help Center',
        'subtitle': 'Get help and tutorials',
        'icon': Icons.help_center,
        'action': 'help'
      },
      {
        'title': 'Contact Support',
        'subtitle': 'Get in touch with our team',
        'icon': Icons.support_agent,
        'action': 'contact'
      },
      {
        'title': 'Report a Bug',
        'subtitle': 'Help us improve the app',
        'icon': Icons.bug_report,
        'action': 'bug'
      },
      {
        'title': 'Feature Request',
        'subtitle': 'Suggest new features',
        'icon': Icons.lightbulb_outline,
        'action': 'feature'
      },
      {
        'title': 'Rate App',
        'subtitle': 'Rate us on the app store',
        'icon': Icons.star_rate,
        'action': 'rate'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: supportItems.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                ),
                title: Text(item['title'] as String),
                subtitle: Text(item['subtitle'] as String),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _handleSupportAction(item['action'] as String),
                contentPadding: EdgeInsets.zero,
              ),
              if (item != supportItems.last) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    final legalItems = [
      {
        'title': 'Privacy Policy',
        'icon': Icons.privacy_tip,
        'action': 'privacy'
      },
      {
        'title': 'Terms of Service',
        'icon': Icons.description,
        'action': 'terms'
      },
      {'title': 'Licenses', 'icon': Icons.article, 'action': 'licenses'},
      {'title': 'Open Source', 'icon': Icons.code, 'action': 'opensource'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: legalItems.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                ),
                title: Text(item['title'] as String),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _handleLegalAction(item['action'] as String),
                contentPadding: EdgeInsets.zero,
              ),
              if (item != legalItems.last) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeveloperInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.developer_mode,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matrix Software Solutions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Professional Software Development',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Matrix Accounts is built with love using Flutter and Dart. We are committed to providing you with the best accounting experience.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open website
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening website...')),
                    );
                  },
                  icon: const Icon(Icons.language),
                  label: const Text('Website'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open email
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening email...')),
                    );
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Email'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _handleSupportAction(String action) {
    String message;
    switch (action) {
      case 'help':
        message = 'Opening help center...';
        break;
      case 'contact':
        message = 'Contacting support...';
        break;
      case 'bug':
        message = 'Opening bug report...';
        break;
      case 'feature':
        message = 'Opening feature request...';
        break;
      case 'rate':
        message = 'Opening app store...';
        break;
      default:
        message = 'Feature coming soon!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleLegalAction(String action) {
    String message;
    switch (action) {
      case 'privacy':
        message = 'Opening privacy policy...';
        break;
      case 'terms':
        message = 'Opening terms of service...';
        break;
      case 'licenses':
        message = 'Opening licenses...';
        break;
      case 'opensource':
        message = 'Opening open source info...';
        break;
      default:
        message = 'Feature coming soon!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
