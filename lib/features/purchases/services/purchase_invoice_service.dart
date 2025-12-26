import 'package:isar/isar.dart';

import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/transaction_model.dart';

class PurchaseInvoiceService {
  final Isar isar;

  PurchaseInvoiceService(this.isar);

  // Get all purchase invoices for a company
  Future<List<Invoice>> getAllPurchaseInvoices(int companyId) async {
    return await isar.invoices
        .filter()
        .companyIdEqualTo(companyId)
        .invoiceTypeEqualTo(InvoiceType.purchase)
        .sortByInvoiceDateDesc()
        .findAll();
  }

  // Search purchase invoices
  Future<List<Invoice>> searchPurchaseInvoices(
      int companyId, String query) async {
    final allInvoices = await getAllPurchaseInvoices(companyId);

    if (query.isEmpty) return allInvoices;

    return allInvoices.where((invoice) {
      final partyName = isar.partys.getSync(invoice.partyId)?.name ?? '';
      final invoiceIdStr = invoice.id.toString();
      final lowerQuery = query.toLowerCase();

      return partyName.toLowerCase().contains(lowerQuery) ||
          invoiceIdStr.contains(lowerQuery);
    }).toList();
  }

  // Get purchase invoice by ID
  Future<Invoice?> getPurchaseInvoiceById(int invoiceId) async {
    return await isar.invoices.get(invoiceId);
  }

  // Get party (supplier) for invoice
  Future<Party?> getPartyForInvoice(int partyId) async {
    return await isar.partys.get(partyId);
  }

  // Get transaction for invoice
  Future<Transaction?> getTransactionForInvoice(int invoiceId) async {
    final invoice = await isar.invoices.get(invoiceId);
    if (invoice == null) return null;
    return await isar.transactions.get(invoice.transactionId);
  }

  // Get transaction lines for invoice
  Future<List<TransactionLine>> getTransactionLines(int transactionId) async {
    return await isar.transactionLines
        .filter()
        .transactionIdEqualTo(transactionId)
        .findAll();
  }

  // Delete purchase invoice
  Future<void> deletePurchaseInvoice(int invoiceId) async {
    await isar.writeTxn(() async {
      final invoice = await isar.invoices.get(invoiceId);
      if (invoice == null) return;

      // Delete stock ledger entries
      final stocks = await isar.stockLedgers
          .filter()
          .invoiceIdEqualTo(invoiceId)
          .findAll();

      for (final stock in stocks) {
        await isar.stockLedgers.delete(stock.id);
      }

      // Delete transaction lines
      final lines = await isar.transactionLines
          .filter()
          .transactionIdEqualTo(invoice.transactionId)
          .findAll();

      for (final line in lines) {
        await isar.transactionLines.delete(line.id);
      }

      // Delete transaction
      await isar.transactions.delete(invoice.transactionId);

      // Delete invoice
      await isar.invoices.delete(invoiceId);
    });
  }

  // Delete purchase return
  Future<void> deletePurchaseReturn(int returnId) async {
    // Use the same delete method - it's just an invoice
    await deletePurchaseInvoice(returnId);
  }
}
