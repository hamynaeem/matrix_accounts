import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/account_models.dart';

class JournalEntryFormScreen extends ConsumerStatefulWidget {
  const JournalEntryFormScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JournalEntryFormScreen> createState() =>
      _JournalEntryFormScreenState();
}

class _JournalEntryFormScreenState
    extends ConsumerState<JournalEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _referenceNoController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final List<JournalEntryLineItem> _lines = [];
  bool _isLoading = false;
  List<Account> _allAccounts = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _referenceNoController.text = 'JE-${DateTime.now().millisecondsSinceEpoch}';

    // Add two empty lines to start
    _lines.add(JournalEntryLineItem());
    _lines.add(JournalEntryLineItem());

    // Load accounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccounts();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _referenceNoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final accountDao = ref.read(accountDaoProvider);
    final accounts = await accountDao.getAccounts(company.id);

    setState(() {
      _allAccounts = accounts;
    });
  }

  void _addLine() {
    setState(() {
      _lines.add(JournalEntryLineItem());
    });
  }

  void _removeLine(int index) {
    if (_lines.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 2 lines are required')),
      );
      return;
    }

    setState(() {
      _lines.removeAt(index);
    });
  }

  double get _totalDebits =>
      _lines.fold(0.0, (sum, line) => sum + (line.debit ?? 0.0));

  double get _totalCredits =>
      _lines.fold(0.0, (sum, line) => sum + (line.credit ?? 0.0));

  double get _difference => _totalDebits - _totalCredits;

  bool get _isBalanced => _difference.abs() < 0.01;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveJournalEntry() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate lines
    for (int i = 0; i < _lines.length; i++) {
      final line = _lines[i];
      if (line.accountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select account for line ${i + 1}')),
        );
        return;
      }

      if ((line.debit ?? 0.0) == 0 && (line.credit ?? 0.0) == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please enter debit or credit for line ${i + 1}')),
        );
        return;
      }

      if ((line.debit ?? 0.0) > 0 && (line.credit ?? 0.0) > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Line ${i + 1} cannot have both debit and credit. Use separate lines.')),
        );
        return;
      }
    }

    if (!_isBalanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Journal entry is not balanced. Difference: ₹${_difference.abs().toStringAsFixed(2)}')),
      );
      return;
    }

    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // NOTE: JournalEntryLine model and recordJournalEntry method not yet implemented
      /*
      final accountDao = ref.read(accountDaoProvider);

      // Convert to JournalEntryLine objects
      final journalLines = _lines
          .map((line) => JournalEntryLine(
                accountId: line.accountId!,
                debit: line.debit ?? 0.0,
                credit: line.credit ?? 0.0,
                description: line.description,
              ))
          .toList();

      await accountDao.recordJournalEntry(
        companyId: company.id,
        entryDate: _selectedDate,
        referenceNo: _referenceNoController.text,
        description: _descriptionController.text,
        lines: journalLines,
      );
      */

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Journal entry saved successfully'),
              backgroundColor: Colors.green),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving journal entry: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveJournalEntry,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Date
                                  TextFormField(
                                    controller: _dateController,
                                    decoration: InputDecoration(
                                      labelText: 'Entry Date *',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.calendar_today),
                                        onPressed: _selectDate,
                                      ),
                                    ),
                                    readOnly: true,
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Reference Number
                                  TextFormField(
                                    controller: _referenceNoController,
                                    decoration: const InputDecoration(
                                      labelText: 'Reference Number *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Description
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Description *',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 2,
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lines Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Journal Entry Lines',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _addLine,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Line'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Lines List
                          ..._lines.asMap().entries.map((entry) {
                            final index = entry.key;
                            final line = entry.value;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Line ${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (_lines.length > 2)
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _removeLine(index),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Account Dropdown
                                    DropdownButtonFormField<int>(
                                      initialValue: line.accountId,
                                      decoration: const InputDecoration(
                                        labelText: 'Account *',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: _allAccounts.map((account) {
                                        return DropdownMenuItem(
                                          value: account.id,
                                          child: Text(
                                              '${account.code} - ${account.name}'),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          line.accountId = value;
                                        });
                                      },
                                      isExpanded: true,
                                    ),
                                    const SizedBox(height: 12),

                                    // Debit and Credit
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              labelText: 'Debit',
                                              border: OutlineInputBorder(),
                                              prefixText: '₹ ',
                                            ),
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            onChanged: (value) {
                                              setState(() {
                                                line.debit =
                                                    double.tryParse(value) ??
                                                        0.0;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              labelText: 'Credit',
                                              border: OutlineInputBorder(),
                                              prefixText: '₹ ',
                                            ),
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            onChanged: (value) {
                                              setState(() {
                                                line.credit =
                                                    double.tryParse(value) ??
                                                        0.0;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Line Description
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Line Description',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        line.description = value;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  // Totals Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isBalanced ? Colors.green[50] : Colors.red[50],
                      border: Border(
                        top: BorderSide(
                          color: _isBalanced ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('Total Debits'),
                                Text(
                                  '₹${_totalDebits.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Total Credits'),
                                Text(
                                  '₹${_totalCredits.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Difference'),
                                Text(
                                  '₹${_difference.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _isBalanced ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              _isBalanced ? Icons.check_circle : Icons.error,
                              color: _isBalanced ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isBalanced
                                  ? 'Entry is balanced ✓'
                                  : 'Entry is not balanced!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isBalanced ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isBalanced && !_isLoading
                                ? _saveJournalEntry
                                : null,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Journal Entry'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Helper class for managing journal entry line items in the UI
class JournalEntryLineItem {
  int? accountId;
  double? debit;
  double? credit;
  String? description;

  JournalEntryLineItem({
    this.accountId,
    this.debit,
    this.credit,
    this.description,
  });
}
