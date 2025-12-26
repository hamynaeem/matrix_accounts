import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/account_models.dart';
import '../services/report_pdf_generator.dart';

class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  // Operating Activities
  double _netIncome = 0;
  double _salesRevenue = 0;
  double _expenses = 0;
  double _receivableChange = 0;
  double _payableChange = 0;
  double _inventoryChange = 0;

  // Investing Activities
  double _assetPurchases = 0;
  double _assetSales = 0;

  // Financing Activities
  double _equityIncrease = 0;
  double _equityDecrease = 0;
  double _liabilityIncrease = 0;
  double _liabilityDecrease = 0;

  // Cash Changes
  double _cashBeginning = 0;
  double _cashEnding = 0;

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCashFlow();
    });
  }

  Future<void> _loadCashFlow() async {
    setState(() => _isLoading = true);

    try {
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;
      final currentCompany = ref.read(currentCompanyProvider);

      if (currentCompany == null || _startDate == null || _endDate == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load all accounts for the current company
      final allAccounts = await isar.accounts
          .filter()
          .companyIdEqualTo(currentCompany.id)
          .isActiveEqualTo(true)
          .findAll();

      // Get transactions for the period
      final transactions = await isar.accountTransactions
          .filter()
          .companyIdEqualTo(currentCompany.id)
          .transactionDateBetween(_startDate!, _endDate!)
          .sortByTransactionDate()
          .findAll();

      // Calculate Net Income (Revenue - Expenses)
      final revenueAccounts = allAccounts
          .where((a) => a.accountType == AccountType.revenue)
          .toList();
      final expenseAccounts = allAccounts
          .where((a) => a.accountType == AccountType.expense)
          .toList();

      _salesRevenue = revenueAccounts.fold(
        0.0,
        (sum, a) {
          final accountTxns = transactions.where((t) => t.accountId == a.id);
          final credits = accountTxns.fold(0.0, (s, t) => s + t.credit);
          final debits = accountTxns.fold(0.0, (s, t) => s + t.debit);
          return sum + (credits - debits);
        },
      );

      _expenses = expenseAccounts.fold(
        0.0,
        (sum, a) {
          final accountTxns = transactions.where((t) => t.accountId == a.id);
          final debits = accountTxns.fold(0.0, (s, t) => s + t.debit);
          final credits = accountTxns.fold(0.0, (s, t) => s + t.credit);
          return sum + (debits - credits);
        },
      );

      _netIncome = _salesRevenue - _expenses;

      // Calculate changes in working capital
      final arAccount = allAccounts.firstWhere(
        (a) => a.code == '1200',
        orElse: () => Account()..currentBalance = 0,
      );
      final apAccount = allAccounts.firstWhere(
        (a) => a.code == '2000',
        orElse: () => Account()..currentBalance = 0,
      );
      final inventoryAccount = allAccounts.firstWhere(
        (a) => a.code == '1300',
        orElse: () => Account()..currentBalance = 0,
      );

      // Get changes during period
      final arTxns = transactions.where((t) => t.accountId == arAccount.id);
      _receivableChange =
          arTxns.fold(0.0, (sum, t) => sum + t.debit - t.credit);

      final apTxns = transactions.where((t) => t.accountId == apAccount.id);
      _payableChange = apTxns.fold(0.0, (sum, t) => sum + t.credit - t.debit);

      final invTxns =
          transactions.where((t) => t.accountId == inventoryAccount.id);
      _inventoryChange =
          invTxns.fold(0.0, (sum, t) => sum + t.debit - t.credit);

      // Calculate cash positions
      final cashAccounts = allAccounts
          .where(
              (a) => a.code == '1000' || a.code == '1050' || a.code == '1100')
          .toList();

      // Beginning cash (before period)
      _cashBeginning = cashAccounts.fold(0.0, (sum, a) {
        final beforeTxns = isar.accountTransactions
            .filter()
            .companyIdEqualTo(currentCompany.id)
            .accountIdEqualTo(a.id)
            .transactionDateLessThan(_startDate!)
            .findAllSync();

        return sum + beforeTxns.fold(0.0, (s, t) => s + t.debit - t.credit);
      });

      // Ending cash
      _cashEnding = cashAccounts.fold(0.0, (sum, a) => sum + a.currentBalance);

      // For simplicity, other investing and financing activities are set to 0
      // In a full implementation, these would be calculated from specific transactions
      _assetPurchases = 0;
      _assetSales = 0;
      _equityIncrease = 0;
      _equityDecrease = 0;
      _liabilityIncrease = 0;
      _liabilityDecrease = 0;

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cash flow: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generatePdf() async {
    final currentCompany = ref.read(currentCompanyProvider);
    if (currentCompany == null || _startDate == null || _endDate == null) {
      return;
    }

    try {
      final pdfBytes = await ReportPdfGenerator.generateCashFlowPdf(
        company: currentCompany,
        startDate: _startDate!,
        endDate: _endDate!,
        netIncome: _netIncome,
        receivableChange: _receivableChange,
        payableChange: _payableChange,
        inventoryChange: _inventoryChange,
        assetPurchases: _assetPurchases,
        assetSales: _assetSales,
        equityIncrease: _equityIncrease,
        equityDecrease: _equityDecrease,
        liabilityIncrease: _liabilityIncrease,
        liabilityDecrease: _liabilityDecrease,
        cashBeginning: _cashBeginning,
        cashEnding: _cashEnding,
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
                    'Cash Flow Statement PDF',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.print, color: Colors.blue),
                    title: const Text('Print'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ReportPdfGenerator.printPdf(
                          pdfBytes, 'Cash Flow Statement');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.green),
                    title: const Text('Share'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ReportPdfGenerator.sharePdf(
                          pdfBytes, 'cashflow_${currentCompany.name}.pdf');
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
        title: const Text('Cash Flow Statement'),
        backgroundColor: Colors.cyan.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCashFlow,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'cashflow',
      ),
      body: Column(
        children: [
          // Header with company name and date range
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.shade700, Colors.cyan.shade500],
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
                  'Cash Flow Statement',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDateRangeSelector(),
              ],
            ),
          ),
          // Cash Flow Content
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
                    _buildCashFlowSummary(),
                    const SizedBox(height: 24),
                    _buildOperatingActivities(),
                    const SizedBox(height: 24),
                    _buildInvestingActivities(),
                    const SizedBox(height: 24),
                    _buildFinancingActivities(),
                    const SizedBox(height: 24),
                    _buildNetCashChange(),
                    const SizedBox(height: 24),
                    _buildLegend(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _startDate = picked);
                _loadCashFlow();
              }
            },
            child: Text(
              '${_startDate?.day}/${_startDate?.month}/${_startDate?.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(' - ', style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _endDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _endDate = picked);
                _loadCashFlow();
              }
            },
            child: Text(
              '${_endDate?.day}/${_endDate?.month}/${_endDate?.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowSummary() {
    final operatingCash =
        _netIncome - _receivableChange + _payableChange - _inventoryChange;
    final investingCash = _assetSales - _assetPurchases;
    final financingCash = _equityIncrease -
        _equityDecrease +
        _liabilityIncrease -
        _liabilityDecrease;
    final netChange = operatingCash + investingCash + financingCash;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade50, Colors.cyan.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.cyan.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cash Flow Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Operating Activities', operatingCash, Colors.green),
          const SizedBox(height: 8),
          _buildSummaryRow('Investing Activities', investingCash, Colors.blue),
          const SizedBox(height: 8),
          _buildSummaryRow(
              'Financing Activities', financingCash, Colors.orange),
          const Divider(height: 24, thickness: 2),
          _buildSummaryRow('Net Cash Change', netChange, Colors.cyan,
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: amount >= 0 ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildOperatingActivities() {
    final operatingCash =
        _netIncome - _receivableChange + _payableChange - _inventoryChange;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center,
                  color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cash Flow from Operating Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Net Income', _netIncome, indent: false),
          const Divider(height: 16),
          const Text(
            'Adjustments:',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
              'Decrease in Accounts Receivable', -_receivableChange),
          _buildDetailRow('Increase in Accounts Payable', _payableChange),
          _buildDetailRow('Decrease in Inventory', -_inventoryChange),
          const Divider(height: 16, thickness: 2),
          _buildDetailRow('Net Cash from Operating Activities', operatingCash,
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildInvestingActivities() {
    final investingCash = _assetSales - _assetPurchases;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cash Flow from Investing Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Purchase of Assets', -_assetPurchases,
              indent: false),
          _buildDetailRow('Sale of Assets', _assetSales, indent: false),
          const Divider(height: 16, thickness: 2),
          _buildDetailRow('Net Cash from Investing Activities', investingCash,
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildFinancingActivities() {
    final financingCash = _equityIncrease -
        _equityDecrease +
        _liabilityIncrease -
        _liabilityDecrease;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cash Flow from Financing Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Equity Contributions', _equityIncrease,
              indent: false),
          _buildDetailRow('Equity Withdrawals', -_equityDecrease,
              indent: false),
          _buildDetailRow('Loans Received', _liabilityIncrease, indent: false),
          _buildDetailRow('Loan Repayments', -_liabilityDecrease,
              indent: false),
          const Divider(height: 16, thickness: 2),
          _buildDetailRow('Net Cash from Financing Activities', financingCash,
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildNetCashChange() {
    final operatingCash =
        _netIncome - _receivableChange + _payableChange - _inventoryChange;
    final investingCash = _assetSales - _assetPurchases;
    final financingCash = _equityIncrease -
        _equityDecrease +
        _liabilityIncrease -
        _liabilityDecrease;
    final netChange = operatingCash + investingCash + financingCash;
    final calculatedEnding = _cashBeginning + netChange;
    final isBalanced = (_cashEnding - calculatedEnding).abs() < 0.01;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance,
                  color: Colors.purple.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Net Change in Cash',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Cash at Beginning of Period', _cashBeginning,
              indent: false),
          _buildDetailRow('Net Increase/(Decrease) in Cash', netChange,
              indent: false),
          const Divider(height: 16, thickness: 2),
          _buildDetailRow('Cash at End of Period', _cashEnding, isTotal: true),
          const SizedBox(height: 12),
          if (!isBalanced)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: Calculated ending (${_formatCurrency(calculatedEnding)}) differs from actual (${_formatCurrency(_cashEnding)})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
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

  Widget _buildDetailRow(String label, double amount,
      {bool indent = true, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: indent ? 16 : 0,
        top: 4,
        bottom: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 15 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.black87 : Colors.grey.shade800,
              ),
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: amount >= 0 ? Colors.green.shade700 : Colors.red.shade700,
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
                'Understanding the Cash Flow Statement',
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
            'Operating Activities',
            'Cash generated from daily business operations (sales, expenses)',
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Investing Activities',
            'Cash used for or generated from investments in assets',
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Financing Activities',
            'Cash from or used for financing (equity, loans)',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          Text(
            'Positive values indicate cash inflow, negative values indicate cash outflow.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
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

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }
}
