import 'package:isar/isar.dart';

import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';

/// Service for managing sales invoices
class SalesInvoiceService {
  final Isar _isar;

  SalesInvoiceService(this._isar);

  /// Get all sale invoices for a company
  Future<List<Invoice>> getAllSaleInvoices(int companyId) async {
    return await _isar.invoices
        .filter()
        .companyIdEqualTo(companyId)
        .invoiceTypeEqualTo(InvoiceType.sale)
        .sortByInvoiceDateDesc()
        .findAll();
  }

  /// Get sale invoice by ID
  Future<Invoice?> getSaleInvoiceById(int id) async {
    return await _isar.invoices.get(id);
  }

  /// Get party for an invoice
  Future<Party?> getPartyForInvoice(int partyId) async {
    return await _isar.partys.get(partyId);
  }

  /// Search sale invoices
  Future<List<Invoice>> searchSaleInvoices(
    int companyId,
    String query,
  ) async {
    if (query.isEmpty) {
      return await getAllSaleInvoices(companyId);
    }

    // Search by status or date
    return await _isar.invoices
        .filter()
        .companyIdEqualTo(companyId)
        .invoiceTypeEqualTo(InvoiceType.sale)
        .group((q) =>
            q.statusContains(query, caseSensitive: false).or().statusIsNull())
        .sortByInvoiceDateDesc()
        .findAll();
  }

  /// Get count of sale invoices
  Future<int> getSaleInvoiceCount(int companyId) async {
    return await _isar.invoices
        .filter()
        .companyIdEqualTo(companyId)
        .invoiceTypeEqualTo(InvoiceType.sale)
        .count();
  }

  /// Delete sale invoice
  Future<bool> deleteSaleInvoice(int id) async {
    bool deleted = false;
    await _isar.writeTxn(() async {
      deleted = await _isar.invoices.delete(id);
    });
    return deleted;
  }

  /// Get invoices by date range
  Future<List<Invoice>> getSaleInvoicesByDateRange(
    int companyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _isar.invoices
        .filter()
        .companyIdEqualTo(companyId)
        .invoiceTypeEqualTo(InvoiceType.sale)
        .invoiceDateBetween(startDate, endDate)
        .sortByInvoiceDateDesc()
        .findAll();
  }

  /// Get invoices by status
  Future<List<Invoice>> getSaleInvoicesByStatus(
    int companyId,
    String status,
  ) async {
    return await _isar.invoices
        .filter()
        .companyIdEqualTo(companyId)
        .invoiceTypeEqualTo(InvoiceType.sale)
        .statusEqualTo(status, caseSensitive: false)
        .sortByInvoiceDateDesc()
        .findAll();
  }

  /// Delete sale return
  Future<bool> deleteSaleReturn(int returnId) async {
    // Use the same delete method - it's just an invoice
    return await deleteSaleInvoice(returnId);
  }
}
