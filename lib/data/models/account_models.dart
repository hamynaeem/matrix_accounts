import 'package:isar/isar.dart';

part 'account_models.g.dart';

enum AccountType {
  asset, // Cash, Bank, Accounts Receivable
  liability, // Accounts Payable, Loans
  equity, // Capital, Retained Earnings
  revenue, // Sales Revenue
  expense, // Cost of Goods Sold, Operating Expenses
}

enum TransactionType {
  saleInvoice,
  paymentIn,
  purchaseInvoice,
  paymentOut,
  journalEntry,
  saleReturn,
  purchaseReturn,
  expense,
}

@collection
class Account {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Index(caseSensitive: false)
  late String name;

  late String code; // Account code like "1000", "2000", etc.

  @enumerated
  late AccountType accountType;

  int? parentAccountId; // For sub-accounts

  String? description;

  double openingBalance = 0;
  double currentBalance = 0;

  bool isSystem = false; // System accounts cannot be deleted
  bool isActive = true;

  DateTime createdAt = DateTime.now();
}

@collection
class AccountTransaction {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Index()
  late int accountId;

  @Index()
  @enumerated
  late TransactionType transactionType;

  @Index()
  late int referenceId; // ID of the invoice, payment, etc.

  @Index()
  late DateTime transactionDate;

  late double debit;
  late double credit;

  double runningBalance = 0; // Balance after this transaction

  String? description;
  String? referenceNo; // Invoice number, payment receipt number, etc.

  int? partyId; // Customer or supplier ID if applicable

  DateTime createdAt = DateTime.now();
}
