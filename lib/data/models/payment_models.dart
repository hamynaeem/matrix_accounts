import 'package:isar/isar.dart';

part 'payment_models.g.dart';

enum PaymentAccountType {
  cash,
  bank,
}

@collection
class PaymentAccount {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Enumerated(EnumType.name)
  late PaymentAccountType accountType;

  late String accountName;
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  String? icon; // emoji or icon name

  @Index()
  late bool isActive;

  late DateTime createdAt;
  DateTime? updatedAt;

  // For default accounts (Cash)
  late bool isDefault;
}

@collection
class PaymentIn {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  late String receiptNo;
  late DateTime receiptDate;

  @Index()
  late int partyId; // customer

  late double totalAmount;

  String? description;
  String? attachmentPath;

  late DateTime createdAt;
  DateTime? updatedAt;

  int? createdByUserId;
}

@collection
class PaymentInLine {
  Id id = Isar.autoIncrement;

  @Index()
  late int paymentInId;

  @Index()
  late int paymentAccountId;

  late double amount;
  String? referenceNo;

  late DateTime createdAt;
}

@collection
class PaymentOut {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  late String voucherNo;
  late DateTime voucherDate;

  @Index()
  late int partyId; // supplier

  late double totalAmount;

  String? description;
  String? attachmentPath;

  late DateTime createdAt;
  DateTime? updatedAt;

  int? createdByUserId;
}

@collection
class PaymentOutLine {
  Id id = Isar.autoIncrement;

  @Index()
  late int paymentOutId;

  @Index()
  late int paymentAccountId;

  late double amount;
  String? referenceNo;

  late DateTime createdAt;
}
