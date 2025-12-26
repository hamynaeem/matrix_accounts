import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/product_master_dao.dart';
import '../../../data/models/inventory_models.dart';

final productMasterDaoProvider = Provider<ProductMasterDao>((ref) {
  final isar = ref.read(isarServiceProvider).isar;
  return ProductMasterDao(isar);
});

final productListProvider = FutureProvider<List<Product>>((ref) async {
  final company = ref.read(currentCompanyProvider);
  if (company == null) return [];
  final dao = ref.read(productMasterDaoProvider);
  return dao.getProductsByCompany(company.id);
});

final productCategoryProvider = FutureProvider<List<ItemCategory>>((ref) async {
  final company = ref.read(currentCompanyProvider);
  if (company == null) return [];
  final dao = ref.read(productMasterDaoProvider);
  return dao.getCategories(company.id);
});

final productUnitProvider = FutureProvider<List<UnitOfMeasure>>((ref) async {
  final dao = ref.read(productMasterDaoProvider);
  return dao.getUnits();
});
