import 'package:isar/isar.dart';

part 'company_model.g.dart';

@collection
class Company {
  Id id = Isar.autoIncrement;

  late int subscriberId;

  @Index(unique: true, caseSensitive: false)
  late String name;

  String? primaryCurrency;
  int? financialYearStartMonth;

  DateTime createdAt = DateTime.now();
  bool isActive = true;
}
