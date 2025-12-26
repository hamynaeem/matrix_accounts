import 'package:isar/isar.dart';

part 'inventory_models.g.dart';

@collection
class UnitOfMeasure {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String name;

  late String abbrev;
}

@collection
class ItemCategory {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Index(caseSensitive: false)
  late String name;

  int? parentCategoryId;
}

@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Index(caseSensitive: false)
  late String sku;

  @Index(caseSensitive: false)
  late String name;

  int? categoryId;
  int? uomId;

  bool isTracked = true;

  double lastCost = 0;
  double salePrice = 0;

  double openingQty = 0;

  bool isActive = true;
}
