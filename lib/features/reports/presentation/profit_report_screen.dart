import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/inventory_models.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/transaction_model.dart';

class ProfitReportScreen extends ConsumerStatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  ConsumerState<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends ConsumerState<ProfitReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showDetails = true;

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    final currentCompany = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Costing Report'),
        backgroundColor: Colors.purple.shade700,
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
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'profit_report',
      ),
      body: Column(
        children: [
          // Date filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => _setDateRange('today'),
                          child: const Text('Today'),
                        ),
                        TextButton(
                          onPressed: () => _setDateRange('week'),
                          child: const Text('This Week'),
                        ),
                        TextButton(
                          onPressed: () => _setDateRange('month'),
                          child: const Text('This Month'),
                        ),
                        TextButton(
                          onPressed: () => _setDateRange('year'),
                          child: const Text('This Year'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Report content
          Expanded(
            child: _buildProfitReport(currentCompany?.id),
          ),
        ],
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
        case 'year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31);
          break;
      }
    });
  }

  Widget _buildProfitReport(int? companyId) {
    if (companyId == null) {
      return const Center(child: Text('Please select a company'));
    }

    if (_startDate == null || _endDate == null) {
      return const Center(child: Text('Please select date range'));
    }

    final isar = ref.read(isarServiceProvider).isar;

    return FutureBuilder<_ProfitData>(
      future: _calculateProfit(isar, companyId, _startDate!, _endDate!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('No data available'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                _buildSummarySection(data),
                const SizedBox(height: 16),

                // Details
                if (_showDetails) ...[
                  _buildSalesSection(data),
                  const SizedBox(height: 16),
                  _buildPurchasesSection(data),
                  const SizedBox(height: 16),
                  _buildDetailedTransactions(data),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(_ProfitData data) {
    final grossProfit = data.totalSales - data.totalCost;
    final netProfit = grossProfit; // Can subtract expenses later
    final profitMargin =
        data.totalSales > 0 ? (grossProfit / data.totalSales * 100) : 0.0;

    return Card(
      elevation: 4,
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Total Sales', data.totalSales, Colors.green),
                _buildSummaryItem('Total Cost', data.totalCost, Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Gross Profit', grossProfit, Colors.blue),
                _buildSummaryItem('Profit Margin', profitMargin, Colors.purple,
                    suffix: '%'),
              ],
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: netProfit >= 0
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Profit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: netProfit >= 0
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                    ),
                  ),
                  Text(
                    'Rs. ${netProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: netProfit >= 0
                          ? Colors.green.shade900
                          : Colors.red.shade900,
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

  Widget _buildSummaryItem(String label, double value, Color color,
      {String suffix = ''}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suffix.isEmpty
                ? 'Rs. ${value.toStringAsFixed(2)}'
                : '${value.toStringAsFixed(2)}$suffix',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSection(_ProfitData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sales Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${data.salesCount} invoices',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Total Sales', data.totalSales, Colors.green),
            _buildDetailRow(
                'Avg Sale',
                data.salesCount > 0 ? data.totalSales / data.salesCount : 0,
                Colors.green.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasesSection(_ProfitData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Purchase Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${data.purchaseCount} invoices',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Total Purchases', data.totalCost, Colors.red),
            _buildDetailRow(
                'Avg Purchase',
                data.purchaseCount > 0
                    ? data.totalCost / data.purchaseCount
                    : 0,
                Colors.red.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            'Rs. ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTransactions(_ProfitData data) {
    if (data.invoiceDetails.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No transactions in this period'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...data.invoiceDetails.map((invoice) => _buildInvoiceCard(invoice)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(_InvoiceDetail invoice) {
    final profit = invoice.saleAmount - invoice.costAmount;
    final margin =
        invoice.saleAmount > 0 ? (profit / invoice.saleAmount * 100) : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: invoice.type == TransactionType.sale
          ? Colors.green.shade50
          : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.partyName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${invoice.referenceNo} • ${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: invoice.type == TransactionType.sale
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    invoice.type == TransactionType.sale ? 'SALE' : 'PURCHASE',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (invoice.type == TransactionType.sale) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sale: Rs. ${invoice.saleAmount.toStringAsFixed(2)}'),
                  Text('Cost: Rs. ${invoice.costAmount.toStringAsFixed(2)}'),
                  Text(
                    'Profit: Rs. ${profit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: profit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    'Margin: ${margin.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Purchase: Rs. ${invoice.costAmount.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<_ProfitData> _calculateProfit(
      Isar isar, int companyId, DateTime start, DateTime end) async {
    // Get all sales in the period
    final sales = await isar.transactions
        .filter()
        .companyIdEqualTo(companyId)
        .typeEqualTo(TransactionType.sale)
        .dateBetween(start, end.add(const Duration(days: 1)))
        .findAll();

    // Get all purchases in the period
    final purchases = await isar.transactions
        .filter()
        .companyIdEqualTo(companyId)
        .typeEqualTo(TransactionType.purchase)
        .dateBetween(start, end.add(const Duration(days: 1)))
        .findAll();

    double totalSales = 0;
    double totalCost = 0;
    final invoiceDetails = <_InvoiceDetail>[];

    // Process sales
    for (final sale in sales) {
      final lines = await isar.transactionLines
          .filter()
          .transactionIdEqualTo(sale.id)
          .findAll();

      double saleAmount = 0;
      double costAmount = 0;

      for (final line in lines) {
        saleAmount += line.lineAmount;

        // Calculate actual cost based on weighted average from purchases before this sale
        final product = line.productId != null && line.productId != 0
            ? await isar.collection<Product>().get(line.productId!)
            : null;

        if (product != null) {
          // Get all purchase movements for this product up to the sale date
          final purchaseMovements = await isar
              .collection<StockLedger>()
              .filter()
              .companyIdEqualTo(companyId)
              .productIdEqualTo(product.id)
              .movementTypeEqualTo(StockMovementType.inPurchase)
              .dateLessThan(sale.date.add(const Duration(days: 1)))
              .findAll();

          double totalCostValue = 0;
          double totalPurchaseQty = 0;

          // Calculate weighted average from actual purchases
          for (final movement in purchaseMovements) {
            if (movement.transactionId != null) {
              final purchaseLines = await isar
                  .collection<TransactionLine>()
                  .filter()
                  .transactionIdEqualTo(movement.transactionId!)
                  .productIdEqualTo(product.id)
                  .findAll();

              if (purchaseLines.isNotEmpty) {
                final purchaseLine = purchaseLines.first;
                totalCostValue +=
                    purchaseLine.unitPrice * movement.quantityDelta;
                totalPurchaseQty += movement.quantityDelta;
              }
            }
          }

          // Use weighted average cost if available, otherwise use lastCost
          double avgCost = totalPurchaseQty > 0
              ? totalCostValue / totalPurchaseQty
              : product.lastCost;

          costAmount += avgCost * line.quantity;
        }
      }

      totalSales += saleAmount;
      totalCost += costAmount;

      final party = sale.partyId != null && sale.partyId != 0
          ? await isar.collection<Party>().get(sale.partyId!)
          : null;
      invoiceDetails.add(_InvoiceDetail(
        type: TransactionType.sale,
        referenceNo: sale.referenceNo,
        date: sale.date,
        partyName: party?.name ?? 'Unknown',
        saleAmount: saleAmount,
        costAmount: costAmount,
      ));
    }

    // Process purchases (add to cost)
    for (final purchase in purchases) {
      final lines = await isar.transactionLines
          .filter()
          .transactionIdEqualTo(purchase.id)
          .findAll();

      double purchaseAmount = 0;
      for (final line in lines) {
        purchaseAmount += line.lineAmount;
      }

      final party = purchase.partyId != null && purchase.partyId != 0
          ? await isar.collection<Party>().get(purchase.partyId!)
          : null;
      invoiceDetails.add(_InvoiceDetail(
        type: TransactionType.purchase,
        referenceNo: purchase.referenceNo,
        date: purchase.date,
        partyName: party?.name ?? 'Unknown',
        saleAmount: 0,
        costAmount: purchaseAmount,
      ));
    }

    // Sort by date descending
    invoiceDetails.sort((a, b) => b.date.compareTo(a.date));

    return _ProfitData(
      totalSales: totalSales,
      totalCost: totalCost,
      salesCount: sales.length,
      purchaseCount: purchases.length,
      invoiceDetails: invoiceDetails,
    );
  }
}

class _ProfitData {
  final double totalSales;
  final double totalCost;
  final int salesCount;
  final int purchaseCount;
  final List<_InvoiceDetail> invoiceDetails;

  _ProfitData({
    required this.totalSales,
    required this.totalCost,
    required this.salesCount,
    required this.purchaseCount,
    required this.invoiceDetails,
  });
}

class _InvoiceDetail {
  final TransactionType type;
  final String referenceNo;
  final DateTime date;
  final String partyName;
  final double saleAmount;
  final double costAmount;

  _InvoiceDetail({
    required this.type,
    required this.referenceNo,
    required this.date,
    required this.partyName,
    required this.saleAmount,
    required this.costAmount,
  });
}
