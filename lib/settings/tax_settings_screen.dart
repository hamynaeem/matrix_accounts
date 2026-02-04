// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaxSettingsScreen extends ConsumerStatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  ConsumerState<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends ConsumerState<TaxSettingsScreen> {
  bool _gstEnabled = true;
  bool _vatEnabled = false;
  bool _tdsEnabled = false;
  double _defaultGstRate = 18.0;
  final String _gstNumber = '';
  final String _panNumber = '';

  final _gstNumberController = TextEditingController();
  final _panNumberController = TextEditingController();

  final List<Map<String, dynamic>> _gstRates = [
    {'name': 'GST 0%', 'rate': 0.0, 'enabled': true},
    {'name': 'GST 5%', 'rate': 5.0, 'enabled': true},
    {'name': 'GST 12%', 'rate': 12.0, 'enabled': true},
    {'name': 'GST 18%', 'rate': 18.0, 'enabled': true},
    {'name': 'GST 28%', 'rate': 28.0, 'enabled': true},
  ];

  @override
  void dispose() {
    _gstNumberController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Settings'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tax Overview Card
            _buildTaxOverviewCard(context),
            const SizedBox(height: 24),

            // GST Settings
            _buildSectionHeader(
                context, 'GST (Goods & Services Tax)', Icons.receipt_long),
            const SizedBox(height: 16),
            _buildGstSettings(context),
            const SizedBox(height: 24),

            // VAT Settings
            _buildSectionHeader(
                context, 'VAT (Value Added Tax)', Icons.calculate),
            const SizedBox(height: 16),
            _buildVatSettings(context),
            const SizedBox(height: 24),

            // TDS Settings
            _buildSectionHeader(
                context, 'TDS (Tax Deducted at Source)', Icons.money_off),
            const SizedBox(height: 16),
            _buildTdsSettings(context),
            const SizedBox(height: 24),

            // Tax Registration Details
            _buildSectionHeader(
                context, 'Registration Details', Icons.verified),
            const SizedBox(height: 16),
            _buildRegistrationDetails(context),
            const SizedBox(height: 24),

            // Tax Rates Configuration
            _buildSectionHeader(context, 'Tax Rates', Icons.percent),
            const SizedBox(height: 16),
            _buildTaxRatesConfiguration(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxOverviewCard(BuildContext context) {
    final theme = Theme.of(context);
    final enabledTaxes = [
      if (_gstEnabled) 'GST',
      if (_vatEnabled) 'VAT',
      if (_tdsEnabled) 'TDS',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance,
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
                      'Tax Configuration',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${enabledTaxes.length} tax types enabled',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: enabledTaxes.map((tax) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      tax,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGstSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          SwitchListTile(
            title: const Text('Enable GST'),
            subtitle: const Text('Goods & Services Tax calculation'),
            value: _gstEnabled,
            onChanged: (value) => setState(() => _gstEnabled = value),
            activeThumbColor: Colors.green,
            secondary: const Icon(Icons.receipt_long),
          ),
          if (_gstEnabled) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.percent),
              title: const Text('Default GST Rate'),
              subtitle: Text('${_defaultGstRate.toStringAsFixed(1)}%'),
              trailing: DropdownButton<double>(
                value: _defaultGstRate,
                items: _gstRates.map((rate) {
                  return DropdownMenuItem<double>(
                    value: rate['rate'] as double,
                    child: Text('${rate['rate'].toStringAsFixed(1)}%'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _defaultGstRate = value!),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('GST Calculation Method'),
              subtitle: const Text('Inclusive pricing'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVatSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SwitchListTile(
        title: const Text('Enable VAT'),
        subtitle: const Text('Value Added Tax calculation'),
        value: _vatEnabled,
        onChanged: (value) => setState(() => _vatEnabled = value),
        activeThumbColor: Colors.blue,
        secondary: const Icon(Icons.calculate),
      ),
    );
  }

  Widget _buildTdsSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SwitchListTile(
        title: const Text('Enable TDS'),
        subtitle: const Text('Tax Deducted at Source'),
        value: _tdsEnabled,
        onChanged: (value) => setState(() => _tdsEnabled = value),
        activeThumbColor: Colors.orange,
        secondary: const Icon(Icons.money_off),
      ),
    );
  }

  Widget _buildRegistrationDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildSmartTextField(
            controller: _gstNumberController,
            label: 'GST Registration Number',
            icon: Icons.numbers,
            hint: 'Enter 15-digit GSTIN',
          ),
          const SizedBox(height: 16),
          _buildSmartTextField(
            controller: _panNumberController,
            label: 'PAN Number',
            icon: Icons.credit_card,
            hint: 'Enter 10-character PAN',
          ),
        ],
      ),
    );
  }

  Widget _buildTaxRatesConfiguration(BuildContext context) {
    return Column(
      children: _gstRates.map((rate) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Switch(
                value: rate['enabled'],
                onChanged: (value) {
                  setState(() {
                    rate['enabled'] = value;
                  });
                },
                activeThumbColor: Colors.green,
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: rate['enabled']
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.percent,
                  color: rate['enabled'] ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: rate['enabled'] ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    Text(
                      'Tax rate: ${rate['rate']}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: rate['enabled']
                            ? Colors.grey.shade600
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  Widget _buildSmartTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tax settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
