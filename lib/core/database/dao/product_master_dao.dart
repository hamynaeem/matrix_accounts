import 'package:isar/isar.dart';

import '../../../data/models/inventory_models.dart';
import '../../../data/models/invoice_stock_models.dart';

class ProductMasterDao {
  final Isar isar;

  ProductMasterDao(this.isar);

  Future<void> saveProduct(Product product) async {
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
  }

  Future<List<Product>> getProductsByCompany(int companyId) async {
    return isar.products.filter().companyIdEqualTo(companyId).findAll();
  }

  Future<void> saveCategory(ItemCategory category) async {
    await isar.writeTxn(() async {
      await isar.itemCategorys.put(category);
    });
  }

  Future<List<ItemCategory>> getCategories(int companyId) async {
    return isar.itemCategorys
        .filter()
        .companyIdEqualTo(companyId)
        .findAll();
  }

  Future<void> saveUnit(UnitOfMeasure unit) async {
    await isar.writeTxn(() async {
      await isar.unitOfMeasures.put(unit);
    });
  }

  Future<List<UnitOfMeasure>> getUnits() async {
    return isar.unitOfMeasures.where().findAll();
  }

  Future<void> insertOpeningStock({
    required int companyId,
    required int productId,
    required double qty,
  }) async {
    if (qty == 0) return;

    final stock = StockLedger()
      ..companyId = companyId
      ..productId = productId
      ..date = DateTime.now()
      ..movementType = StockMovementType.inAdjustment
      ..quantityDelta = qty;

    await isar.writeTxn(() async {
      await isar.stockLedgers.put(stock);
    });
  }
}
