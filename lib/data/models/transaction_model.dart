import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

enum TransactionType {
  sale,
  purchase,
  expense,
  receipt,
  payment,
  saleReturn,
  purchaseReturn,
}

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Index()
  @enumerated
  late TransactionType type;

  @Index()
  late DateTime date;

  @Index(caseSensitive: false)
  late String referenceNo;

  int? partyId;
  String? cashBankAccount;

  double totalAmount = 0;

  bool isPosted = true;

  int? createdByUserId;
  DateTime createdAt = DateTime.now();

  @ignore
  get notes => null;
}

@collection
class TransactionLine {
  Id id = Isar.autoIncrement;

  @Index()
  late int transactionId;

  int? productId;
  int? expenseCategoryId;
  int? partyId;

  String? description;

  double quantity = 0;
  double unitPrice = 0;
  double lineAmount = 0;
}
