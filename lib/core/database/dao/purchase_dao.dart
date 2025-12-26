import 'package:isar/isar.dart';

import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/models/transaction_model.dart';
import 'account_dao.dart';
import 'sales_dao.dart' as sales; // For PaymentLineInput

class PurchaseDao {
  final Isar isar;
  final AccountDao _accountDao;

  PurchaseDao(this.isar) : _accountDao = AccountDao(isar);

  Future<Invoice?> getInvoiceById(int invoiceId) async {
    return await isar.invoices.get(invoiceId);
  }

  Future<Transaction?> getTransactionForInvoice(int invoiceId) async {
    final invoice = await isar.invoices.get(invoiceId);
    if (invoice == null) return null;
    return await isar.transactions.get(invoice.transactionId);
  }

  Future<List<TransactionLine>> getTransactionLines(int transactionId) async {
    return await isar.transactionLines
        .filter()
        .transactionIdEqualTo(transactionId)
        .findAll();
  }

  Future<void> createPurchaseInvoice({
    required int companyId,
    required Party supplier,
    required DateTime date,
    required String referenceNo,
    required List<PurchaseLineInput> lines,
    List<sales.PaymentLineInput>? paymentLines,
    int? userId,
  }) async {
    final transaction = Transaction()
      ..companyId = companyId
      ..type = TransactionType.purchase
      ..date = date
      ..referenceNo = referenceNo
      ..partyId = supplier.id
      ..totalAmount = lines.fold(0.0, (sum, l) => sum + (l.qty * l.rate))
      ..createdByUserId = userId;

    await isar.writeTxn(() async {
      final txnId = await isar.transactions.put(transaction);

      final invoice = Invoice()
        ..companyId = companyId
        ..transactionId = txnId
        ..invoiceType = InvoiceType.purchase
        ..partyId = supplier.id
        ..invoiceDate = date
        ..grandTotal = transaction.totalAmount
        ..status = 'Pending';

      final invoiceId = await isar.invoices.put(invoice);

      for (final l in lines) {
        final line = TransactionLine()
          ..transactionId = txnId
          ..productId = l.productId
          ..quantity = l.qty
          ..unitPrice = l.rate
          ..lineAmount = l.qty * l.rate;

        await isar.transactionLines.put(line);

        // Calculate unit cost for this purchase
        final unitCost = l.rate;
        final totalCost = l.qty * unitCost;

        final stock = StockLedger()
          ..companyId = companyId
          ..productId = l.productId
          ..date = date
          ..movementType = StockMovementType.inPurchase
          ..quantityDelta = l.qty // Positive for purchase
          ..unitCost = unitCost
          ..totalCost = totalCost
          ..transactionId = txnId
          ..invoiceId = invoiceId;

        await isar.stockLedgers.put(stock);
      }

      // Record accounting transaction - invoice amount
      await _accountDao.recordPurchaseInvoiceInternal(
        companyId: companyId,
        invoiceId: invoiceId,
        supplierId: supplier.id,
        supplierName: supplier.name,
        invoiceDate: date,
        invoiceNo: referenceNo,
        totalAmount: transaction.totalAmount,
      );

      // Record payment if provided
      if (paymentLines != null && paymentLines.isNotEmpty) {
        int microsecondsDelay = 0;
        for (final paymentLine in paymentLines) {
          final paymentAccount =
              await isar.paymentAccounts.get(paymentLine.paymentAccountId);
          if (paymentAccount == null) continue;

          // Determine account code based on account type
          String accountCode;
          if (paymentAccount.accountType == PaymentAccountType.cash) {
            accountCode = '1000';
          } else if (paymentAccount.accountType == PaymentAccountType.cheque) {
            accountCode = '1050';
          } else {
            accountCode = '1100'; // bank
          }

          // Add microsecond delay for unique timestamps
          await Future.delayed(Duration(microseconds: microsecondsDelay));
          microsecondsDelay += 1000;

          final paymentDate =
              date.add(Duration(microseconds: microsecondsDelay));

          await _accountDao.recordPurchaseInvoicePaymentInternal(
            companyId: companyId,
            invoiceId: invoiceId,
            supplierId: supplier.id,
            supplierName: supplier.name,
            paymentDate: paymentDate,
            invoiceNo: referenceNo,
            amount: paymentLine.amount,
            accountCode: accountCode,
          );
        }
      }
    });
  }

  Future<void> updatePurchaseInvoice({
    required int invoiceId,
    required int companyId,
    required Party supplier,
    required DateTime date,
    required String referenceNo,
    required List<PurchaseLineInput> lines,
    List<sales.PaymentLineInput>? paymentLines,
    int? userId,
  }) async {
    final invoice = await isar.invoices.get(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    final transactionId = invoice.transactionId;

    await isar.writeTxn(() async {
      // Update transaction
      final transaction = await isar.transactions.get(transactionId);
      if (transaction != null) {
        transaction.date = date;
        transaction.referenceNo = referenceNo;
        transaction.partyId = supplier.id;
        transaction.totalAmount =
            lines.fold(0.0, (sum, l) => sum + (l.qty * l.rate));
        await isar.transactions.put(transaction);
      }

      // Update invoice
      invoice.partyId = supplier.id;
      invoice.invoiceDate = date;
      invoice.grandTotal = lines.fold(0.0, (sum, l) => sum + (l.qty * l.rate));
      await isar.invoices.put(invoice);

      // Delete old transaction lines and stock ledger entries
      final oldLines = await isar.transactionLines
          .filter()
          .transactionIdEqualTo(transactionId)
          .findAll();

      for (final oldLine in oldLines) {
        await isar.transactionLines.delete(oldLine.id);
      }

      final oldStocks = await isar.stockLedgers
          .filter()
          .invoiceIdEqualTo(invoiceId)
          .findAll();

      for (final oldStock in oldStocks) {
        await isar.stockLedgers.delete(oldStock.id);
      }

      // Create new transaction lines and stock ledger entries
      for (final l in lines) {
        final line = TransactionLine()
          ..transactionId = transactionId
          ..productId = l.productId
          ..quantity = l.qty
          ..unitPrice = l.rate
          ..lineAmount = l.qty * l.rate;

        await isar.transactionLines.put(line);

        // Calculate unit cost for this purchase
        final unitCost = l.rate;
        final totalCost = l.qty * unitCost;

        final stock = StockLedger()
          ..companyId = companyId
          ..productId = l.productId
          ..date = date
          ..movementType = StockMovementType.inPurchase
          ..quantityDelta = l.qty // Positive for purchase
          ..unitCost = unitCost
          ..totalCost = totalCost
          ..transactionId = transactionId
          ..invoiceId = invoiceId;

        await isar.stockLedgers.put(stock);
      }

      // Delete ALL old accounting transactions related to this invoice
      await _accountDao.deletePurchaseInvoiceTransactionsInternal(invoiceId);

      // Record new invoice accounting
      final newTotal = lines.fold(0.0, (sum, l) => sum + (l.qty * l.rate));

      await _accountDao.recordPurchaseInvoiceInternal(
        companyId: companyId,
        invoiceId: invoiceId,
        supplierId: supplier.id,
        supplierName: supplier.name,
        invoiceDate: date,
        invoiceNo: referenceNo,
        totalAmount: newTotal,
      );

      // Record new payment accounting if provided
      if (paymentLines != null && paymentLines.isNotEmpty) {
        int microsecondsDelay = 0;
        for (final paymentLine in paymentLines) {
          final paymentAccount =
              await isar.paymentAccounts.get(paymentLine.paymentAccountId);
          if (paymentAccount == null) continue;

          // Determine account code based on account type
          String accountCode;
          if (paymentAccount.accountType == PaymentAccountType.cash) {
            accountCode = '1000';
          } else if (paymentAccount.accountType == PaymentAccountType.cheque) {
            accountCode = '1050';
          } else {
            accountCode = '1100'; // bank
          }

          // Add microsecond delay for unique timestamps
          await Future.delayed(Duration(microseconds: microsecondsDelay));
          microsecondsDelay += 1000;

          final paymentDate =
              date.add(Duration(microseconds: microsecondsDelay));

          await _accountDao.recordPurchaseInvoicePaymentInternal(
            companyId: companyId,
            invoiceId: invoiceId,
            supplierId: supplier.id,
            supplierName: supplier.name,
            paymentDate: paymentDate,
            invoiceNo: referenceNo,
            amount: paymentLine.amount,
            accountCode: accountCode,
          );
        }
      }

      // Update invoice grand total
      invoice.grandTotal = newTotal;
      await isar.invoices.put(invoice);
    });
  }

  Future<void> deletePurchaseInvoice(int invoiceId) async {
    await isar.writeTxn(() async {
      final invoice = await isar.invoices.get(invoiceId);
      if (invoice == null) return;

      // Delete accounting transactions
      await _accountDao.deletePurchaseInvoiceTransactionsInternal(invoiceId);

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

  // ========== PURCHASE RETURN METHODS ==========

  /// Create a purchase return transaction
  /// This reverses the accounting and stock for returned items
  Future<int> createPurchaseReturn({
    required int companyId,
    required int originalInvoiceId,
    required Party supplier,
    required DateTime returnDate,
    required String returnNo,
    required List<PurchaseReturnLineInput> returnLines,
    int? userId,
  }) async {
    int returnInvoiceId = 0;

    await isar.writeTxn(() async {
      // Get original invoice to verify
      final originalInvoice = await isar.invoices.get(originalInvoiceId);
      if (originalInvoice == null) {
        throw Exception('Original invoice not found');
      }

      // Calculate total return amount
      final totalAmount =
          returnLines.fold(0.0, (sum, l) => sum + (l.qty * l.rate));

      // Create return transaction
      final returnTransaction = Transaction()
        ..companyId = companyId
        ..type = TransactionType.purchaseReturn
        ..date = returnDate
        ..referenceNo = returnNo
        ..partyId = supplier.id
        ..totalAmount = totalAmount
        ..createdByUserId = userId;

      final returnTxnId = await isar.transactions.put(returnTransaction);

      // Create return invoice
      final returnInvoice = Invoice()
        ..companyId = companyId
        ..transactionId = returnTxnId
        ..invoiceType = InvoiceType.purchase
        ..partyId = supplier.id
        ..invoiceDate = returnDate
        ..grandTotal = totalAmount
        ..status = 'Return';

      returnInvoiceId = await isar.invoices.put(returnInvoice);

      // Create return lines
      for (final returnLine in returnLines) {
        final line = TransactionLine()
          ..transactionId = returnTxnId
          ..productId = returnLine.productId
          ..quantity = -returnLine.qty // Negative quantity for return
          ..unitPrice = returnLine.rate
          ..lineAmount = -(returnLine.qty * returnLine.rate);

        await isar.transactionLines.put(line);

        // Create negative stock entry (goods out of inventory)
        final stock = StockLedger()
          ..companyId = companyId
          ..productId = returnLine.productId
          ..date = returnDate
          ..movementType =
              StockMovementType.outAdjustment // Using adjustment for returns
          ..quantityDelta = -returnLine.qty // Negative for return
          ..unitCost = returnLine.rate
          ..totalCost = returnLine.qty * returnLine.rate
          ..transactionId = returnTxnId
          ..invoiceId = returnInvoiceId;

        await isar.stockLedgers.put(stock);
      }

      // Record purchase return accounting (reverses AP and Inventory)
      await _accountDao.recordPurchaseReturnInternal(
        companyId: companyId,
        returnInvoiceId: returnInvoiceId,
        supplierId: supplier.id,
        supplierName: supplier.name,
        returnDate: returnDate,
        returnNo: returnNo,
        returnAmount: totalAmount,
      );
    });

    return returnInvoiceId;
  }

  /// Delete a purchase return
  Future<void> deletePurchaseReturn(int returnInvoiceId) async {
    await isar.writeTxn(() async {
      final returnInvoice = await isar.invoices.get(returnInvoiceId);
      if (returnInvoice == null) return;

      // Delete stock ledger entries
      final stocks = await isar.stockLedgers
          .filter()
          .invoiceIdEqualTo(returnInvoiceId)
          .findAll();

      for (final stock in stocks) {
        await isar.stockLedgers.delete(stock.id);
      }

      // Delete transaction lines
      final lines = await isar.transactionLines
          .filter()
          .transactionIdEqualTo(returnInvoice.transactionId)
          .findAll();

      for (final line in lines) {
        await isar.transactionLines.delete(line.id);
      }

      // Delete accounting entries
      await _accountDao
          .deletePurchaseReturnTransactionsInternal(returnInvoiceId);

      // Delete transaction and invoice
      await isar.transactions.delete(returnInvoice.transactionId);
      await isar.invoices.delete(returnInvoiceId);
    });
  }
}

class PurchaseLineInput {
  final int productId;
  final double qty;
  final double rate;

  PurchaseLineInput({
    required this.productId,
    required this.qty,
    required this.rate,
  });
}

class PurchaseReturnLineInput {
  final int productId;
  final double qty;
  final double rate;

  PurchaseReturnLineInput({
    required this.productId,
    required this.qty,
    required this.rate,
  });
}
