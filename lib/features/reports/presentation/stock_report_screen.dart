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

  @override
  Widget build(BuildContext context) {
    final currentCompany = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Report'),
        backgroundColor: Colors.green.shade700,
        actions: [
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
      future: _calculateStock(isar, companyId),
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
                      Text(
                        'SKU: ${item.sku}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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

  Future<List<_StockItem>> _calculateStock(Isar isar, int companyId) async {
    final products =
        await isar.products.filter().companyIdEqualTo(companyId).findAll();

    final stockItems = <_StockItem>[];

    for (final product in products) {
      // Get all stock movements for this product
      final stockMovements = await isar.stockLedgers
          .filter()
          .companyIdEqualTo(companyId)
          .productIdEqualTo(product.id)
          .sortByDate()
          .findAll();

      // Calculate current stock
      double currentStock = product.openingQty;
      for (final movement in stockMovements) {
        currentStock += movement.quantityDelta;
      }

      // Calculate weighted average cost from purchase transactions
      double avgCost = product.lastCost;
      double totalCostValue = 0;
      double totalPurchaseQty = 0;

      // Get all purchase movements for this product
      final purchaseMovements = stockMovements
          .where((m) => m.movementType == StockMovementType.inPurchase)
          .toList();

      for (final movement in purchaseMovements) {
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
            totalCostValue += line.unitPrice * movement.quantityDelta;
            totalPurchaseQty += movement.quantityDelta;
          }
        }
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
}

class _StockItem {
  final int productId;
  final String sku;
  final String productName;
  final bool isTracked;
  final double currentStock;
  final double avgCost;
  final double salePrice;

  _StockItem({
    required this.productId,
    required this.sku,
    required this.productName,
    required this.isTracked,
    required this.currentStock,
    required this.avgCost,
    required this.salePrice,
  });
}
