import 'package:isar/isar.dart';

part 'party_model.g.dart';

enum PartyType { customer, supplier, both }

@collection
class Party {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Index(caseSensitive: false)
  late String name;

  @Index()
  @enumerated
  late PartyType partyType;

  String? phone;
  String? email;
  String? address;

  double openingBalance = 0;
  double creditLimit = 0;
  int paymentTermsDays = 0;

  DateTime createdAt = DateTime.now();
  bool isActive = true;
}
