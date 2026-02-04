import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/sync_service.dart';
import '../config/app_config.dart';
import '../config/providers.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// Sync Service Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    apiClient: ref.watch(apiClientProvider),
    isarService: ref.watch(isarServiceProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

// Sync Status Provider
enum SyncState { idle, syncing, success, error }

class SyncStateData {
  final SyncState state;
  final String? message;
  final int? changesApplied;
  final DateTime? lastSyncTime;

  SyncStateData({
    required this.state,
    this.message,
    this.changesApplied,
    this.lastSyncTime,
  });

  SyncStateData copyWith({
    SyncState? state,
    String? message,
    int? changesApplied,
    DateTime? lastSyncTime,
  }) {
    return SyncStateData(
      state: state ?? this.state,
      message: message ?? this.message,
      changesApplied: changesApplied ?? this.changesApplied,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

final syncStateProvider =
    StateNotifierProvider<SyncStateNotifier, SyncStateData>((ref) {
  return SyncStateNotifier(ref.watch(syncServiceProvider));
});

class SyncStateNotifier extends StateNotifier<SyncStateData> {
  final SyncService syncService;

  SyncStateNotifier(this.syncService)
      : super(SyncStateData(state: SyncState.idle));

  Future<void> performSync(int companyId) async {
    state = state.copyWith(state: SyncState.syncing);

    try {
      final result = await syncService.fullSync(companyId);

      if (result.success) {
        state = SyncStateData(
          state: SyncState.success,
          message: 'Sync completed successfully',
          changesApplied: result.changesApplied,
          lastSyncTime: DateTime.now(),
        );
      } else {
        state = SyncStateData(
          state: SyncState.error,
          message: result.error ?? 'Sync failed',
        );
      }
    } catch (e) {
      state = SyncStateData(
        state: SyncState.error,
        message: e.toString(),
      );
    }
  }

  void reset() {
    state = SyncStateData(state: SyncState.idle);
  }
}
