// ignore_for_file: deprecated_member_use

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
                    // Simplified Balance Sheet - Only Cash, Bank, Balance
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSimplifiedBalanceItem(
                              'Cash in Hand',
                              _getCashInHandAmount(),
                              Icons.money,
                              Colors.green,
                            ),
                            const Divider(height: 32),
                            _buildSimplifiedBalanceItem(
                              'Bank Amount',
                              _getBankAmount(),
                              Icons.account_balance,
                              Colors.blue,
                            ),
                            const Divider(height: 32),
                            _buildSimplifiedBalanceItem(
                              'Net Balance',
                              _getNetBalance(),
                              Icons.account_balance_wallet,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Total Summary Card
                    Card(
                      elevation: 3,
                      color: Colors.teal.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.assessment,
                              size: 32,
                              color: Colors.teal.shade700,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Available Funds',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'PKR ${(_getCashInHandAmount() + _getBankAmount()).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
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

  Widget _buildSimplifiedBalanceItem(
      String title, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PKR ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getCashInHandAmount() {
    // Find cash account from asset accounts
    final cashAccount = _assetAccounts.where(
      (account) => account.name.toLowerCase().contains('cash'),
    );
    return cashAccount.isNotEmpty ? cashAccount.first.currentBalance : 0.0;
  }

  double _getBankAmount() {
    // Find bank account from asset accounts
    final bankAccount = _assetAccounts.where(
      (account) => account.name.toLowerCase().contains('bank'),
    );
    return bankAccount.isNotEmpty ? bankAccount.first.currentBalance : 0.0;
  }

  double _getNetBalance() {
    // Calculate net balance (Assets - Liabilities)
    return _totalAssets - _totalLiabilities;
  }
}
