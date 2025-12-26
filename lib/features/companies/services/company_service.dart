import 'package:isar/isar.dart';

import '../../../data/models/company_model.dart';

/// Service for managing company data in Isar database
class CompanyService {
  final Isar _isar;

  CompanyService(this._isar);

  /// Get all companies
  Future<List<Company>> getAllCompanies() async {
    return await _isar.companys.where().findAll();
  }

  /// Get all active companies
  Future<List<Company>> getActiveCompanies() async {
    return await _isar.companys.filter().isActiveEqualTo(true).findAll();
  }

  /// Get company by ID
  Future<Company?> getCompanyById(int id) async {
    return await _isar.companys.get(id);
  }

  /// Get company by name
  Future<Company?> getCompanyByName(String name) async {
    return await _isar.companys
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
  }

  /// Create a new company
  Future<Company> createCompany({
    required int subscriberId,
    required String name,
    String? primaryCurrency,
    int? financialYearStartMonth,
  }) async {
    // Check if company with same name already exists
    final existing = await getCompanyByName(name);
    if (existing != null) {
      throw Exception('Company with name "$name" already exists');
    }

    final company = Company()
      ..subscriberId = subscriberId
      ..name = name.trim()
      ..primaryCurrency = primaryCurrency ?? 'PKR'
      ..financialYearStartMonth = financialYearStartMonth ?? 7
      ..isActive = true
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.companys.put(company);
    });

    return company;
  }

  /// Update an existing company
  Future<Company> updateCompany({
    required int id,
    String? name,
    String? primaryCurrency,
    int? financialYearStartMonth,
    bool? isActive,
  }) async {
    final company = await getCompanyById(id);
    if (company == null) {
      throw Exception('Company with ID $id not found');
    }

    // If name is being changed, check for duplicates
    if (name != null && name.trim() != company.name) {
      final existing = await getCompanyByName(name);
      if (existing != null && existing.id != id) {
        throw Exception('Company with name "$name" already exists');
      }
      company.name = name.trim();
    }

    if (primaryCurrency != null) {
      company.primaryCurrency = primaryCurrency;
    }

    if (financialYearStartMonth != null) {
      company.financialYearStartMonth = financialYearStartMonth;
    }

    if (isActive != null) {
      company.isActive = isActive;
    }

    await _isar.writeTxn(() async {
      await _isar.companys.put(company);
    });

    return company;
  }

  /// Delete a company (soft delete by marking inactive)
  Future<void> softDeleteCompany(int id) async {
    await updateCompany(id: id, isActive: false);
  }

  /// Permanently delete a company
  Future<bool> deleteCompany(int id) async {
    bool deleted = false;
    await _isar.writeTxn(() async {
      deleted = await _isar.companys.delete(id);
    });
    return deleted;
  }

  /// Search companies by name
  Future<List<Company>> searchCompanies(String query) async {
    if (query.isEmpty) {
      return await getAllCompanies();
    }

    return await _isar.companys
        .filter()
        .nameContains(query, caseSensitive: false)
        .findAll();
  }

  /// Get count of companies
  Future<int> getCompanyCount() async {
    return await _isar.companys.count();
  }

  /// Get count of active companies
  Future<int> getActiveCompanyCount() async {
    return await _isar.companys.filter().isActiveEqualTo(true).count();
  }
}
