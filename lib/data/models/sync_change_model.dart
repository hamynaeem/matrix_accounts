import 'package:isar/isar.dart';

part 'sync_change_model.g.dart';

/// Tracks local changes for synchronization
@collection
class SyncChange {
  Id id = Isar.autoIncrement;

  @Index()
  late int companyId;

  @Index()
  late String table;

  @Enumerated(EnumType.name)
  late ChangeOperation operation;

  late int recordId;

  late String data; // JSON string of the record

  late DateTime createdAt;

  late bool synced;

  String? deviceId;
}

enum ChangeOperation {
  create,
  update,
  delete,
}
