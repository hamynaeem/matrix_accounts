import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/account_models.dart';
import '../services/report_pdf_generator.dart';

class BalanceSheetScreen extends ConsumerStatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  ConsumerState<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends ConsumerState<BalanceSheetScreen> {
  DateTime _asOfDate = DateTime.now();
  bool _isLoading = true;

  // Balance Sheet Data
  List<Account> _assetAccounts = [];
  List<Account> _liabilityAccounts = [];
  List<Account> _equityAccounts = [];

  double _totalAssets = 0;
  double _totalLiabilities = 0;
  double _totalEquity = 0;
  double _netIncome = 0; // From revenue - expenses

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBalanceSheet();
    });
  }

  Future<void> _loadBalanceSheet() async {
    setState(() => _isLoading = true);

    try {
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;
      final currentCompany = ref.read(currentCompanyProvider);

      if (currentCompany == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load all accounts for the current company
      final allAccounts = await isar.accounts
          .filter()
          .companyIdEqualTo(currentCompany.id)
          .isActiveEqualTo(true)
          .findAll();

      // Separate accounts by type
      _assetAccounts =
          allAccounts.where((a) => a.accountType == AccountType.asset).toList();
      _liabilityAccounts = allAccounts
          .where((a) => a.accountType == AccountType.liability)
          .toList();
      _equityAccounts = allAccounts
          .where((a) => a.accountType == AccountType.equity)
          .toList();

      // Get revenue and expense accounts to calculate net income
      final revenueAccounts = allAccounts
          .where((a) => a.accountType == AccountType.revenue)
          .toList();
      final expenseAccounts = allAccounts
          .where((a) => a.accountType == AccountType.expense)
          .toList();

      // Calculate totals
      _totalAssets =
          _assetAccounts.fold(0.0, (sum, a) => sum + a.currentBalance);
      _totalLiabilities =
          _liabilityAccounts.fold(0.0, (sum, a) => sum + a.currentBalance);
      _totalEquity =
          _equityAccounts.fold(0.0, (sum, a) => sum + a.currentBalance);

      // Calculate net income (Revenue - Expenses)
      final totalRevenue =
          revenueAccounts.fold(0.0, (sum, a) => sum + a.currentBalance);
      final totalExpenses =
          expenseAccounts.fold(0.0, (sum, a) => sum + a.currentBalance);
      _netIncome = totalRevenue - totalExpenses;

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading balance sheet: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generatePdf() async {
    final currentCompany = ref.read(currentCompanyProvider);
    if (currentCompany == null) return;

    try {
      final pdfBytes = await ReportPdfGenerator.generateBalanceSheetPdf(
        company: currentCompany,
        asOfDate: _asOfDate,
        assetAccounts: _assetAccounts,
        liabilityAccounts: _liabilityAccounts,
        equityAccounts: _equityAccounts,
        totalAssets: _totalAssets,
        totalLiabilities: _totalLiabilities,
        totalEquity: _totalEquity,
        netIncome: _netIncome,
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
                    'Balance Sheet PDF',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.print, color: Colors.blue),
                    title: const Text('Print'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ReportPdfGenerator.printPdf(
                          pdfBytes, 'Balance Sheet');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.green),
                    title: const Text('Share'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ReportPdfGenerator.sharePdf(
                          pdfBytes, 'balance_sheet_${currentCompany.name}.pdf');
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
        title: const Text('Balance Sheet'),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBalanceSheet,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'balance_sheet',
      ),
      body: Column(
        children: [
          // Header with company name and date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
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
                  'Balance Sheet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'As of: ${_asOfDate.day}/${_asOfDate.month}/${_asOfDate.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Balance Sheet Content
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accounting Equation Display
                    _buildAccountingEquation(),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Assets
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Assets', Colors.blue),
                              const SizedBox(height: 12),
                              _buildAccountList(_assetAccounts),
                              const Divider(thickness: 2, height: 24),
                              _buildTotalRow(
                                'Total Assets',
                                _totalAssets,
                                Colors.blue.shade700,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Column: Liabilities & Equity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Liabilities Section
                              _buildSectionHeader('Liabilities', Colors.red),
                              const SizedBox(height: 12),
                              _buildAccountList(_liabilityAccounts),
                              const Divider(thickness: 1, height: 24),
                              _buildTotalRow(
                                'Total Liabilities',
                                _totalLiabilities,
                                Colors.red.shade700,
                              ),
                              const SizedBox(height: 24),
                              // Equity Section
                              _buildSectionHeader('Equity', Colors.green),
                              const SizedBox(height: 12),
                              _buildAccountList(_equityAccounts),
                              const SizedBox(height: 8),
                              // Net Income (added to equity)
                              _buildAccountRow(
                                'Net Income (Current Period)',
                                _netIncome,
                                isSubtotal: true,
                              ),
                              const Divider(thickness: 1, height: 24),
                              _buildTotalRow(
                                'Total Equity',
                                _totalEquity + _netIncome,
                                Colors.green.shade700,
                              ),
                              const Divider(thickness: 2, height: 24),
                              _buildTotalRow(
                                'Total Liabilities & Equity',
                                _totalLiabilities + _totalEquity + _netIncome,
                                Colors.purple.shade700,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Balance Check
                    _buildBalanceCheck(),
                    const SizedBox(height: 16),
                    // Legend
                    _buildLegend(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountingEquation() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.indigo.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.functions, color: Colors.indigo.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Accounting Equation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildEquationBox('Assets', _totalAssets, Colors.blue),
              const Text('=',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              _buildEquationBox('Liabilities', _totalLiabilities, Colors.red),
              const Text('+',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              _buildEquationBox(
                  'Equity', _totalEquity + _netIncome, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquationBox(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList(List<Account> accounts) {
    if (accounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No accounts',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: accounts.map((account) {
        return _buildAccountRow(account.name, account.currentBalance);
      }).toList(),
    );
  }

  Widget _buildAccountRow(String name, double balance,
      {bool isSubtotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: isSubtotal ? Colors.grey.shade700 : Colors.grey.shade800,
                fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal,
                fontStyle: isSubtotal ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          Text(
            _formatCurrency(balance),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal,
              color: balance >= 0 ? Colors.black87 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, Color color,
      {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: isBold ? 16 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCheck() {
    final isBalanced =
        (_totalAssets - (_totalLiabilities + _totalEquity + _netIncome)).abs() <
            0.01;
    final difference =
        _totalAssets - (_totalLiabilities + _totalEquity + _netIncome);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBalanced ? Colors.green.shade300 : Colors.red.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning,
            color: isBalanced ? Colors.green.shade700 : Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBalanced
                      ? 'Balance Sheet is Balanced ✓'
                      : 'Balance Sheet is Out of Balance!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isBalanced
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBalanced
                      ? 'Assets = Liabilities + Equity'
                      : 'Difference: ${_formatCurrency(difference)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isBalanced
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Understanding the Balance Sheet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            'Assets',
            'What the company owns (Cash, Inventory, Receivables)',
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Liabilities',
            'What the company owes (Payables, Loans)',
            Colors.red,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Equity',
            'Owner\'s investment + Retained Earnings',
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Net Income',
            'Current period profit (Revenue - Expenses)',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _asOfDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _asOfDate) {
      setState(() {
        _asOfDate = picked;
      });
      // Note: In a full implementation, you would recalculate balances
      // based on transactions up to the selected date
      _loadBalanceSheet();
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }
}
