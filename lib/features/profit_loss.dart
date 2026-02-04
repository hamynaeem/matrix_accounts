import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../core/config/providers.dart';
import '../core/widgets/navigation_drawer_helper.dart';
import '../data/models/inventory_models.dart';
import '../data/models/invoice_stock_models.dart';
import '../data/models/transaction_model.dart';

class ProfitLossScreen extends ConsumerStatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  ConsumerState<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends ConsumerState<ProfitLossScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showDetails = true;

  @override
  void initState() {
    super.initState();
    // Default to current financial year or month
    final now = DateTime.now();
    _startDate = DateTime(now.year, 4, 1); // Financial year start (April)
    _endDate = DateTime(now.year + 1, 3, 31); // Financial year end (March)
  }

  @override
  Widget build(BuildContext context) {
    final currentCompany = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss Statement'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showDetails ? Icons.visibility : Icons.visibility_off),
            tooltip: _showDetails ? 'Hide Details' : 'Show Details',
            onPressed: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Report',
            onPressed: () => _printReport(),
          ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'profit_loss',
      ),
      body: Column(
        children: [
          // Date Range Selector
          _buildDateRangeSelector(),

          // Report Content
          Expanded(
            child: _buildProfitLossReport(currentCompany?.id),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    'From Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateSelector(
                    'To Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildDateRangeButton('Today', 'today'),
                _buildDateRangeButton('This Week', 'week'),
                _buildDateRangeButton('This Month', 'month'),
                _buildDateRangeButton('This Quarter', 'quarter'),
                _buildDateRangeButton('This Year', 'year'),
                _buildDateRangeButton('Financial Year', 'financial'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
      String label, DateTime? date, Function(DateTime?) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: const TextStyle(fontSize: 14),
            ),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(String label, String period) {
    return TextButton(
      onPressed: () => _setDateRange(period),
      style: TextButton.styleFrom(
        backgroundColor: Colors.indigo.shade50,
        foregroundColor: Colors.indigo.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _setDateRange(String period) {
    final now = DateTime.now();
    setState(() {
      switch (period) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'quarter':
          final quarter = ((now.month - 1) ~/ 3) + 1;
          _startDate = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
          _endDate = DateTime(now.year, quarter * 3 + 1, 0);
          break;
        case 'year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31);
          break;
        case 'financial':
          // Indian financial year: April to March
          if (now.month >= 4) {
            _startDate = DateTime(now.year, 4, 1);
            _endDate = DateTime(now.year + 1, 3, 31);
          } else {
            _startDate = DateTime(now.year - 1, 4, 1);
            _endDate = DateTime(now.year, 3, 31);
          }
          break;
      }
    });
  }

  Widget _buildProfitLossReport(int? companyId) {
    if (companyId == null) {
      return const Center(child: Text('Please select a company'));
    }

    if (_startDate == null || _endDate == null) {
      return const Center(child: Text('Please select date range'));
    }

    final isar = ref.read(isarServiceProvider).isar;

    return FutureBuilder<_ProfitLossData>(
      future: _calculateProfitLoss(isar, companyId, _startDate!, _endDate!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Calculating Profit & Loss...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('No data available'));
        }

        return _buildProfitLossStatement(data);
      },
    );
  }

  Widget _buildProfitLossStatement(_ProfitLossData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStatementHeader(),
          const SizedBox(height: 20),

          // Revenue Section
          _buildRevenueSection(data),
          const SizedBox(height: 16),

          // Cost of Goods Sold
          _buildCOGSSection(data),
          const SizedBox(height: 16),

          // Gross Profit
          _buildGrossProfitSection(data),
          const SizedBox(height: 16),

          // Operating Expenses
          _buildExpensesSection(data),
          const SizedBox(height: 16),

          // Net Profit
          _buildNetProfitSection(data),

          if (_showDetails) ...[
            const SizedBox(height: 24),
            _buildDetailedBreakdown(data),
          ],
        ],
      ),
    );
  }

  Widget _buildStatementHeader() {
    final period = _startDate != null && _endDate != null
        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} to ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
        : 'Select Date Range';

    return Card(
      elevation: 2,
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'PROFIT & LOSS STATEMENT',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'For the period: $period',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSection(_ProfitLossData data) {
    return _buildSection(
      'REVENUE',
      [
        _buildLineItem('Sales Revenue', data.totalRevenue, isTotal: true),
        if (_showDetails) ...[
          _buildLineItem('  - Gross Sales', data.grossSales, indent: true),
          _buildLineItem('  - Sales Returns', -data.salesReturns,
              indent: true, isNegative: true),
        ],
      ],
      Colors.green,
    );
  }

  Widget _buildCOGSSection(_ProfitLossData data) {
    return _buildSection(
      'COST OF GOODS SOLD',
      [
        _buildLineItem('Opening Stock', data.openingStock),
        _buildLineItem('Purchases', data.totalPurchases),
        _buildLineItem('Direct Costs', data.directCosts),
        _buildLineItem('Less: Closing Stock', -data.closingStock,
            isNegative: true),
        const Divider(),
        _buildLineItem('Total COGS', data.totalCOGS, isTotal: true),
      ],
      Colors.orange,
    );
  }

  Widget _buildGrossProfitSection(_ProfitLossData data) {
    final grossProfit = data.totalRevenue - data.totalCOGS;
    final grossProfitMargin =
        data.totalRevenue > 0 ? (grossProfit / data.totalRevenue * 100) : 0.0;

    return _buildSection(
      'GROSS PROFIT',
      [
        _buildLineItem('Gross Profit', grossProfit, isTotal: true),
        if (_showDetails)
          _buildLineItem('Gross Profit Margin', grossProfitMargin,
              isPercentage: true),
      ],
      grossProfit >= 0 ? Colors.green : Colors.red,
    );
  }

  Widget _buildExpensesSection(_ProfitLossData data) {
    return _buildSection(
      'OPERATING EXPENSES',
      [
        _buildLineItem('Administrative Expenses', data.adminExpenses),
        _buildLineItem('Selling Expenses', data.sellingExpenses),
        _buildLineItem('Financial Expenses', data.financialExpenses),
        _buildLineItem('Other Expenses', data.otherExpenses),
        const Divider(),
        _buildLineItem('Total Operating Expenses', data.totalExpenses,
            isTotal: true),
      ],
      Colors.red,
    );
  }

  Widget _buildNetProfitSection(_ProfitLossData data) {
    final grossProfit = data.totalRevenue - data.totalCOGS;
    final netProfit = grossProfit - data.totalExpenses;
    final netProfitMargin =
        data.totalRevenue > 0 ? (netProfit / data.totalRevenue * 100) : 0.0;

    return Card(
      elevation: 4,
      color: netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'NET PROFIT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: netProfit >= 0
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Net Profit (Loss)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs. ${netProfit.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: netProfit >= 0
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ],
            ),
            if (_showDetails) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Profit Margin'),
                  Text(
                    '${netProfitMargin.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: netProfit >= 0
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(
    String label,
    double amount, {
    bool isTotal = false,
    bool indent = false,
    bool isNegative = false,
    bool isPercentage = false,
  }) {
    final textStyle = TextStyle(
      fontSize: isTotal ? 14 : 13,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isNegative ? Colors.red.shade700 : null,
    );

    final amountStyle = TextStyle(
      fontSize: isTotal ? 14 : 13,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isNegative
          ? Colors.red.shade700
          : (amount < 0 ? Colors.red.shade700 : null),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: indent ? 16.0 : 0.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: textStyle)),
          Text(
            isPercentage
                ? '${amount.toStringAsFixed(2)}%'
                : 'Rs. ${amount.abs().toStringAsFixed(2)}',
            style: amountStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown(_ProfitLossData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DETAILED BREAKDOWN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildBreakdownItem(
                'Total Transactions', data.totalTransactions.toString()),
            _buildBreakdownItem('Sales Invoices', data.salesCount.toString()),
            _buildBreakdownItem(
                'Purchase Invoices', data.purchaseCount.toString()),
            _buildBreakdownItem(
                'Average Sale', 'Rs. ${data.averageSale.toStringAsFixed(2)}'),
            _buildBreakdownItem('Average Purchase',
                'Rs. ${data.averagePurchase.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<_ProfitLossData> _calculateProfitLoss(
    Isar isar,
    int companyId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Get all transactions in the period
      final transactions = await isar
          .collection<Transaction>()
          .filter()
          .companyIdEqualTo(companyId)
          .dateBetween(start, end.add(const Duration(days: 1)))
          .findAll();

      double totalRevenue = 0;
      double grossSales = 0;
      double salesReturns = 0;
      double totalPurchases = 0;
      double totalCOGS = 0;
      double directCosts = 0;
      double adminExpenses = 0;
      double sellingExpenses = 0;
      double financialExpenses = 0;
      double otherExpenses = 0;

      int salesCount = 0;
      int purchaseCount = 0;

      // Process transactions
      for (final transaction in transactions) {
        final lines = await isar.transactionLines
            .filter()
            .transactionIdEqualTo(transaction.id)
            .findAll();

        double transactionAmount = 0;
        for (final line in lines) {
          transactionAmount += line.lineAmount;
        }

        switch (transaction.type) {
          case TransactionType.sale:
            grossSales += transactionAmount;
            totalRevenue += transactionAmount;
            salesCount++;

            // Calculate COGS for this sale
            for (final line in lines) {
              final product = line.productId != null && line.productId != 0
                  ? await isar.collection<Product>().get(line.productId!)
                  : null;

              if (product != null) {
                // Use last cost or 0 if not available
                final costPrice = product.lastCost > 0 ? product.lastCost : 0;
                totalCOGS += costPrice * line.quantity;
              }
            }
            break;

          case TransactionType.purchase:
            totalPurchases += transactionAmount;
            purchaseCount++;
            break;

          case TransactionType.saleReturn:
            salesReturns += transactionAmount;
            totalRevenue -= transactionAmount;
            break;

          case TransactionType.purchaseReturn:
            totalPurchases -= transactionAmount;
            break;

          case TransactionType.expense:
            // Categorize expenses based on transaction notes or category
            final notes = transaction.notes?.toLowerCase() ?? '';
            if (notes.contains('admin') || notes.contains('office')) {
              adminExpenses += transactionAmount;
            } else if (notes.contains('sales') || notes.contains('marketing')) {
              sellingExpenses += transactionAmount;
            } else if (notes.contains('interest') || notes.contains('bank')) {
              financialExpenses += transactionAmount;
            } else {
              otherExpenses += transactionAmount;
            }
            break;

          default:
            break;
        }
      }

      // Get stock values (simplified - you may need to implement proper stock valuation)
      final products = await isar
          .collection<Product>()
          .where()
          .companyIdEqualTo(companyId)
          .findAll();

      double openingStock = 0;
      double closingStock = 0;

      for (final product in products) {
        // Calculate current stock using opening qty + stock movements
        final stockMovements = await isar.stockLedgers
            .filter()
            .companyIdEqualTo(companyId)
            .productIdEqualTo(product.id)
            .dateLessThan(end.add(const Duration(days: 1)))
            .findAll();

        double currentStock = product.openingQty;
        for (final movement in stockMovements) {
          currentStock += movement.quantityDelta;
        }

        // Use current stock * last cost for closing stock
        closingStock += (currentStock * product.lastCost);

        // For opening stock, calculate stock at the beginning of the period
        final openingMovements = await isar.stockLedgers
            .filter()
            .companyIdEqualTo(companyId)
            .productIdEqualTo(product.id)
            .dateLessThan(start)
            .findAll();

        double openingStockQty = product.openingQty;
        for (final movement in openingMovements) {
          openingStockQty += movement.quantityDelta;
        }
        openingStock += (openingStockQty * product.lastCost);
      }

      final totalExpenses =
          adminExpenses + sellingExpenses + financialExpenses + otherExpenses;
      final totalTransactions = transactions.length;
      final averageSale =
          salesCount > 0 ? (grossSales / salesCount).toDouble() : 0.0;
      final averagePurchase =
          purchaseCount > 0 ? (totalPurchases / purchaseCount).toDouble() : 0.0;

      return _ProfitLossData(
        totalRevenue: totalRevenue,
        grossSales: grossSales,
        salesReturns: salesReturns,
        totalPurchases: totalPurchases,
        totalCOGS: totalCOGS,
        directCosts: directCosts,
        openingStock: openingStock,
        closingStock: closingStock,
        adminExpenses: adminExpenses,
        sellingExpenses: sellingExpenses,
        financialExpenses: financialExpenses,
        otherExpenses: otherExpenses,
        totalExpenses: totalExpenses,
        salesCount: salesCount,
        purchaseCount: purchaseCount,
        totalTransactions: totalTransactions,
        averageSale: averageSale,
        averagePurchase: averagePurchase,
      );
    } catch (e) {
      rethrow;
    }
  }

  void _printReport() {
    // Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print functionality will be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ProfitLossData {
  final double totalRevenue;
  final double grossSales;
  final double salesReturns;
  final double totalPurchases;
  final double totalCOGS;
  final double directCosts;
  final double openingStock;
  final double closingStock;
  final double adminExpenses;
  final double sellingExpenses;
  final double financialExpenses;
  final double otherExpenses;
  final double totalExpenses;
  final int salesCount;
  final int purchaseCount;
  final int totalTransactions;
  final double averageSale;
  final double averagePurchase;

  _ProfitLossData({
    required this.totalRevenue,
    required this.grossSales,
    required this.salesReturns,
    required this.totalPurchases,
    required this.totalCOGS,
    required this.directCosts,
    required this.openingStock,
    required this.closingStock,
    required this.adminExpenses,
    required this.sellingExpenses,
    required this.financialExpenses,
    required this.otherExpenses,
    required this.totalExpenses,
    required this.salesCount,
    required this.purchaseCount,
    required this.totalTransactions,
    required this.averageSale,
    required this.averagePurchase,
  });
}
