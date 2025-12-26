import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/company_model.dart';
import '../services/company_service.dart';

class CompanyFormScreen extends ConsumerStatefulWidget {
  final int? companyId;

  const CompanyFormScreen({super.key, this.companyId});

  @override
  ConsumerState<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends ConsumerState<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currencyController = TextEditingController(text: 'PKR');

  int _selectedMonth = 7; // July (default)
  bool _isActive = true;
  bool _isLoading = false;
  Company? _existingCompany;

  final List<String> _currencies = [
    'PKR',
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SAR',
    'INR',
  ];

  final List<Map<String, dynamic>> _months = [
    {'value': 1, 'name': 'January'},
    {'value': 2, 'name': 'February'},
    {'value': 3, 'name': 'March'},
    {'value': 4, 'name': 'April'},
    {'value': 5, 'name': 'May'},
    {'value': 6, 'name': 'June'},
    {'value': 7, 'name': 'July'},
    {'value': 8, 'name': 'August'},
    {'value': 9, 'name': 'September'},
    {'value': 10, 'name': 'October'},
    {'value': 11, 'name': 'November'},
    {'value': 12, 'name': 'December'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    if (widget.companyId != null) {
      setState(() => _isLoading = true);

      try {
        final isar = ref.read(isarServiceProvider).isar;
        final service = CompanyService(isar);
        final company = await service.getCompanyById(widget.companyId!);

        if (company != null && mounted) {
          setState(() {
            _existingCompany = company;
            _nameController.text = company.name;
            _currencyController.text = company.primaryCurrency ?? 'PKR';
            _selectedMonth = company.financialYearStartMonth ?? 7;
            _isActive = company.isActive;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading company: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isar = ref.read(isarServiceProvider).isar;
      final service = CompanyService(isar);

      if (_existingCompany != null) {
        // Update existing company
        await service.updateCompany(
          id: _existingCompany!.id,
          name: _nameController.text.trim(),
          primaryCurrency: _currencyController.text.trim(),
          financialYearStartMonth: _selectedMonth,
          isActive: _isActive,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Company updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        // Create new company
        await service.createCompany(
          subscriberId: 1, // TODO: Get from current user
          name: _nameController.text.trim(),
          primaryCurrency: _currencyController.text.trim(),
          financialYearStartMonth: _selectedMonth,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Company created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving company: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = _existingCompany != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Company' : 'Add Company'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Company Name
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Company Name *',
                                hintText: 'Enter company name',
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Company name is required';
                                }
                                if (value.trim().length < 3) {
                                  return 'Company name must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Financial Settings
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Settings',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Currency Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _currencyController.text,
                              decoration: InputDecoration(
                                labelText: 'Primary Currency *',
                                prefixIcon: const Icon(Icons.currency_exchange),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _currencyController.text = value;
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Financial Year Start Month
                            DropdownButtonFormField<int>(
                              initialValue: _selectedMonth,
                              decoration: InputDecoration(
                                labelText: 'Financial Year Start Month *',
                                prefixIcon: const Icon(Icons.calendar_month),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _months.map((month) {
                                return DropdownMenuItem(
                                  value: month['value'] as int,
                                  child: Text(month['name'] as String),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedMonth = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status (only for edit mode)
                    if (isEditMode)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: const Text('Active'),
                                subtitle: Text(
                                  _isActive
                                      ? 'Company is active and visible'
                                      : 'Company is inactive and hidden',
                                  style: theme.textTheme.bodySmall,
                                ),
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() => _isActive = value);
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Save Button
                    FilledButton(
                      onPressed: _isLoading ? null : _saveCompany,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEditMode ? 'Update Company' : 'Create Company',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
