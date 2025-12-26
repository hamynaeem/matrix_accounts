import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String email;

  late String fullName;
  late String passwordHash;

  bool isActive = true;
  DateTime createdAt = DateTime.now();
}

@collection
class CompanyUser {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Index()
  late int userId;

  @Index(caseSensitive: false)
  late String role;

  int? userGroupId;
  bool isActive = true;
}
