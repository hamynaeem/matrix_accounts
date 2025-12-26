import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/company_model.dart';
import '../../data/models/user_model.dart';
import '../database/dao/account_dao.dart';
import '../database/isar_service.dart';
import '../services/auth_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('IsarService must be overridden in main.dart');
});

final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('AuthService must be overridden in main.dart');
});

final currentUserProvider = StateProvider<User?>((ref) => null);

// Persist company selection using StateProvider
final currentCompanyProvider = StateProvider<Company?>((ref) => null);

// Track selected company ID
final selectedCompanyIdProvider = StateProvider<int?>((ref) => null);

enum SyncStatus { idle, syncing, error }

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

final accountDaoProvider = Provider<AccountDao>((ref) {
  throw UnimplementedError('AccountDao must be overridden in main.dart');
});
