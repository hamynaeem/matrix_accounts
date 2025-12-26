import 'package:isar/isar.dart';

import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/models/transaction_model.dart';
import 'account_dao.dart';
import 'payment_dao.dart';

class SalesDao {
  final Isar isar;
  late final AccountDao _accountDao;
  late final PaymentDao _paymentDao;

  SalesDao(this.isar) {
    _accountDao = AccountDao(isar);
    _paymentDao = PaymentDao(isar);
  }

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

  Future<void> createSaleInvoice({
    required int companyId,
    required Party customer,
    required DateTime date,
    required String referenceNo,
    required List<SaleLineInput> lines,
    List<PaymentLineInput>? paymentLines, // NEW: payment lines
    int? userId,
  }) async {
    final transaction = Transaction()
      ..companyId = companyId
      ..type = TransactionType.sale
      ..date = date
      ..referenceNo = referenceNo
      ..partyId = customer.id
      ..totalAmount = lines.fold(0.0, (sum, l) => sum + (l.qty * l.rate))
      ..createdByUserId = userId;

    await isar.writeTxn(() async {
      final txnId = await isar.transactions.put(transaction);

      final invoice = Invoice()
        ..companyId = companyId
        ..transactionId = txnId
        ..invoiceType = InvoiceType.sale
        ..partyId = customer.id
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

        // Calculate COGS using weighted average cost
        final avgCost = await _calculateAverageCost(companyId, l.productId);
        final unitCost = avgCost;
        final totalCost = l.qty * unitCost;

        final stock = StockLedger()
          ..companyId = companyId
          ..productId = l.productId
          ..date = date
          ..movementType = StockMovementType.outSale
          ..quantityDelta = -l.qty
          ..unitCost = unitCost
          ..totalCost = totalCost
          ..transactionId = txnId
          ..invoiceId = invoiceId;

        await isar.stockLedgers.put(stock);
      }

      // Calculate total COGS for this sale
      double totalCOGS = 0;
      for (final l in lines) {
        final avgCost = await _calculateAverageCost(companyId, l.productId);
        totalCOGS += l.qty * avgCost;
      }

      // Record accounting transaction - invoice amount
      await _accountDao.recordSaleInvoiceInternal(
        companyId: companyId,
        invoiceId: invoiceId,
        customerId: customer.id,
        customerName: customer.name,
        invoiceDate: date,
        invoiceNo: referenceNo,
        totalAmount: transaction.totalAmount,
      );

      // Record COGS accounting
      if (totalCOGS > 0) {
        await _accountDao.recordCOGSInternal(
          companyId: companyId,
          invoiceId: invoiceId,
          saleDate: date,
          invoiceNo: referenceNo,
          cogsAmount: totalCOGS,
        );
      }

      // Record payment if provided
      if (paymentLines != null && paymentLines.isNotEmpty) {
        int microsecondsDelay = 0;
        for (final paymentLine in paymentLines) {
          if (paymentLine.amount <= 0) continue;

          // Get payment account to determine type
          final paymentAccount = await _paymentDao
              .getPaymentAccountById(paymentLine.paymentAccountId);
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

          await _accountDao.recordSaleInvoicePaymentInternal(
            companyId: companyId,
            invoiceId: invoiceId,
            customerId: customer.id,
            customerName: customer.name,
            paymentDate: paymentDate,
            invoiceNo: referenceNo,
            amount: paymentLine.amount,
            accountCode: accountCode,
          );
        }
      }
    });
  }

  Future<void> updateSaleInvoice({
    required int invoiceId,
    required int companyId,
    required Party customer,
    required DateTime date,
    required String referenceNo,
    required List<SaleLineInput> lines,
    List<PaymentLineInput>? paymentLines, // NEW: payment lines
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
        transaction.partyId = customer.id;
        transaction.totalAmount =
            lines.fold(0.0, (sum, l) => sum + (l.qty * l.rate));
        await isar.transactions.put(transaction);
      }

      // Update invoice
      invoice.partyId = customer.id;
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

        // Calculate COGS using weighted average cost
        final avgCost = await _calculateAverageCost(companyId, l.productId);
        final unitCost = avgCost;
        final totalCost = l.qty * unitCost;

        final stock = StockLedger()
          ..companyId = companyId
          ..productId = l.productId
          ..date = date
          ..movementType = StockMovementType.outSale
          ..quantityDelta = -l.qty
          ..unitCost = unitCost
          ..totalCost = totalCost
          ..transactionId = transactionId
          ..invoiceId = invoiceId;

        await isar.stockLedgers.put(stock);
      }

      // Delete ALL old accounting transactions related to this invoice
      await _accountDao.deleteSaleInvoiceTransactionsInternal(invoiceId);

      // Record new invoice accounting (DR AR, CR Sales)
      final newTotal = lines.fold(0.0, (sum, l) => sum + (l.qty * l.rate));

      await _accountDao.recordSaleInvoiceInternal(
        companyId: companyId,
        invoiceId: invoiceId,
        customerId: customer.id,
        customerName: customer.name,
        invoiceDate: date,
        invoiceNo: referenceNo,
        totalAmount: newTotal,
      );

      // Calculate and record COGS
      double totalCOGS = 0;
      for (final l in lines) {
        final avgCost = await _calculateAverageCost(companyId, l.productId);
        totalCOGS += l.qty * avgCost;
      }

      if (totalCOGS > 0) {
        await _accountDao.recordCOGSInternal(
          companyId: companyId,
          invoiceId: invoiceId,
          saleDate: date,
          invoiceNo: referenceNo,
          cogsAmount: totalCOGS,
        );
      }

      // Record new payment accounting if provided
      if (paymentLines != null && paymentLines.isNotEmpty) {
        int microsecondsDelay = 0;
        for (final paymentLine in paymentLines) {
          if (paymentLine.amount <= 0) continue;

          // Get payment account to determine type
          final paymentAccount = await _paymentDao
              .getPaymentAccountById(paymentLine.paymentAccountId);
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

          await _accountDao.recordSaleInvoicePaymentInternal(
            companyId: companyId,
            invoiceId: invoiceId,
            customerId: customer.id,
            customerName: customer.name,
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

  Future<void> deleteSaleInvoice(int invoiceId) async {
    await isar.writeTxn(() async {
      final invoice = await isar.invoices.get(invoiceId);
      if (invoice == null) return;

      // Delete accounting transactions
      await _accountDao.deleteSaleInvoiceTransactions(invoiceId);

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

  /// Calculate weighted average cost for a product based on purchase history
  Future<double> _calculateAverageCost(int companyId, int productId) async {
    // Get all purchase stock movements for this product
    final purchases = await isar.stockLedgers
        .filter()
        .companyIdEqualTo(companyId)
        .productIdEqualTo(productId)
        .movementTypeEqualTo(StockMovementType.inPurchase)
        .findAll();

    if (purchases.isEmpty) {
      return 0.0; // No purchase history, cost is 0
    }

    // Calculate weighted average cost
    double totalCost = 0;
    double totalQuantity = 0;

    for (final purchase in purchases) {
      totalCost += purchase.totalCost;
      totalQuantity += purchase.quantityDelta;
    }

    if (totalQuantity == 0) {
      return 0.0;
    }

    return totalCost / totalQuantity;
  }

  // ========== SALE RETURN METHODS ==========

  /// Create a sale return transaction
  /// This reverses the accounting and stock for returned items
  Future<int> createSaleReturn({
    required int companyId,
    required int originalInvoiceId,
    required Party customer,
    required DateTime returnDate,
    required String returnNo,
    required List<SaleReturnLineInput> returnLines,
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
        ..type = TransactionType.saleReturn
        ..date = returnDate
        ..referenceNo = returnNo
        ..partyId = customer.id
        ..totalAmount = totalAmount
        ..createdByUserId = userId;

      final returnTxnId = await isar.transactions.put(returnTransaction);

      // Create return invoice
      final returnInvoice = Invoice()
        ..companyId = companyId
        ..transactionId = returnTxnId
        ..invoiceType = InvoiceType.sale
        ..partyId = customer.id
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

        // Get average cost for COGS reversal
        final avgCost =
            await _calculateAverageCost(companyId, returnLine.productId);
        final unitCost = avgCost;
        final totalCost = returnLine.qty * unitCost;

        // Create positive stock entry (goods back in inventory)
        final stock = StockLedger()
          ..companyId = companyId
          ..productId = returnLine.productId
          ..date = returnDate
          ..movementType =
              StockMovementType.inAdjustment // Using adjustment for returns
          ..quantityDelta = returnLine.qty // Positive for return
          ..unitCost = unitCost
          ..totalCost = totalCost
          ..transactionId = returnTxnId
          ..invoiceId = returnInvoiceId;

        await isar.stockLedgers.put(stock);
      }

      // Calculate total COGS to reverse
      double totalCOGS = 0;
      for (final returnLine in returnLines) {
        final avgCost =
            await _calculateAverageCost(companyId, returnLine.productId);
        totalCOGS += returnLine.qty * avgCost;
      }

      // Record sale return accounting (reverses AR and Revenue)
      await _accountDao.recordSaleReturnInternal(
        companyId: companyId,
        returnInvoiceId: returnInvoiceId,
        customerId: customer.id,
        customerName: customer.name,
        returnDate: returnDate,
        returnNo: returnNo,
        returnAmount: totalAmount,
      );

      // Record COGS reversal (reverses COGS and increases Inventory)
      if (totalCOGS > 0) {
        await _accountDao.recordCOGSReversalInternal(
          companyId: companyId,
          returnInvoiceId: returnInvoiceId,
          returnDate: returnDate,
          returnNo: returnNo,
          cogsReversalAmount: totalCOGS,
        );
      }
    });

    return returnInvoiceId;
  }

  /// Delete a sale return
  Future<void> deleteSaleReturn(int returnInvoiceId) async {
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
      await _accountDao.deleteSaleReturnTransactionsInternal(returnInvoiceId);

      // Delete transaction and invoice
      await isar.transactions.delete(returnInvoice.transactionId);
      await isar.invoices.delete(returnInvoiceId);
    });
  }
}

class SaleLineInput {
  final int productId;
  final double qty;
  final double rate;

  SaleLineInput({
    required this.productId,
    required this.qty,
    required this.rate,
  });
}

class SaleReturnLineInput {
  final int productId;
  final double qty;
  final double rate;

  SaleReturnLineInput({
    required this.productId,
    required this.qty,
    required this.rate,
  });
}

class PaymentLineInput {
  final int paymentAccountId;
  final double amount;
  final String? referenceNo;

  PaymentLineInput({
    required this.paymentAccountId,
    required this.amount,
    this.referenceNo,
  });
}
