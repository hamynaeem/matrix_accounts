import 'package:isar/isar.dart';

import '../../../data/models/account_models.dart';

class AccountDao {
  final Isar isar;

  AccountDao(this.isar);

  // Initialize default chart of accounts for a company
  Future<void> createDefaultAccounts(int companyId) async {
    await isar.writeTxn(() async {
      // Check if accounts already exist
      final existing =
          await isar.accounts.filter().companyIdEqualTo(companyId).count();

      if (existing > 0) return;

      final accounts = [
        // Assets
        Account()
          ..companyId = companyId
          ..name = 'Cash'
          ..code = '1000'
          ..accountType = AccountType.asset
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Cheque'
          ..code = '1050'
          ..accountType = AccountType.asset
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Bank'
          ..code = '1100'
          ..accountType = AccountType.asset
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Accounts Receivable'
          ..code = '1200'
          ..accountType = AccountType.asset
          ..description = 'Money owed by customers'
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Inventory'
          ..code = '1300'
          ..accountType = AccountType.asset
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,

        // Liabilities
        Account()
          ..companyId = companyId
          ..name = 'Accounts Payable'
          ..code = '2000'
          ..accountType = AccountType.liability
          ..description = 'Money owed to suppliers'
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,

        // Equity
        Account()
          ..companyId = companyId
          ..name = 'Owner Equity'
          ..code = '3000'
          ..accountType = AccountType.equity
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,

        // Revenue
        Account()
          ..companyId = companyId
          ..name = 'Sales Revenue'
          ..code = '4000'
          ..accountType = AccountType.revenue
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,

        // Expenses
        Account()
          ..companyId = companyId
          ..name = 'Cost of Goods Sold'
          ..code = '5000'
          ..accountType = AccountType.expense
          ..description = 'Direct cost of goods sold'
          ..isSystem = true
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Petrol & Fuel'
          ..code = '5100'
          ..accountType = AccountType.expense
          ..description = 'Vehicle fuel and petrol expenses'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Rent Expense'
          ..code = '5200'
          ..accountType = AccountType.expense
          ..description = 'Office or warehouse rent'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Salary & Wages'
          ..code = '5300'
          ..accountType = AccountType.expense
          ..description = 'Employee salaries and wages'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Transport & Freight'
          ..code = '5400'
          ..accountType = AccountType.expense
          ..description = 'Transportation and delivery charges'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Shipping & Courier'
          ..code = '5500'
          ..accountType = AccountType.expense
          ..description = 'Shipping and courier services'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Electricity & Utilities'
          ..code = '5600'
          ..accountType = AccountType.expense
          ..description = 'Electricity, water, and other utilities'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Telephone & Internet'
          ..code = '5700'
          ..accountType = AccountType.expense
          ..description = 'Phone and internet bills'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Office Supplies'
          ..code = '5800'
          ..accountType = AccountType.expense
          ..description = 'Stationery and office supplies'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Maintenance & Repairs'
          ..code = '5900'
          ..accountType = AccountType.expense
          ..description = 'Equipment and facility maintenance'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Insurance'
          ..code = '6000'
          ..accountType = AccountType.expense
          ..description = 'Insurance premiums'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Advertising & Marketing'
          ..code = '6100'
          ..accountType = AccountType.expense
          ..description = 'Marketing and advertising expenses'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Bank Charges'
          ..code = '6200'
          ..accountType = AccountType.expense
          ..description = 'Bank fees and charges'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
        Account()
          ..companyId = companyId
          ..name = 'Miscellaneous Expense'
          ..code = '6900'
          ..accountType = AccountType.expense
          ..description = 'Other general expenses'
          ..isSystem = false
          ..openingBalance = 0
          ..currentBalance = 0,
      ];

      for (final account in accounts) {
        await isar.accounts.put(account);
      }
    });
  }

  // Internal method - works within existing transaction
  Future<void> recordSaleInvoiceInternal({
    required int companyId,
    required int invoiceId,
    required int customerId,
    required String customerName,
    required DateTime invoiceDate,
    required String invoiceNo,
    required double totalAmount,
  }) async {
    // Get required accounts
    final accountsReceivable = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('1200')
        .findFirst();

    final salesRevenue = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('4000')
        .findFirst();

    if (accountsReceivable == null || salesRevenue == null) {
      throw Exception(
          'Required accounts not found. Please initialize chart of accounts.');
    }

    // Debit Accounts Receivable (increase asset)
    final arTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = accountsReceivable.id
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = invoiceId
      ..transactionDate = invoiceDate
      ..debit = totalAmount
      ..credit = 0
      ..description = 'Sale to $customerName'
      ..referenceNo = invoiceNo
      ..partyId = customerId;

    accountsReceivable.currentBalance += totalAmount;
    arTransaction.runningBalance = accountsReceivable.currentBalance;

    await isar.accountTransactions.put(arTransaction);
    await isar.accounts.put(accountsReceivable);

    // Credit Sales Revenue (increase revenue)
    final revenueTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = salesRevenue.id
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = invoiceId
      ..transactionDate = invoiceDate
      ..debit = 0
      ..credit = totalAmount
      ..description = 'Sale to $customerName'
      ..referenceNo = invoiceNo
      ..partyId = customerId;

    salesRevenue.currentBalance += totalAmount;
    revenueTransaction.runningBalance = salesRevenue.currentBalance;

    await isar.accountTransactions.put(revenueTransaction);
    await isar.accounts.put(salesRevenue);
  }

  // Internal method - records payment received on sale invoice (within transaction)
  Future<void> recordSaleInvoicePaymentInternal({
    required int companyId,
    required int invoiceId,
    required int customerId,
    required String customerName,
    required DateTime paymentDate,
    required String invoiceNo,
    required double amount,
    required String accountCode, // '1000' cash, '1050' cheque, '1100' bank
  }) async {
    // Get the cash/bank account by code
    final cashBankAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo(accountCode)
        .findFirst();

    final accountsReceivable = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('1200')
        .findFirst();

    if (cashBankAccount == null || accountsReceivable == null) {
      throw Exception('Required accounts not found for payment recording.');
    }

    // Debit Cash/Bank (increase asset)
    final cashTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = cashBankAccount.id
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = invoiceId
      ..transactionDate = paymentDate
      ..debit = amount
      ..credit = 0
      ..description = 'Payment from $customerName (Invoice)'
      ..referenceNo = invoiceNo
      ..partyId = customerId;

    cashBankAccount.currentBalance += amount;
    cashTransaction.runningBalance = cashBankAccount.currentBalance;

    await isar.accountTransactions.put(cashTransaction);
    await isar.accounts.put(cashBankAccount);

    // Credit Accounts Receivable (decrease asset)
    final arTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = accountsReceivable.id
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = invoiceId
      ..transactionDate = paymentDate
      ..debit = 0
      ..credit = amount
      ..description = 'Payment from $customerName (Invoice)'
      ..referenceNo = invoiceNo
      ..partyId = customerId;

    accountsReceivable.currentBalance -= amount;
    arTransaction.runningBalance = accountsReceivable.currentBalance;

    await isar.accountTransactions.put(arTransaction);
    await isar.accounts.put(accountsReceivable);
  }

  // Public method - creates its own transaction
  Future<void> recordSaleInvoice({
    required int companyId,
    required int invoiceId,
    required int customerId,
    required String customerName,
    required DateTime invoiceDate,
    required String invoiceNo,
    required double totalAmount,
  }) async {
    await isar.writeTxn(() async {
      await recordSaleInvoiceInternal(
        companyId: companyId,
        invoiceId: invoiceId,
        customerId: customerId,
        customerName: customerName,
        invoiceDate: invoiceDate,
        invoiceNo: invoiceNo,
        totalAmount: totalAmount,
      );
    });
  }

  // Internal method - works within existing transaction
  Future<void> recordPaymentInInternal({
    required int companyId,
    required int paymentId,
    required int customerId,
    required String customerName,
    required DateTime paymentDate,
    required String receiptNo,
    required double amount,
    required String accountCode, // '1000' for cash, '1100' for bank
  }) async {
    // Get the cash/bank account by code
    final cashBankAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo(accountCode)
        .findFirst();

    final accountsReceivable = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('1200')
        .findFirst();

    if (cashBankAccount == null || accountsReceivable == null) {
      throw Exception('Required accounts not found for payment recording.');
    }

    // Debit Cash/Bank (increase asset)
    final cashTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = cashBankAccount.id
      ..transactionType = TransactionType.paymentIn
      ..referenceId = paymentId
      ..transactionDate = paymentDate
      ..debit = amount
      ..credit = 0
      ..description = 'Payment from $customerName'
      ..referenceNo = receiptNo
      ..partyId = customerId;

    cashBankAccount.currentBalance += amount;
    cashTransaction.runningBalance = cashBankAccount.currentBalance;

    await isar.accountTransactions.put(cashTransaction);
    await isar.accounts.put(cashBankAccount);

    // Credit Accounts Receivable (decrease asset)
    final arTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = accountsReceivable.id
      ..transactionType = TransactionType.paymentIn
      ..referenceId = paymentId
      ..transactionDate = paymentDate
      ..debit = 0
      ..credit = amount
      ..description = 'Payment from $customerName'
      ..referenceNo = receiptNo
      ..partyId = customerId;

    accountsReceivable.currentBalance -= amount;
    arTransaction.runningBalance = accountsReceivable.currentBalance;

    await isar.accountTransactions.put(arTransaction);
    await isar.accounts.put(accountsReceivable);
  }

  // Public method - creates its own transaction
  Future<void> recordPaymentIn({
    required int companyId,
    required int paymentId,
    required int customerId,
    required String customerName,
    required DateTime paymentDate,
    required String receiptNo,
    required double amount,
    required String accountCode,
  }) async {
    await isar.writeTxn(() async {
      await recordPaymentInInternal(
        companyId: companyId,
        paymentId: paymentId,
        customerId: customerId,
        customerName: customerName,
        paymentDate: paymentDate,
        receiptNo: receiptNo,
        amount: amount,
        accountCode: accountCode,
      );
    });
  }

  // Update transactions when invoice is editedansaction
  Future<void> updateSaleInvoiceTransactionsInternal({
    required int companyId,
    required int invoiceId,
    required double oldAmount,
    required double newAmount,
    required int customerId,
    required String customerName,
    required DateTime invoiceDate,
    required String invoiceNo,
  }) async {
    // Delete old transactions
    final oldTransactions = await isar.accountTransactions
        .filter()
        .transactionTypeEqualTo(TransactionType.saleInvoice)
        .referenceIdEqualTo(invoiceId)
        .findAll();

    for (final txn in oldTransactions) {
      final account = await isar.accounts.get(txn.accountId);
      if (account != null) {
        // Reverse the old transaction
        account.currentBalance -= (txn.debit - txn.credit);
        await isar.accounts.put(account);
      }
      await isar.accountTransactions.delete(txn.id);
    }

    // Record new transactions
    await recordSaleInvoiceInternal(
      companyId: companyId,
      invoiceId: invoiceId,
      customerId: customerId,
      customerName: customerName,
      invoiceDate: invoiceDate,
      invoiceNo: invoiceNo,
      totalAmount: newAmount,
    );
  }

  // Public method - creates its own transaction
  Future<void> updateSaleInvoiceTransactions({
    required int companyId,
    required int invoiceId,
    required double oldAmount,
    required double newAmount,
    required int customerId,
    required String customerName,
    required DateTime invoiceDate,
    required String invoiceNo,
  }) async {
    await isar.writeTxn(() async {
      await updateSaleInvoiceTransactionsInternal(
        companyId: companyId,
        invoiceId: invoiceId,
        oldAmount: oldAmount,
        newAmount: newAmount,
        customerId: customerId,
        customerName: customerName,
        invoiceDate: invoiceDate,
        invoiceNo: invoiceNo,
      );
    });
  }

  // Update transactions when payment is editedansaction
  Future<void> updatePaymentInTransactionsInternal({
    required int companyId,
    required int paymentId,
    required double oldAmount,
    required double newAmount,
    required int customerId,
    required String customerName,
    required DateTime paymentDate,
    required String receiptNo,
    required String accountCode,
  }) async {
    // Delete old transactions
    final oldTransactions = await isar.accountTransactions
        .filter()
        .transactionTypeEqualTo(TransactionType.paymentIn)
        .referenceIdEqualTo(paymentId)
        .findAll();

    for (final txn in oldTransactions) {
      final account = await isar.accounts.get(txn.accountId);
      if (account != null) {
        // Reverse the old transaction
        account.currentBalance -= (txn.debit - txn.credit);
        await isar.accounts.put(account);
      }
      await isar.accountTransactions.delete(txn.id);
    }

    // Record new transactions
    await recordPaymentInInternal(
      companyId: companyId,
      paymentId: paymentId,
      customerId: customerId,
      customerName: customerName,
      paymentDate: paymentDate,
      receiptNo: receiptNo,
      amount: newAmount,
      accountCode: accountCode,
    );
  }

  // Public method - creates its own transaction
  Future<void> updatePaymentInTransactions({
    required int companyId,
    required int paymentId,
    required double oldAmount,
    required double newAmount,
    required int customerId,
    required String customerName,
    required DateTime paymentDate,
    required String receiptNo,
    required String accountCode,
  }) async {
    await isar.writeTxn(() async {
      await updatePaymentInTransactionsInternal(
        companyId: companyId,
        paymentId: paymentId,
        oldAmount: oldAmount,
        newAmount: newAmount,
        customerId: customerId,
        customerName: customerName,
        paymentDate: paymentDate,
        receiptNo: receiptNo,
        accountCode: accountCode,
      );
    });
  }

  // Internal method - works within existing transaction
  Future<void> deleteSaleInvoiceTransactionsInternal(int invoiceId) async {
    final transactions = await isar.accountTransactions
        .filter()
        .transactionTypeEqualTo(TransactionType.saleInvoice)
        .referenceIdEqualTo(invoiceId)
        .findAll();

    for (final txn in transactions) {
      final account = await isar.accounts.get(txn.accountId);
      if (account != null) {
        // Reverse the transaction
        account.currentBalance -= (txn.debit - txn.credit);
        await isar.accounts.put(account);
      }
      await isar.accountTransactions.delete(txn.id);
    }
  }

  // Public method - creates its own transaction
  Future<void> deleteSaleInvoiceTransactions(int invoiceId) async {
    await isar.writeTxn(() async {
      await deleteSaleInvoiceTransactionsInternal(invoiceId);
    });
  }

  // Delete transactions when payment is deletednsaction
  Future<void> deletePaymentInTransactionsInternal(int paymentId) async {
    final transactions = await isar.accountTransactions
        .filter()
        .transactionTypeEqualTo(TransactionType.paymentIn)
        .referenceIdEqualTo(paymentId)
        .findAll();

    for (final txn in transactions) {
      final account = await isar.accounts.get(txn.accountId);
      if (account != null) {
        // Reverse the transaction
        account.currentBalance -= (txn.debit - txn.credit);
        await isar.accounts.put(account);
      }
      await isar.accountTransactions.delete(txn.id);
    }
  }

  // Public method - creates its own transaction
  Future<void> deletePaymentInTransactions(int paymentId) async {
    await isar.writeTxn(() async {
      await deletePaymentInTransactionsInternal(paymentId);
    });
  }

  // Get account balance
  Future<double> getAccountBalance(int companyId, String accountCode) async {
    final account = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo(accountCode)
        .findFirst();

    return account?.currentBalance ?? 0;
  }

  // Get account transaction history
  Future<List<AccountTransaction>> getAccountTransactions({
    required int companyId,
    required String accountCode,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final account = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo(accountCode)
        .findFirst();

    if (account == null) return [];

    var query = isar.accountTransactions.filter().accountIdEqualTo(account.id);

    if (fromDate != null) {
      query = query.transactionDateGreaterThan(
          fromDate.subtract(const Duration(days: 1)));
    }

    if (toDate != null) {
      query =
          query.transactionDateLessThan(toDate.add(const Duration(days: 1)));
    }

    return await query.sortByTransactionDateDesc().findAll();
  }

  // Get customer ledger
  Future<List<AccountTransaction>> getCustomerLedger({
    required int companyId,
    required int customerId,
  }) async {
    // Get Accounts Receivable account
    final arAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('1200')
        .findFirst();

    if (arAccount == null) return [];

    // Only return transactions from the AR account for this customer
    return await isar.accountTransactions
        .filter()
        .companyIdEqualTo(companyId)
        .accountIdEqualTo(arAccount.id)
        .partyIdEqualTo(customerId)
        .sortByTransactionDateDesc()
        .findAll();
  }

  // Get all accounts for a company
  Future<List<Account>> getAccounts(int companyId) async {
    return await isar.accounts.filter().companyIdEqualTo(companyId).findAll();
  }

  // ========== PURCHASE ACCOUNTING METHODS ==========

  // Internal method - records purchase invoice (within transaction)
  Future<void> recordPurchaseInvoiceInternal({
    required int companyId,
    required int invoiceId,
    required int supplierId,
    required String supplierName,
    required DateTime invoiceDate,
    required String invoiceNo,
    required double totalAmount,
  }) async {
    // Get required accounts
    final accountsPayable = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('2000') // Accounts Payable
        .findFirst();

    final purchaseExpense = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('5000') // Purchase/Cost of Goods Sold
        .findFirst();

    if (accountsPayable == null || purchaseExpense == null) {
      throw Exception(
          'Required accounts not found. Please initialize chart of accounts.');
    }

    // Debit Purchase Expense (increase expense)
    final expenseTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = purchaseExpense.id
      ..transactionType = TransactionType.purchaseInvoice
      ..referenceId = invoiceId
      ..transactionDate = invoiceDate
      ..debit = totalAmount
      ..credit = 0
      ..description = 'Purchase from $supplierName'
      ..referenceNo = invoiceNo
      ..partyId = supplierId;

    purchaseExpense.currentBalance += totalAmount;
    expenseTransaction.runningBalance = purchaseExpense.currentBalance;

    await isar.accountTransactions.put(expenseTransaction);
    await isar.accounts.put(purchaseExpense);

    // Credit Accounts Payable (increase liability)
    final apTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = accountsPayable.id
      ..transactionType = TransactionType.purchaseInvoice
      ..referenceId = invoiceId
      ..transactionDate = invoiceDate
      ..debit = 0
      ..credit = totalAmount
      ..description = 'Purchase from $supplierName'
      ..referenceNo = invoiceNo
      ..partyId = supplierId;

    accountsPayable.currentBalance += totalAmount;
    apTransaction.runningBalance = accountsPayable.currentBalance;

    await isar.accountTransactions.put(apTransaction);
    await isar.accounts.put(accountsPayable);
  }

  // Internal method - records payment made on purchase invoice (within transaction)
  Future<void> recordPurchaseInvoicePaymentInternal({
    required int companyId,
    required int invoiceId,
    required int supplierId,
    required String supplierName,
    required DateTime paymentDate,
    required String invoiceNo,
    required double amount,
    required String accountCode, // '1000' cash, '1050' cheque, '1100' bank
  }) async {
    // Get the cash/bank account by code
    final cashBankAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo(accountCode)
        .findFirst();

    final accountsPayable = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('2000') // Accounts Payable
        .findFirst();

    if (cashBankAccount == null || accountsPayable == null) {
      throw Exception('Required accounts not found for payment recording.');
    }

    // Credit Cash/Bank (decrease asset)
    final cashTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = cashBankAccount.id
      ..transactionType = TransactionType.paymentOut
      ..referenceId = invoiceId
      ..transactionDate = paymentDate
      ..debit = 0
      ..credit = amount
      ..description = 'Payment to $supplierName (Invoice)'
      ..referenceNo = invoiceNo
      ..partyId = supplierId;

    cashBankAccount.currentBalance -= amount;
    cashTransaction.runningBalance = cashBankAccount.currentBalance;

    await isar.accountTransactions.put(cashTransaction);
    await isar.accounts.put(cashBankAccount);

    // Debit Accounts Payable (decrease liability)
    final apTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = accountsPayable.id
      ..transactionType = TransactionType.paymentOut
      ..referenceId = invoiceId
      ..transactionDate = paymentDate
      ..debit = amount
      ..credit = 0
      ..description = 'Payment to $supplierName (Invoice)'
      ..referenceNo = invoiceNo
      ..partyId = supplierId;

    accountsPayable.currentBalance -= amount;
    apTransaction.runningBalance = accountsPayable.currentBalance;

    await isar.accountTransactions.put(apTransaction);
    await isar.accounts.put(accountsPayable);
  }

  // Delete all accounting transactions related to purchase invoice (internal)
  Future<void> deletePurchaseInvoiceTransactionsInternal(int invoiceId) async {
    final transactions = await isar.accountTransactions
        .filter()
        .transactionTypeEqualTo(TransactionType.purchaseInvoice)
        .or()
        .transactionTypeEqualTo(TransactionType.paymentOut)
        .referenceIdEqualTo(invoiceId)
        .findAll();

    for (final transaction in transactions) {
      // Reverse the balance changes
      final account = await isar.accounts.get(transaction.accountId);
      if (account != null) {
        // Reverse the transaction: subtract (debit - credit)
        account.currentBalance -= (transaction.debit - transaction.credit);
        await isar.accounts.put(account);
      }

      await isar.accountTransactions.delete(transaction.id);
    }
  }

  // Public method - delete purchase invoice transactions (creates its own transaction)
  Future<void> deletePurchaseInvoiceTransactions(int invoiceId) async {
    await isar.writeTxn(() async {
      await deletePurchaseInvoiceTransactionsInternal(invoiceId);
    });
  }

  // Get supplier ledger
  Future<List<AccountTransaction>> getSupplierLedger({
    required int companyId,
    required int supplierId,
  }) async {
    // Get Accounts Payable account
    final apAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('2000')
        .findFirst();

    if (apAccount == null) return [];

    // Only return transactions from the AP account for this supplier
    return await isar.accountTransactions
        .filter()
        .companyIdEqualTo(companyId)
        .accountIdEqualTo(apAccount.id)
        .partyIdEqualTo(supplierId)
        .sortByTransactionDateDesc()
        .findAll();
  }

  // Internal method - records standalone payment to supplier (within transaction)
  Future<void> recordPaymentOutInternal({
    required int companyId,
    required int paymentId,
    required int supplierId,
    required String supplierName,
    required DateTime paymentDate,
    required String voucherNo,
    required double amount,
    required String accountCode, // '1000' cash, '1050' cheque, '1100' bank
  }) async {
    // Get the cash/bank account by code
    final cashBankAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo(accountCode)
        .findFirst();

    final accountsPayable = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('2000') // Accounts Payable
        .findFirst();

    if (cashBankAccount == null || accountsPayable == null) {
      throw Exception('Required accounts not found for payment recording.');
    }

    // Credit Cash/Bank (decrease asset)
    final cashTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = cashBankAccount.id
      ..transactionType = TransactionType.paymentOut
      ..referenceId = paymentId
      ..transactionDate = paymentDate
      ..debit = 0
      ..credit = amount
      ..description = 'Payment to $supplierName'
      ..referenceNo = voucherNo
      ..partyId = supplierId;

    cashBankAccount.currentBalance -= amount;
    cashTransaction.runningBalance = cashBankAccount.currentBalance;

    await isar.accountTransactions.put(cashTransaction);
    await isar.accounts.put(cashBankAccount);

    // Debit Accounts Payable (decrease liability)
    final apTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = accountsPayable.id
      ..transactionType = TransactionType.paymentOut
      ..referenceId = paymentId
      ..transactionDate = paymentDate
      ..debit = amount
      ..credit = 0
      ..description = 'Payment to $supplierName'
      ..referenceNo = voucherNo
      ..partyId = supplierId;

    accountsPayable.currentBalance -= amount;
    apTransaction.runningBalance = accountsPayable.currentBalance;

    await isar.accountTransactions.put(apTransaction);
    await isar.accounts.put(accountsPayable);
  }

  // Delete all accounting transactions related to payment out (internal)
  Future<void> deletePaymentOutTransactionsInternal(int paymentId) async {
    final transactions = await isar.accountTransactions
        .filter()
        .transactionTypeEqualTo(TransactionType.paymentOut)
        .referenceIdEqualTo(paymentId)
        .findAll();

    for (final transaction in transactions) {
      // Reverse the balance changes
      final account = await isar.accounts.get(transaction.accountId);
      if (account != null) {
        // Reverse the transaction: subtract (debit - credit)
        account.currentBalance -= (transaction.debit - transaction.credit);
        await isar.accounts.put(account);
      }

      await isar.accountTransactions.delete(transaction.id);
    }
  }

  // Public method - delete payment out transactions (creates its own transaction)
  Future<void> deletePaymentOutTransactions(int paymentId) async {
    await isar.writeTxn(() async {
      await deletePaymentOutTransactionsInternal(paymentId);
    });
  }

  // Expense accounting methods
  Future<void> recordExpenseInternal({
    required int companyId,
    required int expenseId,
    required int expenseAccountId,
    required String expenseAccountName,
    required DateTime expenseDate,
    required String referenceNo,
    required double amount,
    required String paymentAccountCode,
  }) async {
    // Get expense account
    final expenseAccount = await isar.accounts.get(expenseAccountId);
    if (expenseAccount == null) return;

    // Get payment account (cash/bank/cheque)
    final paymentAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo(paymentAccountCode)
        .findFirst();
    if (paymentAccount == null) return;

    // Debit Expense Account
    final expenseTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = expenseAccount.id
      ..transactionDate = expenseDate
      ..transactionType = TransactionType.expense
      ..referenceId = expenseId
      ..referenceNo = referenceNo
      ..description = 'Expense: $expenseAccountName'
      ..debit = amount
      ..credit = 0
      ..partyId = null;

    await isar.accountTransactions.put(expenseTransaction);
    expenseAccount.currentBalance += amount;
    await isar.accounts.put(expenseAccount);

    // Credit Payment Account (reduce cash/bank)
    final paymentTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = paymentAccount.id
      ..transactionDate = expenseDate
      ..transactionType = TransactionType.expense
      ..referenceId = expenseId
      ..referenceNo = referenceNo
      ..description = 'Expense Payment: $expenseAccountName'
      ..debit = 0
      ..credit = amount
      ..partyId = null;

    await isar.accountTransactions.put(paymentTransaction);
    paymentAccount.currentBalance -= amount;
    await isar.accounts.put(paymentAccount);
  }

  Future<void> deleteExpenseTransactionsInternal(int expenseId) async {
    final transactions = await isar.accountTransactions
        .filter()
        .transactionTypeEqualTo(TransactionType.expense)
        .referenceIdEqualTo(expenseId)
        .findAll();

    for (final transaction in transactions) {
      // Reverse the balance changes
      final account = await isar.accounts.get(transaction.accountId);
      if (account != null) {
        account.currentBalance -= (transaction.debit - transaction.credit);
        await isar.accounts.put(account);
      }

      await isar.accountTransactions.delete(transaction.id);
    }
  }

  // Cost of Goods Sold (COGS) accounting
  Future<void> recordCOGSInternal({
    required int companyId,
    required int invoiceId,
    required DateTime saleDate,
    required String invoiceNo,
    required double cogsAmount,
  }) async {
    // Get COGS account (5000)
    final cogsAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('5000')
        .findFirst();

    // Get Inventory account (1300)
    final inventoryAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('1300')
        .findFirst();

    if (cogsAccount == null || inventoryAccount == null) return;

    // Debit COGS
    final cogsTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = cogsAccount.id
      ..transactionDate = saleDate
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = invoiceId
      ..referenceNo = invoiceNo
      ..description = 'COGS for Invoice $invoiceNo'
      ..debit = cogsAmount
      ..credit = 0
      ..partyId = null;

    await isar.accountTransactions.put(cogsTransaction);
    cogsAccount.currentBalance += cogsAmount;
    await isar.accounts.put(cogsAccount);

    // Credit Inventory
    final inventoryTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = inventoryAccount.id
      ..transactionDate = saleDate
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = invoiceId
      ..referenceNo = invoiceNo
      ..description = 'Inventory reduction for Invoice $invoiceNo'
      ..debit = 0
      ..credit = cogsAmount
      ..partyId = null;

    await isar.accountTransactions.put(inventoryTransaction);
    inventoryAccount.currentBalance -= cogsAmount;
    await isar.accounts.put(inventoryAccount);
  }

  // Sale Return accounting
  Future<void> recordSaleReturnInternal({
    required int companyId,
    required int returnInvoiceId,
    required int customerId,
    required String customerName,
    required DateTime returnDate,
    required String returnNo,
    required double returnAmount,
  }) async {
    // Get Accounts Receivable (AR) account
    final arAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('1200')
        .findFirst();

    // Get Sales Returns account (or use Sales Revenue account)
    final salesReturnAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('4000') // Sales Revenue - we'll debit it for returns
        .findFirst();

    if (arAccount == null || salesReturnAccount == null) return;

    // Credit AR (reduce customer balance)
    final arTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = arAccount.id
      ..transactionDate = returnDate
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = returnInvoiceId
      ..referenceNo = returnNo
      ..description = 'Sale Return from $customerName'
      ..debit = 0
      ..credit = returnAmount
      ..partyId = customerId;

    await isar.accountTransactions.put(arTransaction);
    arAccount.currentBalance -= returnAmount;
    await isar.accounts.put(arAccount);

    // Debit Sales Returns (reduce revenue)
    final salesTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = salesReturnAccount.id
      ..transactionDate = returnDate
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = returnInvoiceId
      ..referenceNo = returnNo
      ..description = 'Sale Return - $returnNo'
      ..debit = returnAmount
      ..credit = 0
      ..partyId = customerId;

    await isar.accountTransactions.put(salesTransaction);
    salesReturnAccount.currentBalance -= returnAmount;
    await isar.accounts.put(salesReturnAccount);
  }

  Future<void> recordCOGSReversalInternal({
    required int companyId,
    required int returnInvoiceId,
    required DateTime returnDate,
    required String returnNo,
    required double cogsReversalAmount,
  }) async {
    // Reverse COGS by crediting COGS and debiting Inventory
    final cogsAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('5000')
        .findFirst();

    final inventoryAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('1300')
        .findFirst();

    if (cogsAccount == null || inventoryAccount == null) return;

    // Credit COGS (reverse the expense)
    final cogsTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = cogsAccount.id
      ..transactionDate = returnDate
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = returnInvoiceId
      ..referenceNo = returnNo
      ..description = 'COGS Reversal for Return $returnNo'
      ..debit = 0
      ..credit = cogsReversalAmount
      ..partyId = null;

    await isar.accountTransactions.put(cogsTransaction);
    cogsAccount.currentBalance -= cogsReversalAmount;
    await isar.accounts.put(cogsAccount);

    // Debit Inventory (restore inventory value)
    final inventoryTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = inventoryAccount.id
      ..transactionDate = returnDate
      ..transactionType = TransactionType.saleInvoice
      ..referenceId = returnInvoiceId
      ..referenceNo = returnNo
      ..description = 'Inventory restoration for Return $returnNo'
      ..debit = cogsReversalAmount
      ..credit = 0
      ..partyId = null;

    await isar.accountTransactions.put(inventoryTransaction);
    inventoryAccount.currentBalance += cogsReversalAmount;
    await isar.accounts.put(inventoryAccount);
  }

  Future<void> deleteSaleReturnTransactionsInternal(int returnInvoiceId) async {
    final transactions = await isar.accountTransactions
        .filter()
        .referenceIdEqualTo(returnInvoiceId)
        .findAll();

    for (final transaction in transactions) {
      final account = await isar.accounts.get(transaction.accountId);
      if (account != null) {
        account.currentBalance -= (transaction.debit - transaction.credit);
        await isar.accounts.put(account);
      }
      await isar.accountTransactions.delete(transaction.id);
    }
  }

  // Purchase Return accounting
  Future<void> recordPurchaseReturnInternal({
    required int companyId,
    required int returnInvoiceId,
    required int supplierId,
    required String supplierName,
    required DateTime returnDate,
    required String returnNo,
    required double returnAmount,
  }) async {
    // Get Accounts Payable (AP) account
    final apAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('2000')
        .findFirst();

    // Get Inventory account
    final inventoryAccount = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo('1300')
        .findFirst();

    if (apAccount == null || inventoryAccount == null) return;

    // Debit AP (reduce supplier balance)
    final apTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = apAccount.id
      ..transactionDate = returnDate
      ..transactionType = TransactionType.purchaseInvoice
      ..referenceId = returnInvoiceId
      ..referenceNo = returnNo
      ..description = 'Purchase Return to $supplierName'
      ..debit = returnAmount
      ..credit = 0
      ..partyId = supplierId;

    await isar.accountTransactions.put(apTransaction);
    apAccount.currentBalance -= returnAmount;
    await isar.accounts.put(apAccount);

    // Credit Inventory (reduce inventory value)
    final inventoryTransaction = AccountTransaction()
      ..companyId = companyId
      ..accountId = inventoryAccount.id
      ..transactionDate = returnDate
      ..transactionType = TransactionType.purchaseInvoice
      ..referenceId = returnInvoiceId
      ..referenceNo = returnNo
      ..description = 'Inventory reduction for Return $returnNo'
      ..debit = 0
      ..credit = returnAmount
      ..partyId = null;

    await isar.accountTransactions.put(inventoryTransaction);
    inventoryAccount.currentBalance -= returnAmount;
    await isar.accounts.put(inventoryAccount);
  }

  Future<void> deletePurchaseReturnTransactionsInternal(
      int returnInvoiceId) async {
    final transactions = await isar.accountTransactions
        .filter()
        .referenceIdEqualTo(returnInvoiceId)
        .findAll();

    for (final transaction in transactions) {
      final account = await isar.accounts.get(transaction.accountId);
      if (account != null) {
        account.currentBalance -= (transaction.debit - transaction.credit);
        await isar.accounts.put(account);
      }
      await isar.accountTransactions.delete(transaction.id);
    }
  }
}
