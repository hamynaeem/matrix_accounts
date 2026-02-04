import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database/isar_service.dart';
import 'api_client.dart';

class SyncService {
  final ApiClient apiClient;
  final IsarService isarService;
  final SharedPreferences prefs;

  SyncService({
    required this.apiClient,
    required this.isarService,
    required this.prefs,
  });

  String get deviceId {
    var id = prefs.getString('device_id');
    if (id == null) {
      id = const Uuid().v4();
      prefs.setString('device_id', id);
    }
    return id;
  }

  int get lastSyncVersion => prefs.getInt('last_sync_version') ?? 0;

  Future<void> setLastSyncVersion(int version) async {
    await prefs.setInt('last_sync_version', version);
  }

  /// Pull changes from server
  Future<SyncResult> pullChanges({
    required int companyId,
    List<String>? tables,
  }) async {
    try {
      final response = await apiClient.post('/api/sync/pull', {
        'company_id': companyId,
        'device_id': deviceId,
        'last_version': lastSyncVersion,
        if (tables != null) 'tables': tables,
      });

      if (response['success'] == true) {
        final changes = response['changes'] as List;
        final currentVersion = response['current_version'] as int;

        // Apply changes to local database
        await _applyChanges(changes);

        // Update last sync version
        await setLastSyncVersion(currentVersion);

        return SyncResult(
          success: true,
          changesApplied: changes.length,
          currentVersion: currentVersion,
        );
      }

      return SyncResult(
        success: false,
        error: 'Server returned unsuccessful response',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Push local changes to server
  Future<SyncResult> pushChanges({
    required int companyId,
    required List<Map<String, dynamic>> changes,
  }) async {
    try {
      final response = await apiClient.post('/api/sync/push', {
        'company_id': companyId,
        'device_id': deviceId,
        'changes': changes,
      });

      if (response['success'] == true) {
        final idMappings = response['id_mappings'] as Map<String, dynamic>?;
        final conflicts = response['conflicts'] as List?;
        final currentVersion = response['current_version'] as int;

        // Update local IDs with server IDs
        if (idMappings != null && idMappings.isNotEmpty) {
          await _updateLocalIds(idMappings);
        }

        // Handle conflicts if any
        if (conflicts != null && conflicts.isNotEmpty) {
          // TODO: Show conflict resolution UI
          print('Conflicts detected: $conflicts');
        }

        await setLastSyncVersion(currentVersion);

        return SyncResult(
          success: true,
          changesApplied: changes.length,
          currentVersion: currentVersion,
          conflicts: conflicts?.length ?? 0,
        );
      }

      return SyncResult(
        success: false,
        error: 'Server returned unsuccessful response',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get sync status
  Future<SyncStatus?> getSyncStatus(int companyId) async {
    try {
      final response = await apiClient.get(
        '/api/sync/status',
        queryParams: {
          'company_id': companyId.toString(),
          'device_id': deviceId,
        },
      );

      if (response['success'] == true) {
        final status = response['status'];
        return SyncStatus(
          deviceId: status['device_id'],
          lastSyncVersion: status['last_sync_version'],
          currentVersion: status['current_version'],
          pendingChanges: status['pending_changes'],
          isSynced: status['is_synced'],
          lastSyncAt: status['last_sync_at'] != null
              ? DateTime.parse(status['last_sync_at'])
              : null,
        );
      }
      return null;
    } catch (e) {
      print('Error getting sync status: $e');
      return null;
    }
  }

  /// Apply changes from server to local database
  Future<void> _applyChanges(List<dynamic> changes) async {
    for (final change in changes) {
      final table = change['table'];
      final operation = change['operation'];
      final data = change['data'];
      final recordId = change['record_id'];

      try {
        switch (table) {
          case 'parties':
            await _applyPartyChange(operation, data, recordId);
            break;
          case 'products':
            await _applyProductChange(operation, data, recordId);
            break;
          // Add more cases for other tables
          default:
            print('Unknown table: $table');
        }
      } catch (e) {
        print('Error applying change for $table: $e');
      }
    }
  }

  Future<void> _applyPartyChange(
    String operation,
    Map<String, dynamic> data,
    int recordId,
  ) async {
    // TODO: Implement party change application
    // This would use PartyDao to update local database
  }

  Future<void> _applyProductChange(
    String operation,
    Map<String, dynamic> data,
    int recordId,
  ) async {
    // TODO: Implement product change application
    // This would use ProductDao to update local database
  }

  /// Update local temporary IDs with server IDs
  Future<void> _updateLocalIds(Map<String, dynamic> idMappings) async {
    // TODO: Implement ID mapping update
    // Update temporary IDs in local database with server-assigned IDs
  }

  /// Full sync - pull and push
  Future<SyncResult> fullSync(int companyId) async {
    // First pull changes from server
    final pullResult = await pullChanges(companyId: companyId);
    
    if (!pullResult.success) {
      return pullResult;
    }

    // Then push local changes (if any)
    final localChanges = await _getLocalChanges(companyId);
    
    if (localChanges.isEmpty) {
      return pullResult;
    }

    return await pushChanges(
      companyId: companyId,
      changes: localChanges,
    );
  }

  /// Get local changes that need to be pushed
  Future<List<Map<String, dynamic>>> _getLocalChanges(int companyId) async {
    // TODO: Implement local change tracking
    // Return list of changes made locally that need to be pushed
    return [];
  }
}

class SyncResult {
  final bool success;
  final int? changesApplied;
  final int? currentVersion;
  final int? conflicts;
  final String? error;

  SyncResult({
    required this.success,
    this.changesApplied,
    this.currentVersion,
    this.conflicts,
    this.error,
  });
}

class SyncStatus {
  final String deviceId;
  final int lastSyncVersion;
  final int currentVersion;
  final int pendingChanges;
  final bool isSynced;
  final DateTime? lastSyncAt;

  SyncStatus({
    required this.deviceId,
    required this.lastSyncVersion,
    required this.currentVersion,
    required this.pendingChanges,
    required this.isSynced,
    this.lastSyncAt,
  });

  bool get hasChanges => pendingChanges > 0;
}
