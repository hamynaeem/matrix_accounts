import 'package:isar/isar.dart';

import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import 'account_dao.dart';

class PaymentDao {
  final Isar isar;
  late final AccountDao _accountDao;

  PaymentDao(this.isar) {
    _accountDao = AccountDao(isar);
  }

  // Payment Account Methods
  Future<void> createDefaultAccounts(int companyId) async {
    final existingCash = await isar.paymentAccounts
        .filter()
        .companyIdEqualTo(companyId)
        .accountTypeEqualTo(PaymentAccountType.cash)
        .isDefaultEqualTo(true)
        .findFirst();

    if (existingCash == null) {
      await isar.writeTxn(() async {
        // Create Cash account
        final cash = PaymentAccount()
          ..companyId = companyId
          ..accountType = PaymentAccountType.cash
          ..accountName = 'Cash'
          ..icon = '💵'
          ..isActive = true
          ..isDefault = true
          ..createdAt = DateTime.now();
        await isar.paymentAccounts.put(cash);

        // Create Cheque account
        final cheque = PaymentAccount()
          ..companyId = companyId
          ..accountType = PaymentAccountType.cheque
          ..accountName = 'Cheque'
          ..icon = '📝'
          ..isActive = true
          ..isDefault = true
          ..createdAt = DateTime.now();
        await isar.paymentAccounts.put(cheque);
      });
    }
  }

  Future<List<PaymentAccount>> getPaymentAccounts(int companyId) async {
    return await isar.paymentAccounts
        .filter()
        .companyIdEqualTo(companyId)
        .isActiveEqualTo(true)
        .sortByIsDefaultDesc()
        .thenByAccountName()
        .findAll();
  }

  Future<PaymentAccount?> getPaymentAccountById(int id) async {
    return await isar.paymentAccounts.get(id);
  }

  Future<void> createPaymentAccount({
    required int companyId,
    required PaymentAccountType accountType,
    required String accountName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? icon,
  }) async {
    await isar.writeTxn(() async {
      final account = PaymentAccount()
        ..companyId = companyId
        ..accountType = accountType
        ..accountName = accountName
        ..bankName = bankName
        ..accountNumber = accountNumber
        ..ifscCode = ifscCode
        ..icon = icon ??
            (accountType == PaymentAccountType.cash
                ? '💵'
                : accountType == PaymentAccountType.cheque
                    ? '📝'
                    : '🏦')
        ..isActive = true
        ..isDefault = false
        ..createdAt = DateTime.now();

      await isar.paymentAccounts.put(account);
    });
  }

  Future<void> updatePaymentAccount({
    required int accountId,
    required String accountName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? icon,
  }) async {
    await isar.writeTxn(() async {
      final account = await isar.paymentAccounts.get(accountId);
      if (account != null && !account.isDefault) {
        account.accountName = accountName;
        account.bankName = bankName;
        account.accountNumber = accountNumber;
        account.ifscCode = ifscCode;
        if (icon != null) account.icon = icon;
        account.updatedAt = DateTime.now();
        await isar.paymentAccounts.put(account);
      }
    });
  }

  Future<void> deletePaymentAccount(int accountId) async {
    await isar.writeTxn(() async {
      final account = await isar.paymentAccounts.get(accountId);
      if (account != null && !account.isDefault) {
        account.isActive = false;
        account.updatedAt = DateTime.now();
        await isar.paymentAccounts.put(account);
      }
    });
  }

  // Get account balance (total received in this account)
  Future<double> getAccountBalance(int accountId, int companyId) async {
    final lines = await isar.paymentInLines
        .filter()
        .paymentAccountIdEqualTo(accountId)
        .findAll();

    double total = 0;
    for (final line in lines) {
      final payment = await isar.paymentIns.get(line.paymentInId);
      if (payment != null && payment.companyId == companyId) {
        total += line.amount;
      }
    }
    return total;
  }

  // Payment In Methods
  Future<List<PaymentIn>> getPaymentIns(int companyId) async {
    return await isar.paymentIns
        .filter()
        .companyIdEqualTo(companyId)
        .sortByReceiptDateDesc()
        .findAll();
  }

  Future<PaymentIn?> getPaymentInById(int id) async {
    return await isar.paymentIns.get(id);
  }

  Future<List<PaymentInLine>> getPaymentInLines(int paymentInId) async {
    return await isar.paymentInLines
        .filter()
        .paymentInIdEqualTo(paymentInId)
        .findAll();
  }

  Future<void> createPaymentIn({
    required int companyId,
    required Party customer,
    required DateTime receiptDate,
    required String receiptNo,
    required List<PaymentLineInput> lines,
    String? description,
    String? attachmentPath,
    int? userId,
  }) async {
    await isar.writeTxn(() async {
      final totalAmount = lines.fold(0.0, (sum, l) => sum + l.amount);

      final payment = PaymentIn()
        ..companyId = companyId
        ..receiptNo = receiptNo
        ..receiptDate = receiptDate
        ..partyId = customer.id
        ..totalAmount = totalAmount
        ..description = description
        ..attachmentPath = attachmentPath
        ..createdAt = DateTime.now()
        ..createdByUserId = userId;

      final paymentId = await isar.paymentIns.put(payment);

      // Add small delays to ensure unique timestamps for proper ordering
      int microsecondsDelay = 0;

      for (final l in lines) {
        final line = PaymentInLine()
          ..paymentInId = paymentId
          ..paymentAccountId = l.accountId
          ..amount = l.amount
          ..referenceNo = l.referenceNo
          ..createdAt = DateTime.now();

        await isar.paymentInLines.put(line);

        // Record accounting transaction for EACH payment line
        final paymentAccount = await isar.paymentAccounts.get(l.accountId);
        if (paymentAccount != null) {
          // Determine account code based on payment account type
          String accountCode;
          if (paymentAccount.accountType == PaymentAccountType.cash) {
            accountCode = '1000'; // Cash account
          } else if (paymentAccount.accountType == PaymentAccountType.cheque) {
            accountCode = '1050'; // Cheque account
          } else {
            accountCode = '1100'; // Bank account
          }

          // Add microsecond delay to ensure unique timestamps
          await Future.delayed(Duration(microseconds: microsecondsDelay));
          microsecondsDelay += 1000; // 1 millisecond between each

          await _accountDao.recordPaymentInInternal(
            companyId: companyId,
            paymentId: paymentId,
            customerId: customer.id,
            customerName: customer.name,
            paymentDate:
                receiptDate.add(Duration(microseconds: microsecondsDelay)),
            receiptNo: receiptNo,
            amount: l.amount, // Use individual line amount, not total
            accountCode: accountCode,
          );
        }
      }
    });
  }

  Future<void> updatePaymentIn({
    required int paymentInId,
    required int companyId,
    required Party customer,
    required DateTime receiptDate,
    required String receiptNo,
    required List<PaymentLineInput> lines,
    String? description,
    String? attachmentPath,
    int? userId,
  }) async {
    await isar.writeTxn(() async {
      final payment = await isar.paymentIns.get(paymentInId);
      if (payment == null) return;

      final totalAmount = lines.fold(0.0, (sum, l) => sum + l.amount);

      payment.receiptNo = receiptNo;
      payment.receiptDate = receiptDate;
      payment.partyId = customer.id;
      payment.totalAmount = totalAmount;
      payment.description = description;
      payment.attachmentPath = attachmentPath;
      payment.updatedAt = DateTime.now();

      await isar.paymentIns.put(payment);

      // Delete old lines
      final oldLines = await isar.paymentInLines
          .filter()
          .paymentInIdEqualTo(paymentInId)
          .findAll();

      for (final oldLine in oldLines) {
        await isar.paymentInLines.delete(oldLine.id);
      }

      // Delete all old accounting transactions for this payment
      await _accountDao.deletePaymentInTransactionsInternal(paymentInId);

      // Create new lines and accounting transactions
      for (final l in lines) {
        final line = PaymentInLine()
          ..paymentInId = paymentInId
          ..paymentAccountId = l.accountId
          ..amount = l.amount
          ..referenceNo = l.referenceNo
          ..createdAt = DateTime.now();

        await isar.paymentInLines.put(line);

        // Record accounting transaction for EACH payment line
        final paymentAccount = await isar.paymentAccounts.get(l.accountId);
        if (paymentAccount != null) {
          // Determine account code based on payment account type
          String accountCode;
          if (paymentAccount.accountType == PaymentAccountType.cash) {
            accountCode = '1000'; // Cash account
          } else if (paymentAccount.accountType == PaymentAccountType.cheque) {
            accountCode = '1050'; // Cheque account
          } else {
            accountCode = '1100'; // Bank account
          }

          await _accountDao.recordPaymentInInternal(
            companyId: companyId,
            paymentId: paymentInId,
            customerId: customer.id,
            customerName: customer.name,
            paymentDate: receiptDate,
            receiptNo: receiptNo,
            amount: l.amount, // Use individual line amount
            accountCode: accountCode,
          );
        }
      }
    });
  }

  Future<void> deletePaymentIn(int paymentInId) async {
    await isar.writeTxn(() async {
      // Delete accounting transactions first
      await _accountDao.deletePaymentInTransactionsInternal(paymentInId);

      // Delete lines
      final lines = await isar.paymentInLines
          .filter()
          .paymentInIdEqualTo(paymentInId)
          .findAll();

      for (final line in lines) {
        await isar.paymentInLines.delete(line.id);
      }

      // Delete payment
      await isar.paymentIns.delete(paymentInId);
    });
  }

  // Get party balance (total received from customer)
  Future<double> getPartyReceivedBalance(int partyId, int companyId) async {
    final payments = await isar.paymentIns
        .filter()
        .companyIdEqualTo(companyId)
        .partyIdEqualTo(partyId)
        .findAll();

    return payments.fold<double>(0.0, (sum, p) => sum + p.totalAmount);
  }

  // Payment Out Methods
  Future<List<PaymentOut>> getPaymentOuts(int companyId) async {
    return await isar.paymentOuts
        .filter()
        .companyIdEqualTo(companyId)
        .sortByVoucherDateDesc()
        .findAll();
  }

  Future<PaymentOut?> getPaymentOutById(int id) async {
    return await isar.paymentOuts.get(id);
  }

  Future<List<PaymentOutLine>> getPaymentOutLines(int paymentOutId) async {
    return await isar.paymentOutLines
        .filter()
        .paymentOutIdEqualTo(paymentOutId)
        .findAll();
  }

  Future<void> createPaymentOut({
    required int companyId,
    required Party supplier,
    required DateTime voucherDate,
    required String voucherNo,
    required List<PaymentLineInput> lines,
    String? description,
    String? attachmentPath,
    int? userId,
  }) async {
    await isar.writeTxn(() async {
      final totalAmount = lines.fold(0.0, (sum, l) => sum + l.amount);

      final payment = PaymentOut()
        ..companyId = companyId
        ..voucherNo = voucherNo
        ..voucherDate = voucherDate
        ..partyId = supplier.id
        ..totalAmount = totalAmount
        ..description = description
        ..attachmentPath = attachmentPath
        ..createdAt = DateTime.now()
        ..createdByUserId = userId;

      final paymentId = await isar.paymentOuts.put(payment);

      // Add small delays to ensure unique timestamps for proper ordering
      int microsecondsDelay = 0;

      for (final l in lines) {
        final line = PaymentOutLine()
          ..paymentOutId = paymentId
          ..paymentAccountId = l.accountId
          ..amount = l.amount
          ..referenceNo = l.referenceNo
          ..createdAt = DateTime.now();

        await isar.paymentOutLines.put(line);

        // Record accounting transaction for EACH payment line
        final paymentAccount = await isar.paymentAccounts.get(l.accountId);
        if (paymentAccount != null) {
          // Determine account code based on payment account type
          String accountCode;
          if (paymentAccount.accountType == PaymentAccountType.cash) {
            accountCode = '1000'; // Cash account
          } else if (paymentAccount.accountType == PaymentAccountType.cheque) {
            accountCode = '1050'; // Cheque account
          } else {
            accountCode = '1100'; // Bank account
          }

          // Add microsecond delay to ensure unique timestamps
          await Future.delayed(Duration(microseconds: microsecondsDelay));
          microsecondsDelay += 1000; // 1 millisecond between each

          await _accountDao.recordPaymentOutInternal(
            companyId: companyId,
            paymentId: paymentId,
            supplierId: supplier.id,
            supplierName: supplier.name,
            paymentDate:
                voucherDate.add(Duration(microseconds: microsecondsDelay)),
            voucherNo: voucherNo,
            amount: l.amount, // Use individual line amount, not total
            accountCode: accountCode,
          );
        }
      }
    });
  }

  Future<void> updatePaymentOut({
    required int paymentOutId,
    required int companyId,
    required Party supplier,
    required DateTime voucherDate,
    required String voucherNo,
    required List<PaymentLineInput> lines,
    String? description,
    String? attachmentPath,
    int? userId,
  }) async {
    await isar.writeTxn(() async {
      final payment = await isar.paymentOuts.get(paymentOutId);
      if (payment == null) return;

      final totalAmount = lines.fold(0.0, (sum, l) => sum + l.amount);

      payment.voucherNo = voucherNo;
      payment.voucherDate = voucherDate;
      payment.partyId = supplier.id;
      payment.totalAmount = totalAmount;
      payment.description = description;
      payment.attachmentPath = attachmentPath;
      payment.updatedAt = DateTime.now();

      await isar.paymentOuts.put(payment);

      // Delete old lines
      final oldLines = await isar.paymentOutLines
          .filter()
          .paymentOutIdEqualTo(paymentOutId)
          .findAll();

      for (final oldLine in oldLines) {
        await isar.paymentOutLines.delete(oldLine.id);
      }

      // Delete all old accounting transactions for this payment
      await _accountDao.deletePaymentOutTransactionsInternal(paymentOutId);

      // Create new lines and accounting transactions
      for (final l in lines) {
        final line = PaymentOutLine()
          ..paymentOutId = paymentOutId
          ..paymentAccountId = l.accountId
          ..amount = l.amount
          ..referenceNo = l.referenceNo
          ..createdAt = DateTime.now();

        await isar.paymentOutLines.put(line);

        // Record accounting transaction for EACH payment line
        final paymentAccount = await isar.paymentAccounts.get(l.accountId);
        if (paymentAccount != null) {
          // Determine account code based on payment account type
          String accountCode;
          if (paymentAccount.accountType == PaymentAccountType.cash) {
            accountCode = '1000'; // Cash account
          } else if (paymentAccount.accountType == PaymentAccountType.cheque) {
            accountCode = '1050'; // Cheque account
          } else {
            accountCode = '1100'; // Bank account
          }

          await _accountDao.recordPaymentOutInternal(
            companyId: companyId,
            paymentId: paymentOutId,
            supplierId: supplier.id,
            supplierName: supplier.name,
            paymentDate: voucherDate,
            voucherNo: voucherNo,
            amount: l.amount, // Use individual line amount
            accountCode: accountCode,
          );
        }
      }
    });
  }

  Future<void> deletePaymentOut(int paymentOutId) async {
    await isar.writeTxn(() async {
      // Delete accounting transactions first
      await _accountDao.deletePaymentOutTransactionsInternal(paymentOutId);

      // Delete lines
      final lines = await isar.paymentOutLines
          .filter()
          .paymentOutIdEqualTo(paymentOutId)
          .findAll();

      for (final line in lines) {
        await isar.paymentOutLines.delete(line.id);
      }

      // Delete payment
      await isar.paymentOuts.delete(paymentOutId);
    });
  }

  // Get party balance (total paid to supplier)
  Future<double> getPartyPaidBalance(int partyId, int companyId) async {
    final payments = await isar.paymentOuts
        .filter()
        .companyIdEqualTo(companyId)
        .partyIdEqualTo(partyId)
        .findAll();

    return payments.fold<double>(0.0, (sum, p) => sum + p.totalAmount);
  }
}

class PaymentLineInput {
  final int accountId;
  final double amount;
  final String? referenceNo;

  PaymentLineInput({
    required this.accountId,
    required this.amount,
    this.referenceNo,
  });
}
