import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/product_dao.dart';
import '../../../core/database/dao/sales_dao.dart';
import '../../../data/models/inventory_models.dart';

final productDaoProvider = Provider<ProductDao>((ref) {
  final isar = ref.read(isarServiceProvider).isar;
  return ProductDao(isar);
});

final salesDaoProvider = Provider<SalesDao>((ref) {
  final isar = ref.read(isarServiceProvider).isar;
  return SalesDao(isar);
});

// Refresh trigger for product list
final productListRefreshProvider = StateProvider<int>((ref) => 0);

final productListProvider = FutureProvider<List<Product>>((ref) async {
  // Watch the refresh trigger to reload when it changes
  ref.watch(productListRefreshProvider);
  
  final company = ref.read(currentCompanyProvider);
  if (company == null) return [];
  final dao = ref.read(productDaoProvider);
  return dao.getAllByCompany(company.id);
});
