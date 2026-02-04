// Stub for web - Isar is not supported on web
import 'package:isar/isar.dart';

class Company {
  Id id = Isar.autoIncrement;
  late int subscriberId;
  late String name;
  String? primaryCurrency;
  int? financialYearStartMonth;
  DateTime createdAt = DateTime.now();
  bool isActive = true;
}
