// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Cash Transaction Model
class CashTransaction {
  final String id;
  final DateTime date;
  final String type; // 'Cash In' or 'Cash Out'
  final double amount;
  final String description;
  final double balance;
  final String category;
  final String? notes;

  CashTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
    required this.balance,
    this.category = 'General',
    this.notes,
  });

  CashTransaction copyWith({
    String? id,
    DateTime? date,
    String? type,
    double? amount,
    String? description,
    double? balance,
    String? category,
    String? notes,
  }) {
    return CashTransaction(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      balance: balance ?? this.balance,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type,
        'amount': amount,
        'description': description,
        'balance': balance,
        'category': category,
        'notes': notes,
      };

  factory CashTransaction.fromJson(Map<String, dynamic> json) {
    return CashTransaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      balance: (json['balance'] as num).toDouble(),
      category: json['category'] as String? ?? 'General',
      notes: json['notes'] as String?,
    );
  }
}

// Predefined categories
class TransactionCategories {
  static const List<String> cashInCategories = [
    'Sales',
    'Services',
    'Investment',
    'Loan Received',
    'Other Income',
    'General',
  ];

  static const List<String> cashOutCategories = [
    'Office Expenses',
    'Travel',
    'Supplies',
    'Utilities',
    'Marketing',
    'Maintenance',
    'Salary',
    'Rent',
    'Other Expenses',
    'General',
  ];

  static List<String> getCategoriesForType(String type) {
    return type == 'Cash In' ? cashInCategories : cashOutCategories;
  }
}

// Cash Transactions Provider
class CashTransactionsNotifier extends StateNotifier<List<CashTransaction>> {
  static const String _storageKey = 'cash_transactions';

  CashTransactionsNotifier() : super([]) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final transactions =
            jsonList.map((json) => CashTransaction.fromJson(json)).toList();
        state = transactions;
      } else {
        // If no saved data, use initial sample data
        state = _getInitialData();
        await _saveTransactions();
      }
    } catch (e) {
      // If there's any error loading, use initial data
      state = _getInitialData();
      await _saveTransactions();
    }
  }

  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        state.map((transaction) => transaction.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // Handle save error if needed
      print('Error saving transactions: $e');
    }
  }

  static List<CashTransaction> _getInitialData() {
    // Initial sample data with realistic transactions
    return [
      CashTransaction(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: 'Cash In',
        amount: 8000.00,
        description: 'Customer Payment',
        balance: 13500.00,
        category: 'Sales',
        notes: 'Payment from ABC Corp',
      ),
      CashTransaction(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'Cash Out',
        amount: 1500.00,
        description: 'Office Expenses',
        balance: 20000.00,
        category: 'Office Expenses',
        notes: 'Stationery and supplies',
      ),
      CashTransaction(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'Cash In',
        amount: 5000.00,
        description: 'Sales Payment',
        balance: 25000.00,
        category: 'Sales',
        notes: 'Client payment received',
      ),
    ];
  }

  double get currentBalance {
    if (state.isEmpty) return 0.0;
    return state.first.balance;
  }

  double get totalCashIn {
    return state
        .where((t) => t.type == 'Cash In')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalCashOut {
    return state
        .where((t) => t.type == 'Cash Out')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<CashTransaction> getFilteredTransactions({
    String? searchQuery,
    String? categoryFilter,
    String? typeFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return state.where((transaction) {
      // Search query filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!transaction.description.toLowerCase().contains(query) &&
            !transaction.category.toLowerCase().contains(query) &&
            !(transaction.notes?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Category filter
      if (categoryFilter != null && categoryFilter != 'All') {
        if (transaction.category != categoryFilter) return false;
      }

      // Type filter
      if (typeFilter != null && typeFilter != 'All') {
        if (transaction.type != typeFilter) return false;
      }

      // Date range filter
      if (startDate != null) {
        if (transaction.date.isBefore(startDate)) return false;
      }
      if (endDate != null) {
        if (transaction.date.isAfter(endDate)) return false;
      }

      return true;
    }).toList();
  }

  void addTransaction({
    required DateTime date,
    required String type,
    required double amount,
    required String description,
    required String category,
    String? notes,
  }) {
    final currentBal = currentBalance;
    final newBalance =
        type == 'Cash In' ? currentBal + amount : currentBal - amount;

    final transaction = CashTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      type: type,
      amount: amount,
      description: description,
      balance: newBalance,
      category: category,
      notes: notes,
    );

    // Add to the beginning of the list and update all subsequent balances
    final updatedTransactions = [transaction, ...state];
    state = updatedTransactions;

    // Save to persistent storage
    _saveTransactions();
  }

  void updateTransaction(CashTransaction updatedTransaction) {
    final index = state.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      final newState = [...state];
      newState[index] = updatedTransaction;
      state = newState;
      _recalculateBalances();

      // Save to persistent storage
      _saveTransactions();
    }
  }

  void deleteTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
    _recalculateBalances();

    // Save to persistent storage
    _saveTransactions();
  }

  void _recalculateBalances() {
    if (state.isEmpty) return;

    // Sort transactions by date (oldest first)
    final sortedTransactions = [...state]
      ..sort((a, b) => a.date.compareTo(b.date));
    double runningBalance = 0.0;

    final updatedTransactions = <CashTransaction>[];

    for (final transaction in sortedTransactions) {
      if (transaction.type == 'Cash In') {
        runningBalance += transaction.amount;
      } else {
        runningBalance -= transaction.amount;
      }
      updatedTransactions.add(transaction.copyWith(balance: runningBalance));
    }

    // Sort back to newest first for display
    state = updatedTransactions.reversed.toList();

    // Save to persistent storage
    _saveTransactions();
  }

  Map<String, double> getCategoryTotals(String type) {
    final transactions = state.where((t) => t.type == type);
    final categoryTotals = <String, double>{};

    for (final transaction in transactions) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }
}

final cashTransactionsProvider =
    StateNotifierProvider<CashTransactionsNotifier, List<CashTransaction>>(
        (ref) {
  return CashTransactionsNotifier();
});

class CashInHandScreen extends ConsumerStatefulWidget {
  const CashInHandScreen({super.key});

  @override
  ConsumerState<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends ConsumerState<CashInHandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'Cash In';
  String _selectedCategory = 'General';

  // Filter states
  String _searchQuery = '';
  String _categoryFilter = 'All';
  String _typeFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterExpanded = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      ref.read(cashTransactionsProvider.notifier).addTransaction(
            date: _selectedDate,
            type: _transactionType,
            amount: amount,
            description: _descriptionController.text,
            category: _selectedCategory,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );

      _clearForm();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editTransaction(CashTransaction transaction) {
    _amountController.text = transaction.amount.toString();
    _descriptionController.text = transaction.description;
    _notesController.text = transaction.notes ?? '';
    _selectedDate = transaction.date;
    _transactionType = transaction.type;
    _selectedCategory = transaction.category;

    _showTransactionFormDialog(
      title: 'Edit Transaction',
      isEdit: true,
      transaction: transaction,
    );
  }

  void _updateTransaction(CashTransaction originalTransaction) {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final updatedTransaction = originalTransaction.copyWith(
        date: _selectedDate,
        type: _transactionType,
        amount: amount,
        description: _descriptionController.text,
        category: _selectedCategory,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      ref
          .read(cashTransactionsProvider.notifier)
          .updateTransaction(updatedTransaction);

      _clearForm();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction updated successfully'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now();
    _transactionType = 'Cash In';
    _selectedCategory = 'General';
  }

  void _showAddTransactionDialog() {
    _clearForm();
    _showTransactionFormDialog(title: 'Add Transaction', isEdit: false);
  }

  void _showTransactionFormDialog({
    required String title,
    required bool isEdit,
    CashTransaction? transaction,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Transaction Type
                        DropdownButtonFormField<String>(
                          initialValue: _transactionType,
                          decoration: const InputDecoration(
                            labelText: 'Transaction Type',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Cash In', 'Cash Out'].map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    type == 'Cash In'
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: type == 'Cash In'
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(type),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _transactionType = value!;
                              _selectedCategory = 'General'; // Reset category
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: TransactionCategories.getCategoriesForType(
                                  _transactionType)
                              .map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Amount
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: 'Rs ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Notes (Optional)
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Date Selector
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      _dateFormat.format(_selectedDate),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (isEdit && transaction != null) {
                          _updateTransaction(transaction);
                        } else {
                          _addTransaction();
                        }
                      },
                      child: Text(isEdit ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in cash transactions
    // ref.watch(cashTransactionsProvider);
    final notifier = ref.watch(cashTransactionsProvider.notifier);
    final currentBalance = notifier.currentBalance;
    final totalCashIn = notifier.totalCashIn;
    final totalCashOut = notifier.totalCashOut;

    final filteredTransactions = notifier.getFilteredTransactions(
      searchQuery: _searchQuery,
      categoryFilter: _categoryFilter,
      typeFilter: _typeFilter,
      startDate: _startDate,
      endDate: _endDate,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash in Hand'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showStatisticsDialog(notifier),
            tooltip: 'Statistics',
          ),
          IconButton(
            icon: Icon(
                _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Main Balance Card
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${NumberFormat('#,##,##0.00').format(currentBalance)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Cash In/Out Summary
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_downward,
                                color: Colors.green, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              'Rs ${NumberFormat('#,##0').format(totalCashIn)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_upward,
                                color: Colors.red, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              'Rs ${NumberFormat('#,##0').format(totalCashOut)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Filters (Expandable)
          if (_isFilterExpanded) _buildFiltersSection(),

          const SizedBox(height: 8),

          // Transaction List Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredTransactions.length} found',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Transaction List
          Expanded(
            child: filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _typeFilter,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['All', 'Cash In', 'Cash Out'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _typeFilter = value!);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _categoryFilter,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: {
                    'All',
                    ...TransactionCategories.cashInCategories,
                    ...TransactionCategories.cashOutCategories
                  }.map((category) {
                    return DropdownMenuItem(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _categoryFilter = value!);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateRange(isStart: true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                            _startDate?.toString().split(' ')[0] ?? 'All time'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateRange(isStart: false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(_endDate?.toString().split(' ')[0] ?? 'All time'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _categoryFilter = 'All';
                    _typeFilter = 'All';
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ||
                    _categoryFilter != 'All' ||
                    _typeFilter != 'All'
                ? 'Try adjusting your filters or search terms'
                : 'Add your first cash transaction using the + button',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(CashTransaction transaction) {
    final isIncome = transaction.type == 'Cash In';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTransactionDetails(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncome ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                transaction.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _dateFormat.format(transaction.date),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}Rs ${NumberFormat('#,##,##0.00').format(transaction.amount)}',
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bal: Rs ${NumberFormat('#,##,##0.00').format(transaction.balance)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (transaction.notes != null &&
                  transaction.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transaction.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectDateRange({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showTransactionDetails(CashTransaction transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  transaction.type == 'Cash In'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color:
                      transaction.type == 'Cash In' ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    transaction.description,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${transaction.type == 'Cash In' ? '+' : '-'}Rs ${NumberFormat('#,##,##0.00').format(transaction.amount)}',
                  style: TextStyle(
                    color: transaction.type == 'Cash In'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Category', transaction.category),
            _buildDetailRow('Date', _dateFormat.format(transaction.date)),
            _buildDetailRow('Balance After',
                'Rs ${NumberFormat('#,##,##0.00').format(transaction.balance)}'),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              _buildDetailRow('Notes', transaction.notes!),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editTransaction(transaction);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteDialog(transaction);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatisticsDialog(CashTransactionsNotifier notifier) {
    final cashInByCategory = notifier.getCategoryTotals('Cash In');
    final cashOutByCategory = notifier.getCategoryTotals('Cash Out');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cash Flow Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_downward, color: Colors.green),
                          const SizedBox(height: 8),
                          Text(
                            'Total Cash In',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs ${NumberFormat('#,##,##0').format(notifier.totalCashIn)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'Total Cash Out',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs ${NumberFormat('#,##,##0').format(notifier.totalCashOut)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Category Breakdown
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cashInByCategory.isNotEmpty) ...[
                        const Text(
                          'Cash In by Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...cashInByCategory.entries.map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    'Rs ${NumberFormat('#,##0').format(entry.value)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                      ],
                      if (cashOutByCategory.isNotEmpty) ...[
                        const Text(
                          'Cash Out by Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...cashOutByCategory.entries.map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    'Rs ${NumberFormat('#,##0').format(entry.value)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(CashTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this transaction?\n\n'
          '${transaction.description}\n'
          'Amount: Rs ${NumberFormat('#,##,##0.00').format(transaction.amount)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(cashTransactionsProvider.notifier)
                  .deleteTransaction(transaction.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction deleted successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
