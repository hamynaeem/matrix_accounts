import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FinancialYearSettingsScreen extends ConsumerStatefulWidget {
  const FinancialYearSettingsScreen({super.key});

  @override
  ConsumerState<FinancialYearSettingsScreen> createState() =>
      _FinancialYearSettingsScreenState();
}

class _FinancialYearSettingsScreenState
    extends ConsumerState<FinancialYearSettingsScreen> {
  DateTime _startDate =
      DateTime(DateTime.now().year, 4, 1); // April 1st default
  DateTime _endDate =
      DateTime(DateTime.now().year + 1, 3, 31); // March 31st default
  String _selectedPeriod = 'April to March';
  bool _isLocked = false;

  final List<Map<String, dynamic>> _predefinedPeriods = [
    {'name': 'April to March', 'start': 4, 'end': 3},
    {'name': 'January to December', 'start': 1, 'end': 12},
    {'name': 'July to June', 'start': 7, 'end': 6},
    {'name': 'October to September', 'start': 10, 'end': 9},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Year Settings'),
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
            // Current Financial Year Card
            _buildCurrentYearCard(context),
            const SizedBox(height: 24),

            // Quick Period Selection
            _buildSectionHeader(context, 'Quick Setup', Icons.flash_on),
            const SizedBox(height: 16),
            _buildQuickPeriodSelection(context),
            const SizedBox(height: 24),

            // Custom Period Selection
            _buildSectionHeader(context, 'Custom Period', Icons.calendar_month),
            const SizedBox(height: 16),
            _buildCustomPeriodSelection(context),
            const SizedBox(height: 24),

            // Financial Year History
            _buildSectionHeader(context, 'Previous Years', Icons.history),
            const SizedBox(height: 16),
            _buildYearHistory(context),
            const SizedBox(height: 24),

            // Lock Year Option
            _buildLockYearSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentYearCard(BuildContext context) {
    final theme = Theme.of(context);
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
                  Icons.calendar_today,
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
                      'Current Financial Year',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLocked)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Days Remaining',
                  '${_endDate.difference(DateTime.now()).inDays}', Icons.timer),
              const SizedBox(width: 16),
              _buildStatCard(
                  'Total Days',
                  '${_endDate.difference(_startDate).inDays + 1}',
                  Icons.event_note),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPeriodSelection(BuildContext context) {
    return Column(
      children: _predefinedPeriods.map((period) {
        final isSelected = _selectedPeriod == period['name'];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _selectPredefinedPeriod(period),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: period['name'],
                    groupValue: _selectedPeriod,
                    onChanged: (value) => _selectPredefinedPeriod(period),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.calendar_month,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      period['name'],
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomPeriodSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateField('Start Date', _startDate, (date) {
                  setState(() {
                    _startDate = date;
                    _endDate = DateTime(date.year + 1, date.month, date.day)
                        .subtract(const Duration(days: 1));
                    _selectedPeriod = 'Custom';
                  });
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField('End Date', _endDate, (date) {
                  setState(() => _endDate = date);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
      String label, DateTime date, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(child: Text(_formatDate(date))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearHistory(BuildContext context) {
    final years = [
      {'year': '2023-24', 'status': 'Closed', 'color': Colors.green},
      {'year': '2022-23', 'status': 'Closed', 'color': Colors.green},
      {'year': '2021-22', 'status': 'Locked', 'color': Colors.orange},
    ];

    return Column(
      children: years.map((year) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (year['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  year['status'] == 'Closed' ? Icons.check_circle : Icons.lock,
                  color: year['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Year ${year['year']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      year['status'] as String,
                      style: TextStyle(
                        color: year['color'] as Color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: View year details
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLockYearSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Text(
                'Lock Financial Year',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Locking the financial year will prevent any modifications to transactions within this period. This action can be undone later.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Switch(
                value: _isLocked,
                onChanged: (value) => setState(() => _isLocked = value),
                activeThumbColor: Colors.orange.shade700,
              ),
              const SizedBox(width: 12),
              Text(
                _isLocked ? 'Year is locked' : 'Year is unlocked',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
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

  void _selectPredefinedPeriod(Map<String, dynamic> period) {
    setState(() {
      _selectedPeriod = period['name'];
      final year = DateTime.now().year;
      final startMonth = period['start'] as int;
      final endMonth = period['end'] as int;

      if (startMonth <= endMonth) {
        _startDate = DateTime(year, startMonth, 1);
        _endDate = DateTime(year, endMonth + 1, 0);
      } else {
        _startDate = DateTime(year, startMonth, 1);
        _endDate = DateTime(year + 1, endMonth + 1, 0);
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _saveSettings() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Financial year settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
