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
        UnitOfMeasure()
          ..name = 'Liter'
          ..abbrev = 'L',
        UnitOfMeasure()
          ..name = 'Meter'
          ..abbrev = 'm',
        UnitOfMeasure()
          ..name = 'Box'
          ..abbrev = 'Box',
        UnitOfMeasure()
          ..name = 'Dozen'
          ..abbrev = 'Doz',
        UnitOfMeasure()
          ..name = 'Pack'
          ..abbrev = 'Pack',
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
      final customers = [
        Party()
          ..companyId = company.id
          ..name = 'Rajesh Kumar'
          ..partyType = PartyType.customer
          ..customerClass = CustomerClass.retailer
          ..phone = '+91 98765 43210'
          ..email = 'rajesh.kumar@example.com'
          ..address = '123, MG Road, Mumbai, Maharashtra - 400001'
          ..openingBalance = 0
          ..creditLimit = 50000
          ..paymentTermsDays = 30
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Priya Sharma'
          ..partyType = PartyType.customer
          ..customerClass = CustomerClass.wholesaler
          ..phone = '+91 98123 45678'
          ..email = 'priya.sharma@example.com'
          ..address = '456, Brigade Road, Bangalore, Karnataka - 560001'
          ..openingBalance = 5000
          ..creditLimit = 100000
          ..paymentTermsDays = 45
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Amit Patel'
          ..partyType = PartyType.customer
          ..customerClass = CustomerClass.retailer
          ..phone = '+91 97654 32109'
          ..email = 'amit.patel@example.com'
          ..address = '789, CG Road, Ahmedabad, Gujarat - 380009'
          ..openingBalance = -2000
          ..creditLimit = 30000
          ..paymentTermsDays = 15
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Sneha Reddy'
          ..partyType = PartyType.customer
          ..customerClass = CustomerClass.wholesaler
          ..phone = '+91 96543 21098'
          ..email = 'sneha.reddy@example.com'
          ..address = '321, Jubilee Hills, Hyderabad, Telangana - 500033'
          ..openingBalance = 0
          ..creditLimit = 75000
          ..paymentTermsDays = 30
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Vikram Singh'
          ..partyType = PartyType.customer
          ..customerClass = CustomerClass.retailer
          ..phone = '+91 95432 10987'
          ..email = 'vikram.singh@example.com'
          ..address = '654, Connaught Place, New Delhi - 110001'
          ..openingBalance = 1500
          ..creditLimit = 40000
          ..paymentTermsDays = 20
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Meera Iyer'
          ..partyType = PartyType.supplier
          ..customerClass = CustomerClass.other
          ..phone = '+91 94321 09876'
          ..email = 'meera.iyer@example.com'
          ..address = '987, T Nagar, Chennai, Tamil Nadu - 600017'
          ..openingBalance = 0
          ..creditLimit = 0
          ..paymentTermsDays = 30
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Arjun Mehta'
          ..partyType = PartyType.both
          ..customerClass = CustomerClass.wholesaler
          ..phone = '+91 93210 98765'
          ..email = 'arjun.mehta@example.com'
          ..address = '147, FC Road, Pune, Maharashtra - 411004'
          ..openingBalance = 3000
          ..creditLimit = 60000
          ..paymentTermsDays = 25
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Kavita Desai'
          ..partyType = PartyType.customer
          ..customerClass = CustomerClass.retailer
          ..phone = '+91 92109 87654'
          ..email = 'kavita.desai@example.com'
          ..address = '258, Park Street, Kolkata, West Bengal - 700016'
          ..openingBalance = 0
          ..creditLimit = 35000
          ..paymentTermsDays = 30
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Rahul Gupta'
          ..partyType = PartyType.customer
          ..customerClass = CustomerClass.wholesaler
          ..phone = '+91 91098 76543'
          ..email = 'rahul.gupta@example.com'
          ..address = '369, MI Road, Jaipur, Rajasthan - 302001'
          ..openingBalance = -1000
          ..creditLimit = 80000
          ..paymentTermsDays = 40
          ..createdAt = DateTime.now()
          ..isActive = true,
        Party()
          ..companyId = company.id
          ..name = 'Anita Joshi'
          ..partyType = PartyType.customer
          ..customerClass = CustomerClass.retailer
          ..phone = '+91 90987 65432'
          ..email = 'anita.joshi@example.com'
          ..address = '741, MG Road, Indore, Madhya Pradesh - 452001'
          ..openingBalance = 2500
          ..creditLimit = 45000
          ..paymentTermsDays = 30
          ..createdAt = DateTime.now()
          ..isActive = true,
      ];

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
          ..name = 'Electronics'
          ..parentCategoryId = null,
        ItemCategory()
          ..companyId = company.id
          ..name = 'Groceries'
          ..parentCategoryId = null,
        ItemCategory()
          ..companyId = company.id
          ..name = 'Stationery'
          ..parentCategoryId = null,
        ItemCategory()
          ..companyId = company.id
          ..name = 'Hardware'
          ..parentCategoryId = null,
        ItemCategory()
          ..companyId = company.id
          ..name = 'Clothing'
          ..parentCategoryId = null,
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

    final electronicsCategory = categories.firstWhere(
      (c) => c.name == 'Electronics',
      orElse: () => categories.first,
    );
    final groceriesCategory = categories.firstWhere(
      (c) => c.name == 'Groceries',
      orElse: () => categories.first,
    );
    final stationeryCategory = categories.firstWhere(
      (c) => c.name == 'Stationery',
      orElse: () => categories.first,
    );
    final hardwareCategory = categories.firstWhere(
      (c) => c.name == 'Hardware',
      orElse: () => categories.first,
    );
    final clothingCategory = categories.firstWhere(
      (c) => c.name == 'Clothing',
      orElse: () => categories.first,
    );
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
    final literUnit = units.firstWhere(
      (u) => u.abbrev == 'L',
      orElse: () => units.first,
    );
    final packUnit = units.firstWhere(
      (u) => u.abbrev == 'Pack',
      orElse: () => units.first,
    );
    final boxUnit = units.firstWhere(
      (u) => u.abbrev == 'Box',
      orElse: () => units.first,
    );

    await isar.writeTxn(() async {
      final products = [
        // Electronics
        Product()
          ..companyId = company.id
          ..sku = 'ELEC-001'
          ..name = 'LED Bulb 9W'
          ..categoryId = electronicsCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 120
          ..salePrice = 180
          ..openingQty = 100
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'ELEC-002'
          ..name = 'LED Tube Light 20W'
          ..categoryId = electronicsCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 250
          ..salePrice = 350
          ..openingQty = 50
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'ELEC-003'
          ..name = 'Table Fan 400mm'
          ..categoryId = electronicsCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 1200
          ..salePrice = 1650
          ..openingQty = 25
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'ELEC-004'
          ..name = 'Power Strip 6 Socket'
          ..categoryId = electronicsCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 350
          ..salePrice = 499
          ..openingQty = 40
          ..isActive = true,

        // Groceries
        Product()
          ..companyId = company.id
          ..sku = 'GROC-001'
          ..name = 'Basmati Rice Premium'
          ..categoryId = groceriesCategory.id
          ..uomId = kgUnit.id
          ..isTracked = true
          ..lastCost = 80
          ..salePrice = 110
          ..openingQty = 200
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'GROC-002'
          ..name = 'Wheat Flour'
          ..categoryId = groceriesCategory.id
          ..uomId = kgUnit.id
          ..isTracked = true
          ..lastCost = 35
          ..salePrice = 50
          ..openingQty = 500
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'GROC-003'
          ..name = 'Sugar White'
          ..categoryId = groceriesCategory.id
          ..uomId = kgUnit.id
          ..isTracked = true
          ..lastCost = 40
          ..salePrice = 55
          ..openingQty = 300
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'GROC-004'
          ..name = 'Cooking Oil Sunflower'
          ..categoryId = groceriesCategory.id
          ..uomId = literUnit.id
          ..isTracked = true
          ..lastCost = 150
          ..salePrice = 195
          ..openingQty = 80
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'GROC-005'
          ..name = 'Tea Leaves Premium'
          ..categoryId = groceriesCategory.id
          ..uomId = kgUnit.id
          ..isTracked = true
          ..lastCost = 280
          ..salePrice = 380
          ..openingQty = 50
          ..isActive = true,

        // Stationery
        Product()
          ..companyId = company.id
          ..sku = 'STAT-001'
          ..name = 'A4 Paper Ream (500 Sheets)'
          ..categoryId = stationeryCategory.id
          ..uomId = packUnit.id
          ..isTracked = true
          ..lastCost = 220
          ..salePrice = 299
          ..openingQty = 60
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'STAT-002'
          ..name = 'Blue Pen Box (10 pcs)'
          ..categoryId = stationeryCategory.id
          ..uomId = boxUnit.id
          ..isTracked = true
          ..lastCost = 45
          ..salePrice = 65
          ..openingQty = 100
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'STAT-003'
          ..name = 'Pencil Box (12 pcs)'
          ..categoryId = stationeryCategory.id
          ..uomId = boxUnit.id
          ..isTracked = true
          ..lastCost = 35
          ..salePrice = 50
          ..openingQty = 80
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'STAT-004'
          ..name = 'Notebook 200 Pages'
          ..categoryId = stationeryCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 55
          ..salePrice = 80
          ..openingQty = 150
          ..isActive = true,

        // Hardware
        Product()
          ..companyId = company.id
          ..sku = 'HARD-001'
          ..name = 'Hammer 500g'
          ..categoryId = hardwareCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 180
          ..salePrice = 250
          ..openingQty = 30
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'HARD-002'
          ..name = 'Screwdriver Set (6 pcs)'
          ..categoryId = hardwareCategory.id
          ..uomId = boxUnit.id
          ..isTracked = true
          ..lastCost = 320
          ..salePrice = 449
          ..openingQty = 20
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'HARD-003'
          ..name = 'Wood Screws Box (100 pcs)'
          ..categoryId = hardwareCategory.id
          ..uomId = boxUnit.id
          ..isTracked = true
          ..lastCost = 85
          ..salePrice = 120
          ..openingQty = 50
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'HARD-004'
          ..name = 'Measuring Tape 5m'
          ..categoryId = hardwareCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 95
          ..salePrice = 135
          ..openingQty = 40
          ..isActive = true,

        // Clothing
        Product()
          ..companyId = company.id
          ..sku = 'CLO-001'
          ..name = 'Cotton T-Shirt M'
          ..categoryId = clothingCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 250
          ..salePrice = 399
          ..openingQty = 75
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'CLO-002'
          ..name = 'Jeans Denim L'
          ..categoryId = clothingCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 650
          ..salePrice = 999
          ..openingQty = 45
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'CLO-003'
          ..name = 'Formal Shirt M'
          ..categoryId = clothingCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 450
          ..salePrice = 699
          ..openingQty = 35
          ..isActive = true,

        // Home & Kitchen
        Product()
          ..companyId = company.id
          ..sku = 'HOME-001'
          ..name = 'Dinner Plate Set (6 pcs)'
          ..categoryId = homeKitchenCategory.id
          ..uomId = boxUnit.id
          ..isTracked = true
          ..lastCost = 420
          ..salePrice = 599
          ..openingQty = 30
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'HOME-002'
          ..name = 'Stainless Steel Glass Set (6 pcs)'
          ..categoryId = homeKitchenCategory.id
          ..uomId = boxUnit.id
          ..isTracked = true
          ..lastCost = 280
          ..salePrice = 399
          ..openingQty = 40
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'HOME-003'
          ..name = 'Pressure Cooker 5L'
          ..categoryId = homeKitchenCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 1200
          ..salePrice = 1699
          ..openingQty = 15
          ..isActive = true,
        Product()
          ..companyId = company.id
          ..sku = 'HOME-004'
          ..name = 'Non-Stick Frying Pan'
          ..categoryId = homeKitchenCategory.id
          ..uomId = pcsUnit.id
          ..isTracked = true
          ..lastCost = 350
          ..salePrice = 499
          ..openingQty = 25
          ..isActive = true,
      ];

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
