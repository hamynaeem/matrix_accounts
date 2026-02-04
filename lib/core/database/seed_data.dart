// ignore_for_file: unused_local_variable, avoid_print

import 'package:isar/isar.dart';

import '../../data/models/company_model.dart';
import '../../data/models/inventory_models.dart';
import '../../data/models/party_model.dart';
import 'dao/account_dao.dart';

class SeedData {
  final Isar isar;

  SeedData(this.isar);

  Future<void> seedAll({bool force = false}) async {
    // Check if data already exists
    final existingCompanies = await isar.companys.count();
    if (existingCompanies > 0 && !force) {
      print('Seed data already exists, skipping...');
      return;
    }

    if (force) {
      print('Force seeding: Clearing existing data...');
      await clearAllData();
    }

    print('Seeding database...');

    await _seedUnitsOfMeasure();
    await _seedCompanies();
    await _seedCustomers();
    await _seedCategories();
    await _seedProducts();
    await _seedChartOfAccounts();

    print('Seed data created successfully!');
  }

  Future<void> _seedUnitsOfMeasure() async {
    await isar.writeTxn(() async {
      final units = [
        UnitOfMeasure()
          ..name = 'Piece'
          ..abbrev = 'Pcs',
        UnitOfMeasure()
          ..name = 'Kilogram'
          ..abbrev = 'Kg',
        UnitOfMeasure()
          ..name = 'Gram'
          ..abbrev = 'g',
      ];

      for (final unit in units) {
        await isar.unitOfMeasures.put(unit);
      }
    });

    print('✓ Units of measure seeded');
  }

  Future<void> _seedCompanies() async {
    await isar.writeTxn(() async {
      final companies = [
        Company()
          ..subscriberId = 1
          ..name = 'ABC Trading Co.'
          ..primaryCurrency = 'INR'
          ..financialYearStartMonth = 4
          ..createdAt = DateTime.now()
          ..isActive = true,
        Company()
          ..subscriberId = 1
          ..name = 'XYZ Enterprises'
          ..primaryCurrency = 'INR'
          ..financialYearStartMonth = 4
          ..createdAt = DateTime.now()
          ..isActive = true,
        Company()
          ..subscriberId = 1
          ..name = 'Demo Retail Store'
          ..primaryCurrency = 'INR'
          ..financialYearStartMonth = 4
          ..createdAt = DateTime.now()
          ..isActive = true,
      ];

      for (final company in companies) {
        await isar.companys.put(company);
      }
    });

    print('✓ Companies seeded');
  }

  Future<void> _seedCustomers() async {
    final companies = await isar.companys.where().findAll();
    if (companies.isEmpty) return;

    final company = companies.first;

    await isar.writeTxn(() async {
      final customers = <Party>[];

      for (final customer in customers) {
        await isar.partys.put(customer);
      }
    });

    print('✓ Customers seeded');
  }

  Future<void> _seedCategories() async {
    final companies = await isar.companys.where().findAll();
    if (companies.isEmpty) return;

    final company = companies.first;

    await isar.writeTxn(() async {
      final categories = [
        ItemCategory()
          ..companyId = company.id
          ..name = 'Home & Kitchen'
          ..parentCategoryId = null,
      ];

      for (final category in categories) {
        await isar.itemCategorys.put(category);
      }
    });

    print('✓ Categories seeded');
  }

  Future<void> _seedProducts() async {
    final companies = await isar.companys.where().findAll();
    if (companies.isEmpty) return;

    final company = companies.first;

    final categories = await isar.itemCategorys
        .filter()
        .companyIdEqualTo(company.id)
        .findAll();

    final units = await isar.unitOfMeasures.where().findAll();

    if (categories.isEmpty || units.isEmpty) return;

    final homeKitchenCategory = categories.firstWhere(
      (c) => c.name == 'Home & Kitchen',
      orElse: () => categories.first,
    );

    final pcsUnit = units.firstWhere(
      (u) => u.abbrev == 'Pcs',
      orElse: () => units.first,
    );
    final kgUnit = units.firstWhere(
      (u) => u.abbrev == 'Kg',
      orElse: () => units.first,
    );

    await isar.writeTxn(() async {
      final products = <Product>[];

      for (final product in products) {
        await isar.products.put(product);
      }
    });

    print('✓ Products seeded');
  }

  Future<void> _seedChartOfAccounts() async {
    final companies = await isar.companys.where().findAll();
    for (final company in companies) {
      final accountDao = AccountDao(isar);
      await accountDao.createDefaultAccounts(company.id);
    }
    print('✓ Chart of accounts seeded');
  }

  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.companys.clear();
      await isar.partys.clear();
      await isar.products.clear();
      await isar.itemCategorys.clear();
      await isar.unitOfMeasures.clear();
    });
    print('✓ All data cleared');
  }
}
