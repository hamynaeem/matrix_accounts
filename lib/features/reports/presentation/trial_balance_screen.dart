import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/account_models.dart';
import '../services/report_pdf_generator.dart';

class TrialBalanceScreen extends ConsumerStatefulWidget {
  const TrialBalanceScreen({super.key});

  @override
  ConsumerState<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends ConsumerState<TrialBalanceScreen> {
  DateTime _asOfDate = DateTime.now();
  bool _isLoading = true;

  // Trial Balance Data
  List<AccountBalanceItem> _accountItems = [];
  double _totalDebits = 0;
  double _totalCredits = 0;
  bool _isBalanced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrialBalance();
    });
  }

  Future<void> _loadTrialBalance() async {
    setState(() => _isLoading = true);

    try {
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;
      final currentCompany = ref.read(currentCompanyProvider);

      if (currentCompany == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load all active accounts for the current company
      final allAccounts = await isar.accounts
          .filter()
          .companyIdEqualTo(currentCompany.id)
          .isActiveEqualTo(true)
          .sortByCode()
          .findAll();

      // Get transactions up to the as-of date
      final transactions = await isar.accountTransactions
          .filter()
          .companyIdEqualTo(currentCompany.id)
          .transactionDateLessThan(_asOfDate.add(const Duration(days: 1)))
          .findAll();

      // Calculate balances for each account
      _accountItems = [];
      _totalDebits = 0;
      _totalCredits = 0;

      for (final account in allAccounts) {
        // Get transactions for this account
        final accountTxns =
            transactions.where((t) => t.accountId == account.id);

        double totalDebits = accountTxns.fold(0.0, (sum, t) => sum + t.debit);
        double totalCredits = accountTxns.fold(0.0, (sum, t) => sum + t.credit);
        double balance = totalDebits - totalCredits;

        // Determine if this account normally has a debit or credit balance
        bool isDebitAccount = account.accountType == AccountType.asset ||
            account.accountType == AccountType.expense;

        double debitBalance = 0;
        double creditBalance = 0;

        if (isDebitAccount) {
          // Asset and Expense accounts normally have debit balances
          if (balance >= 0) {
            debitBalance = balance;
          } else {
            creditBalance = -balance; // Contra account
          }
        } else {
          // Liability, Equity, and Revenue accounts normally have credit balances
          if (balance <= 0) {
            creditBalance = -balance;
          } else {
            debitBalance = balance; // Contra account
          }
        }

        // Only include accounts with non-zero balances
        if (debitBalance != 0 || creditBalance != 0) {
          _accountItems.add(AccountBalanceItem(
            account: account,
            debitBalance: debitBalance,
            creditBalance: creditBalance,
          ));

          _totalDebits += debitBalance;
          _totalCredits += creditBalance;
        }
      }

      // Check if debits equal credits
      _isBalanced = (_totalDebits - _totalCredits).abs() < 0.01;

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trial balance: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generatePdf() async {
    final currentCompany = ref.read(currentCompanyProvider);
    if (currentCompany == null) return;

    try {
      // Convert AccountBalanceItem list to Map for PDF generator
      final accountData = _accountItems
          .map((item) => {
                'code': item.account.code,
                'name': item.account.name,
                'debit': item.debitBalance,
                'credit': item.creditBalance,
              })
          .toList();

      final pdfBytes = await ReportPdfGenerator.generateTrialBalancePdf(
        company: currentCompany,
        asOfDate: _asOfDate,
        accountItems: accountData,
        totalDebits: _totalDebits,
        totalCredits: _totalCredits,
      );

      if (mounted) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Trial Balance PDF',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.print, color: Colors.blue),
                    title: const Text('Print'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ReportPdfGenerator.printPdf(
                          pdfBytes, 'Trial Balance');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.green),
                    title: const Text('Share'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ReportPdfGenerator.sharePdf(
                          pdfBytes, 'trial_balance_${currentCompany.name}.pdf');
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCompany = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trial Balance'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrialBalance,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'trial-balance',
      ),
      body: Column(
        children: [
          // Header with company name and date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigo.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                if (currentCompany != null)
                  Text(
                    currentCompany.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4),
                const Text(
                  'Trial Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDateSelector(),
              ],
            ),
          ),
          // Balance indicator
          _buildBalanceIndicator(),
          // Trial Balance Content
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTrialBalanceTable(),
                    const SizedBox(height: 16),
                    _buildLegend(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _asOfDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => _asOfDate = picked);
            _loadTrialBalance();
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text(
              'As of: ',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '${_asOfDate.day}/${_asOfDate.month}/${_asOfDate.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isBalanced ? Colors.green.shade50 : Colors.red.shade50,
        border: Border(
          bottom: BorderSide(
            color: _isBalanced ? Colors.green.shade200 : Colors.red.shade200,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isBalanced ? Icons.check_circle : Icons.error,
            color: _isBalanced ? Colors.green.shade700 : Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isBalanced
                ? 'Trial Balance is Balanced ✓'
                : 'Trial Balance is NOT Balanced - Please Review',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isBalanced ? Colors.green.shade900 : Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialBalanceTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Code',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Account Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Debit',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Credit',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Account Rows grouped by type
          ..._buildAccountsByType(),
          // Total Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 80),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatCurrency(_totalDebits),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatCurrency(_totalCredits),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Difference indicator if not balanced
          if (!_isBalanced)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border(
                  top: BorderSide(color: Colors.red.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Difference: ${_formatCurrency((_totalDebits - _totalCredits).abs())}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildAccountsByType() {
    final widgets = <Widget>[];

    // Group accounts by type
    final accountsByType = <AccountType, List<AccountBalanceItem>>{};
    for (final item in _accountItems) {
      accountsByType.putIfAbsent(item.account.accountType, () => []).add(item);
    }

    // Order: Assets, Liabilities, Equity, Revenue, Expenses
    final orderedTypes = [
      AccountType.asset,
      AccountType.liability,
      AccountType.equity,
      AccountType.revenue,
      AccountType.expense,
    ];

    bool isFirst = true;
    for (final type in orderedTypes) {
      final accounts = accountsByType[type];
      if (accounts == null || accounts.isEmpty) continue;

      // Add section header
      if (!isFirst) {
        widgets.add(const Divider(height: 1, thickness: 1));
      }
      isFirst = false;

      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey.shade100,
          child: Text(
            _getAccountTypeLabel(type),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ),
      );

      // Add account rows
      for (final item in accounts) {
        widgets.add(_buildAccountRow(item));
      }
    }

    return widgets;
  }

  Widget _buildAccountRow(AccountBalanceItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              item.account.code,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.account.name,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.debitBalance > 0 ? _formatCurrency(item.debitBalance) : '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    item.debitBalance > 0 ? FontWeight.w600 : FontWeight.normal,
                color: item.debitBalance > 0
                    ? Colors.green.shade700
                    : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              item.creditBalance > 0
                  ? _formatCurrency(item.creditBalance)
                  : '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: item.creditBalance > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: item.creditBalance > 0
                    ? Colors.blue.shade700
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.indigo, size: 20),
              SizedBox(width: 8),
              Text(
                'Understanding the Trial Balance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            'Purpose',
            'Verifies that total debits equal total credits in the accounting system',
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Normal Balances',
            'Assets & Expenses have debit balances • Liabilities, Equity & Revenue have credit balances',
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Balanced System',
            'When debits = credits, the double-entry accounting system is in balance',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Colors.indigo, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: This report should always balance. If it doesn\'t, check for data entry errors or system issues.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Colors.indigo,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getAccountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return 'ASSETS';
      case AccountType.liability:
        return 'LIABILITIES';
      case AccountType.equity:
        return 'EQUITY';
      case AccountType.revenue:
        return 'REVENUE';
      case AccountType.expense:
        return 'EXPENSES';
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }
}

class AccountBalanceItem {
  final Account account;
  final double debitBalance;
  final double creditBalance;

  AccountBalanceItem({
    required this.account,
    required this.debitBalance,
    required this.creditBalance,
  });
}
