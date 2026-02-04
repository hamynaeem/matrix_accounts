import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Settings_Screen extends ConsumerWidget {
  const Settings_Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Configure your application preferences',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Company Settings Section
            _buildSectionHeader(
              context: context,
              title: 'Company Settings',
              icon: Icons.business,
            ),
            const SizedBox(height: 8),
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.business_center,
                  title: 'Company Information',
                  subtitle: 'Update company details, logo, and contact info',
                  onTap: () => context.push('/settings/company-settings'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.account_balance,
                  title: 'Financial Year',
                  subtitle: 'Set financial year and accounting periods',
                  onTap: () => context.push('/settings/financial-year'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.receipt_long,
                  title: 'Tax Settings',
                  subtitle: 'Configure GST, VAT, and other tax settings',
                  onTap: () => context.push('/settings/tax-settings'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Invoice & Document Settings
            _buildSectionHeader(
              context: context,
              title: 'Document Settings',
              icon: Icons.description,
            ),
            const SizedBox(height: 8),
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.format_list_numbered,
                  title: 'Invoice Numbering',
                  subtitle: 'Configure invoice, bill, and receipt numbering',
                  onTap: () =>
                      _showComingSoonDialog(context, 'Invoice Numbering'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.print,
                  title: 'Print Templates',
                  subtitle: 'Customize invoice and receipt templates',
                  onTap: () =>
                      _showComingSoonDialog(context, 'Print Templates'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.language,
                  title: 'Language & Currency',
                  subtitle: 'Set default language and currency',
                  onTap: () =>
                      _showComingSoonDialog(context, 'Language & Currency'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // System Settings
            _buildSectionHeader(
              context: context,
              title: 'System Settings',
              icon: Icons.settings,
            ),
            const SizedBox(height: 8),
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Configure alerts and reminders',
                  onTap: () => _showComingSoonDialog(context, 'Notifications'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Password, backup, and security settings',
                  onTap: () => _showComingSoonDialog(context, 'Security'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.sync,
                  title: 'Data Sync',
                  subtitle: 'Configure data synchronization settings',
                  onTap: () => _showComingSoonDialog(context, 'Data Sync'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Application Settings
            _buildSectionHeader(
              context: context,
              title: 'Application',
              icon: Icons.phone_android,
            ),
            const SizedBox(height: 8),
            _buildSettingsCard(
              context: context,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.palette,
                  title: 'Theme & Appearance',
                  subtitle: 'Dark mode, colors, and display settings',
                  onTap: () => context.push('/settings/theme-settings'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.storage,
                  title: 'Storage & Backup',
                  subtitle: 'Manage app data and backups',
                  onTap: () =>
                      _showComingSoonDialog(context, 'Storage & Backup'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version information and support',
                  onTap: () => context.push('/settings/about-settings'),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Expanded(child: SizedBox()),
          Container(
            height: 2,
            width: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: trailing ??
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.shade200,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade50],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.construction,
                    color: Colors.blue.shade600,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$feature is currently under development and will be available in a future update.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Stay tuned for updates!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
