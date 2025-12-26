import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/expense_dao.dart' as expense_dao;
import '../../../data/models/account_models.dart' as account_models;
import '../../../data/models/company_model.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/models/user_model.dart';
import '../../payments/logic/payment_providers.dart';

// Provider for ExpenseDao
final expenseDaoProvider = Provider<expense_dao.ExpenseDao>((ref) {
  final isarService = ref.read(isarServiceProvider);
  return expense_dao.ExpenseDao(isarService.isar);
});

class ExpenseLineDraft {
  String? description;
  double qty;
  double rate;

  ExpenseLineDraft({
    this.description,
    this.qty = 1,
    this.rate = 0,
  });

  double get amount => qty * rate;
}

class PaymentLineDraft {
  int? accountId;
  String? accountName;
  String? accountIcon;
  double amount;

  PaymentLineDraft({
    this.accountId,
    this.accountName,
    this.accountIcon,
    this.amount = 0,
  });
}

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final int? expenseId;

  const ExpenseFormScreen({super.key, this.expenseId});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  DateTime _date = DateTime.now();
  final _refNoCtrl = TextEditingController();
  final List<ExpenseLineDraft> _lines = [];
  final List<PaymentLineDraft> _paymentLines = [];
  account_models.Account? _selectedExpenseAccount;
  bool _includeTax = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _loadExpense();
    } else {
      _refNoCtrl.text = 'EXP-${DateTime.now().millisecondsSinceEpoch}';
      _lines.add(ExpenseLineDraft());
      _addDefaultCashPayment().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  Future<void> _addDefaultCashPayment() async {
    final paymentDao = ref.read(paymentDaoProvider);
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      final accounts = await paymentDao.getPaymentAccounts(company.id);
      final cashAccount = accounts
          .where((a) => a.accountType == PaymentAccountType.cash)
          .firstOrNull;

      if (cashAccount != null && mounted) {
        setState(() {
          _paymentLines.add(PaymentLineDraft(
            accountId: cashAccount.id,
            accountName: cashAccount.accountName,
            accountIcon: cashAccount.icon,
            amount: 0,
          ));
        });
      }
    }
  }

  Future<void> _loadExpense() async {
    try {
      final expenseDao = ref.read(expenseDaoProvider);
      final isar = ref.read(isarServiceProvider).isar;

      // Load transaction
      final transaction = await expenseDao.getExpenseById(widget.expenseId!);
      if (transaction == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense not found')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Load transaction lines
      final lines = await expenseDao.getExpenseLines(widget.expenseId!);

      // Load expense account from the first line (they should all have the same expenseCategoryId)
      if (lines.isNotEmpty && lines.first.expenseCategoryId != null) {
        final account = await isar.accounts.get(lines.first.expenseCategoryId!);
        if (account != null) {
          _selectedExpenseAccount = account;
        }
      }

      // Load payment info from account transactions
      final accountTransactions = await isar.accountTransactions
          .filter()
          .referenceIdEqualTo(widget.expenseId!)
          .findAll();

      // Populate form
      _refNoCtrl.text = transaction.referenceNo;
      _date = transaction.date;

      // Populate expense lines
      _lines.clear();
      for (final line in lines) {
        _lines.add(ExpenseLineDraft(
          description: line.description,
          qty: line.quantity,
          rate: line.unitPrice,
        ));
      }

      // Populate payment lines (group by account code)
      _paymentLines.clear();
      final paymentMap = <String, double>{};

      // Credits are payments (money going out)
      for (final trans in accountTransactions.where((t) => t.credit > 0)) {
        final account = await isar.accounts.get(trans.accountId);
        if (account != null) {
          final accountCode = account.code;
          paymentMap[accountCode] =
              (paymentMap[accountCode] ?? 0) + trans.credit;
        }
      }

      // Map account codes to payment accounts
      final company = ref.read(currentCompanyProvider);
      if (company != null) {
        final allPaymentAccounts = await isar.paymentAccounts
            .filter()
            .companyIdEqualTo(company.id)
            .findAll();

        for (final entry in paymentMap.entries) {
          final accountCode = entry.key;
          PaymentAccount? matchedAccount;

          // Map codes to payment account types
          if (accountCode == '1000') {
            matchedAccount = allPaymentAccounts.firstWhere(
              (a) => a.accountType == PaymentAccountType.cash,
              orElse: () => allPaymentAccounts.first,
            );
          } else if (accountCode == '1050') {
            matchedAccount = allPaymentAccounts.firstWhere(
              (a) => a.accountType == PaymentAccountType.cheque,
              orElse: () => allPaymentAccounts.first,
            );
          } else if (accountCode == '1100') {
            matchedAccount = allPaymentAccounts.firstWhere(
              (a) => a.accountType == PaymentAccountType.bank,
              orElse: () => allPaymentAccounts.first,
            );
          }

          if (matchedAccount != null) {
            _paymentLines.add(PaymentLineDraft(
              accountId: matchedAccount.id,
              accountName: matchedAccount.accountName,
              accountIcon: matchedAccount.icon,
              amount: entry.value,
            ));
          }
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading expense: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _refNoCtrl.dispose();
    super.dispose();
  }

  double get _subTotal => _lines.fold<double>(0, (sum, l) => sum + l.amount);

  double get _totalAmount => _subTotal;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final user = ref.watch(currentUserProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseId != null ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: Colors.deepOrange.shade700,
        actions: [
          Row(
            children: [
              const Text('Tax'),
              Switch(
                value: _includeTax,
                onChanged: (value) {
                  setState(() => _includeTax = value);
                },
                activeThumbColor: Colors.white,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense No. and Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expense No.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        TextField(
                          controller: _refNoCtrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(2020),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _date = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_date.day}/${_date.month}/${_date.year}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Expense Category
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expense Category',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final isar = ref.read(isarServiceProvider).isar;
                      final accounts = await isar.accounts
                          .filter()
                          .companyIdEqualTo(company?.id ?? 0)
                          .accountTypeEqualTo(
                              account_models.AccountType.expense)
                          .findAll();

                      if (context.mounted) {
                        final selected =
                            await showDialog<account_models.Account>(
                          context: context,
                          builder: (context) => _ExpenseCategoryDialog(
                            accounts: accounts,
                            companyId: company?.id ?? 0,
                            isar: isar,
                          ),
                        );

                        if (selected != null && mounted) {
                          setState(() => _selectedExpenseAccount = selected);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedExpenseAccount?.name ??
                                'Select expense category',
                            style: TextStyle(
                              color: _selectedExpenseAccount == null
                                  ? Colors.grey.shade600
                                  : Colors.black,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Billed Items Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Text(
                            'Billed Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // TODO: Delete items
                            },
                            child: const Text('Delete Items'),
                          ),
                        ],
                      ),
                    ),
                    // Table Header
                    Container(
                      color: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text('Item Name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              )),
                          Expanded(
                              child: Text('Qty',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Rate',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Amount',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    // Items
                    ...List.generate(
                        _lines.length, (index) => _buildLineItem(index)),
                    // Total Row
                    Container(
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text('Total',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              )),
                          Expanded(
                            child: Text(
                              _lines
                                  .fold<double>(0, (sum, l) => sum + l.qty)
                                  .toStringAsFixed(1),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Expanded(
                            child: Text(
                              _subTotal.toStringAsFixed(2),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Add Item Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _lines.add(ExpenseLineDraft()));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade100,
                    foregroundColor: Colors.deepOrange.shade700,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Total Amount
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepOrange.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rs ${_totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Section
              _buildPaymentSection(),
              const SizedBox(height: 24),

              // Save Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _saveExpense(company, user, saveAndNew: true),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: BorderSide(color: Colors.deepOrange.shade700),
                      ),
                      child: Text(
                        'Save & New',
                        style: TextStyle(color: Colors.deepOrange.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveExpense(company, user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade700,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineItem(int index) {
    final line = _lines[index];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Item description',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) {
                  line.description = value;
                },
              ),
            ),
          ),
          Expanded(
            child: TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  line.qty = double.tryParse(value) ?? 1;
                });
              },
            ),
          ),
          Expanded(
            child: TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  line.rate = double.tryParse(value) ?? 0;
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                line.amount.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: () {
              if (_lines.length > 1) {
                setState(() => _lines.removeAt(index));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.deepOrange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Payment Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () async {
                final paymentDao = ref.read(paymentDaoProvider);
                final company = ref.read(currentCompanyProvider);
                if (company != null) {
                  final accounts =
                      await paymentDao.getPaymentAccounts(company.id);
                  if (context.mounted) {
                    final selected = await showDialog<PaymentAccount>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Select Payment Account'),
                        children: accounts
                            .map((account) => SimpleDialogOption(
                                  onPressed: () =>
                                      Navigator.pop(context, account),
                                  child: Text(
                                      '${account.icon ?? ''} ${account.accountName}'),
                                ))
                            .toList(),
                      ),
                    );

                    if (selected != null && mounted) {
                      setState(() {
                        _paymentLines.add(PaymentLineDraft(
                          accountId: selected.id,
                          accountName: selected.accountName,
                          accountIcon: selected.icon,
                          amount: 0,
                        ));
                      });
                    }
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Type'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._paymentLines.asMap().entries.map((entry) {
          final index = entry.key;
          final payment = entry.value;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(payment.accountIcon ?? '💵',
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    payment.accountName ?? 'Cash',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: 'Rs ',
                      ),
                      onChanged: (value) {
                        payment.amount = double.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _paymentLines.removeAt(index));
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _saveExpense(Company? company, User? user,
      {bool saveAndNew = false}) async {
    if (company == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company not selected')),
        );
      }
      return;
    }

    if (_selectedExpenseAccount == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select expense category')),
        );
      }
      return;
    }

    final validLines = _lines
        .where((l) => l.description?.isNotEmpty == true && l.amount > 0)
        .toList();

    if (validLines.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one expense item')),
        );
      }
      return;
    }

    final validPayments = _paymentLines
        .where((p) => p.accountId != null && p.amount > 0)
        .toList();

    if (validPayments.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add payment information')),
        );
      }
      return;
    }

    try {
      final expenseDao = ref.read(expenseDaoProvider);

      final lineInputs = validLines
          .map((l) => expense_dao.ExpenseLineInput(
                description: l.description!,
                quantity: l.qty,
                rate: l.rate,
                amount: l.amount,
              ))
          .toList();

      final paymentInputs = validPayments
          .map((p) => expense_dao.PaymentLineInput(
                accountId: p.accountId!,
                amount: p.amount,
              ))
          .toList();

      if (widget.expenseId != null) {
        // Update existing expense
        await expenseDao.updateExpense(
          expenseId: widget.expenseId!,
          companyId: company.id,
          date: _date,
          referenceNo: _refNoCtrl.text.trim(),
          expenseAccountId: _selectedExpenseAccount!.id,
          expenseAccountName: _selectedExpenseAccount!.name,
          lines: lineInputs,
          paymentLines: paymentInputs,
          userId: user?.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Create new expense
        await expenseDao.createExpense(
          companyId: company.id,
          date: _date,
          referenceNo: _refNoCtrl.text.trim(),
          expenseAccountId: _selectedExpenseAccount!.id,
          expenseAccountName: _selectedExpenseAccount!.name,
          lines: lineInputs,
          paymentLines: paymentInputs,
          userId: user?.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense saved successfully'),
              backgroundColor: Colors.green,
            ),
          );

          if (saveAndNew) {
            setState(() {
              _refNoCtrl.text = 'EXP-${DateTime.now().millisecondsSinceEpoch}';
              _lines.clear();
              _lines.add(ExpenseLineDraft());
              _paymentLines.clear();
              _selectedExpenseAccount = null;
            });
          } else {
            Navigator.pop(context, true); // Return true to refresh list
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Enhanced Expense Category Selection Dialog
class _ExpenseCategoryDialog extends StatefulWidget {
  final List<account_models.Account> accounts;
  final int companyId;
  final Isar isar;

  const _ExpenseCategoryDialog({
    required this.accounts,
    required this.companyId,
    required this.isar,
  });

  @override
  State<_ExpenseCategoryDialog> createState() => _ExpenseCategoryDialogState();
}

class _ExpenseCategoryDialogState extends State<_ExpenseCategoryDialog> {
  final _searchController = TextEditingController();
  List<account_models.Account> _filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    _filteredAccounts = widget.accounts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAccounts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAccounts = widget.accounts;
      } else {
        _filteredAccounts = widget.accounts
            .where((account) =>
                account.name.toLowerCase().contains(query.toLowerCase()) ||
                account.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _addNewCategory() async {
    final result = await showDialog<account_models.Account>(
      context: context,
      builder: (context) => _AddCategoryDialog(
        companyId: widget.companyId,
        isar: widget.isar,
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Expense Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterAccounts,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterAccounts('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
              ),
            ),
            // Add New Category Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addNewCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Category'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const Divider(height: 24),
            // Categories List
            Expanded(
              child: _filteredAccounts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No categories found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _addNewCategory,
                              child: const Text('Add new category'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = _filteredAccounts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepOrange.shade100,
                            child: Icon(
                              Icons.receipt_long,
                              color: Colors.deepOrange.shade700,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            account.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Code: ${account.code}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onTap: () => Navigator.pop(context, account),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add New Category Dialog
class _AddCategoryDialog extends StatefulWidget {
  final int companyId;
  final Isar isar;

  const _AddCategoryDialog({
    required this.companyId,
    required this.isar,
  });

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if code already exists
      final existingAccount = await widget.isar.accounts
          .filter()
          .companyIdEqualTo(widget.companyId)
          .codeEqualTo(_codeController.text.trim())
          .findFirst();

      if (existingAccount != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Category code "${_codeController.text}" already exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Create new account
      final newAccount = account_models.Account()
        ..companyId = widget.companyId
        ..name = _nameController.text.trim()
        ..code = _codeController.text.trim()
        ..accountType = account_models.AccountType.expense
        ..description = _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null
        ..isSystem = false
        ..isActive = true
        ..openingBalance = 0
        ..currentBalance = 0
        ..createdAt = DateTime.now();

      await widget.isar.writeTxn(() async {
        await widget.isar.accounts.put(newAccount);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, newAccount);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding category: $e'),
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
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text(
                        'Add New Expense Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Form Fields
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Name
                      const Text(
                        'Category Name *',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Office Supplies',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Category Code
                      const Text(
                        'Category Code *',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., EXP-001',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter category code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      const Text(
                        'Description (Optional)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Enter description',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveCategory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
