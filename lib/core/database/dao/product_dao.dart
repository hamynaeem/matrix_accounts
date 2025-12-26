import 'package:isar/isar.dart';
import '../../../data/models/inventory_models.dart';

class ProductDao {
  final Isar isar;

  ProductDao(this.isar);

  Future<List<Product>> getAllByCompany(int companyId) async {
    return isar.products.filter().companyIdEqualTo(companyId).findAll();
  }
}
