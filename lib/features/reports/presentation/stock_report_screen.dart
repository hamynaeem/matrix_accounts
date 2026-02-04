// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/inventory_models.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/transaction_model.dart';

class StockReportScreen extends ConsumerStatefulWidget {
  const StockReportScreen({super.key});

  @override
  ConsumerState<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends ConsumerState<StockReportScreen> {
  String _searchQuery = '';
  bool _showOnlyTracked = true;
  bool _showOnlyInStock = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _dateFilterEnabled = false;

  @override
  Widget build(BuildContext context) {
    final currentCompany = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Report'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(_dateFilterEnabled
                ? Icons.date_range
                : Icons.date_range_outlined),
            tooltip:
                _dateFilterEnabled ? 'Clear Date Filter' : 'Filter by Date',
            onPressed: () {
              if (_dateFilterEnabled) {
                setState(() {
                  _dateFilterEnabled = false;
                  _fromDate = null;
                  _toDate = null;
                });
              } else {
                _showDateFilterDialog();
              }
            },
          ),
          IconButton(
            icon: Icon(_showOnlyTracked
                ? Icons.inventory
                : Icons.inventory_2_outlined),
            tooltip:
                _showOnlyTracked ? 'Show All Products' : 'Show Tracked Only',
            onPressed: () {
              setState(() {
                _showOnlyTracked = !_showOnlyTracked;
              });
            },
          ),
          IconButton(
            icon: Icon(_showOnlyInStock
                ? Icons.check_box
                : Icons.check_box_outline_blank),
            tooltip: _showOnlyInStock ? 'Show All' : 'Show In Stock Only',
            onPressed: () {
              setState(() {
                _showOnlyInStock = !_showOnlyInStock;
              });
            },
          ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'stock_report',
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Date filter display
          if (_dateFilterEnabled) _buildDateFilterDisplay(),

          // Stock list
          Expanded(
            child: _buildStockList(currentCompany?.id),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList(int? companyId) {
    if (companyId == null) {
      return const Center(child: Text('Please select a company'));
    }

    final isar = ref.read(isarServiceProvider).isar;

    return FutureBuilder<List<_StockItem>>(
      future: _calculateStock(isar, companyId, _fromDate, _toDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var stockItems = snapshot.data ?? [];

        // Apply filters
        if (_searchQuery.isNotEmpty) {
          stockItems = stockItems.where((item) {
            return item.productName.toLowerCase().contains(_searchQuery) ||
                item.sku.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (_showOnlyTracked) {
          stockItems = stockItems.where((item) => item.isTracked).toList();
        }

        if (_showOnlyInStock) {
          stockItems =
              stockItems.where((item) => item.currentStock > 0).toList();
        }

        if (stockItems.isEmpty) {
          return const Center(
            child: Text('No products found'),
          );
        }

        // Calculate totals
        final totalStockValue = stockItems.fold<double>(
          0,
          (sum, item) => sum + (item.currentStock * item.avgCost),
        );
        final totalSaleValue = stockItems.fold<double>(
          0,
          (sum, item) => sum + (item.currentStock * item.salePrice),
        );

        return Column(
          children: [
            // Summary Cards
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Stock Value',
                      'Rs. ${totalStockValue.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Potential Sale Value',
                      'Rs. ${totalSaleValue.toStringAsFixed(2)}',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Stock items list
            Expanded(
              child: ListView.builder(
                itemCount: stockItems.length,
                itemBuilder: (context, index) {
                  final item = stockItems[index];
                  return _buildStockCard(item);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(_StockItem item) {
    final stockValue = item.currentStock * item.avgCost;
    final saleValue = item.currentStock * item.salePrice;
    final potentialProfit = saleValue - stockValue;

    Color stockColor = Colors.green;
    if (item.currentStock <= 0) {
      stockColor = Colors.red;
    } else if (item.currentStock <= 10) {
      stockColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: stockColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: stockColor),
                  ),
                  child: Text(
                    '${item.currentStock.toStringAsFixed(2)} units',
                    style: TextStyle(
                      color: stockColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Purchase and Sale quantities row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailColumn(
                  'Total Purchased',
                  '${item.totalPurchaseQty.toStringAsFixed(2)} units',
                  color: Colors.green.shade700,
                ),
                _buildDetailColumn(
                  'Total Sold',
                  '${item.totalSaleQty.toStringAsFixed(2)} units',
                  color: Colors.red.shade700,
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn(
                    'Avg Cost', 'Rs. ${item.avgCost.toStringAsFixed(2)}'),
                _buildDetailColumn(
                    'Sale Price', 'Rs. ${item.salePrice.toStringAsFixed(2)}'),
                _buildDetailColumn(
                    'Stock Value', 'Rs. ${stockValue.toStringAsFixed(2)}'),
                _buildDetailColumn(
                  'Potential Profit',
                  'Rs. ${potentialProfit.toStringAsFixed(2)}',
                  color: potentialProfit >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<List<_StockItem>> _calculateStock(
      Isar isar, int companyId, DateTime? fromDate, DateTime? toDate) async {
    final products =
        await isar.products.filter().companyIdEqualTo(companyId).findAll();

    final stockItems = <_StockItem>[];

    for (final product in products) {
      // Get stock movements for this product with date filtering
      var query = isar.stockLedgers
          .filter()
          .companyIdEqualTo(companyId)
          .productIdEqualTo(product.id);

      if (fromDate != null) {
        query =
            query.dateGreaterThan(fromDate.subtract(const Duration(days: 1)));
      }
      if (toDate != null) {
        query = query.dateLessThan(toDate.add(const Duration(days: 1)));
      }

      final stockMovements = await query.sortByDate().findAll();

      // Calculate current stock
      double currentStock = product.openingQty;
      for (final movement in stockMovements) {
        currentStock += movement.quantityDelta;
      }

      // Calculate weighted average cost from purchase transactions
      double avgCost = product.lastCost;
      double totalCostValue = 0;
      double totalPurchaseQty = 0;
      double totalSaleQty = 0;

      // Get all purchase movements for this product
      final purchaseMovements = stockMovements
          .where((m) => m.movementType == StockMovementType.inPurchase)
          .toList();

      // Get all sale movements for this product
      final saleMovements = stockMovements
          .where((m) => m.movementType == StockMovementType.outSale)
          .toList();

      // Calculate total purchase quantity
      for (final movement in purchaseMovements) {
        totalPurchaseQty +=
            movement.quantityDelta.abs(); // Use abs to ensure positive value

        // Get the transaction line to get the actual purchase price
        if (movement.transactionId != null) {
          final transactionLines = await isar
              .collection<TransactionLine>()
              .filter()
              .transactionIdEqualTo(movement.transactionId!)
              .productIdEqualTo(product.id)
              .findAll();

          if (transactionLines.isNotEmpty) {
            final line = transactionLines.first;
            totalCostValue += line.unitPrice * movement.quantityDelta.abs();
          }
        }
      }

      // Calculate total sale quantity
      for (final movement in saleMovements) {
        totalSaleQty +=
            movement.quantityDelta.abs(); // Use abs to ensure positive value
      }

      // Calculate weighted average if we have purchase data
      if (totalPurchaseQty > 0) {
        avgCost = totalCostValue / totalPurchaseQty;
      } else if (product.openingQty > 0) {
        // Use lastCost if no purchases yet but has opening stock
        avgCost = product.lastCost;
      }

      stockItems.add(_StockItem(
        productId: product.id,
        sku: product.sku,
        productName: product.name,
        isTracked: product.isTracked,
        currentStock: currentStock,
        avgCost: avgCost,
        salePrice: product.salePrice,
        totalPurchaseQty: totalPurchaseQty,
        totalSaleQty: totalSaleQty,
      ));
    }

    // Sort by stock value descending
    stockItems.sort((a, b) {
      final valueA = a.currentStock * a.avgCost;
      final valueB = b.currentStock * b.avgCost;
      return valueB.compareTo(valueA);
    });

    return stockItems;
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempFromDate = _fromDate;
        DateTime? tempToDate = _toDate;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter by Date Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      tempFromDate == null
                          ? 'From Date: Not selected'
                          : 'From Date: ${tempFromDate!.day}/${tempFromDate!.month}/${tempFromDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempFromDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          tempFromDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      tempToDate == null
                          ? 'To Date: Not selected'
                          : 'To Date: ${tempToDate!.day}/${tempToDate!.month}/${tempToDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempToDate ?? DateTime.now(),
                        firstDate: tempFromDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          tempToDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _fromDate = tempFromDate;
                      _toDate = tempToDate;
                      _dateFilterEnabled =
                          tempFromDate != null || tempToDate != null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateFilterDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Date Filter: ${_fromDate != null ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}' : 'All'} - ${_toDate != null ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}' : 'All'}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.blue, size: 20),
            onPressed: () {
              setState(() {
                _dateFilterEnabled = false;
                _fromDate = null;
                _toDate = null;
              });
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _StockItem {
  final int productId;
  final String sku;
  final String productName;
  final bool isTracked;
  final double currentStock;
  final double avgCost;
  final double salePrice;
  final double totalPurchaseQty;
  final double totalSaleQty;

  _StockItem({
    required this.productId,
    required this.sku,
    required this.productName,
    required this.isTracked,
    required this.currentStock,
    required this.avgCost,
    required this.salePrice,
    required this.totalPurchaseQty,
    required this.totalSaleQty,
  });
}
