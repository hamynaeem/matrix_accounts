import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/providers.dart';
import '../providers/sync_providers.dart';

class SyncButton extends ConsumerWidget {
  final bool showLabel;
  final VoidCallback? onSyncComplete;

  const SyncButton({
    super.key,
    this.showLabel = true,
    this.onSyncComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);
    final currentCompany = ref.watch(currentCompanyProvider);

    if (currentCompany == null) {
      return const SizedBox.shrink();
    }

    final isLoading = syncState.state == SyncState.syncing;

    return showLabel
        ? ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () => _performSync(context, ref, currentCompany.id),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: Text(_getButtonLabel(syncState)),
          )
        : IconButton(
            onPressed: isLoading
                ? null
                : () => _performSync(context, ref, currentCompany.id),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: _getButtonLabel(syncState),
          );
  }

  String _getButtonLabel(SyncStateData state) {
    switch (state.state) {
      case SyncState.idle:
        return 'Sync';
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.success:
        return 'Synced';
      case SyncState.error:
        return 'Retry Sync';
    }
  }

  Future<void> _performSync(
    BuildContext context,
    WidgetRef ref,
    int companyId,
  ) async {
    final notifier = ref.read(syncStateProvider.notifier);
    await notifier.performSync(companyId);

    final syncState = ref.read(syncStateProvider);

    if (context.mounted) {
      if (syncState.state == SyncState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync completed! ${syncState.changesApplied ?? 0} changes applied.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        onSyncComplete?.call();
      } else if (syncState.state == SyncState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(syncState.message ?? 'Sync failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(syncState.state).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(syncState.state),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(syncState.state),
            size: 16,
            color: _getStatusColor(syncState.state),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(syncState),
            style: TextStyle(
              color: _getStatusColor(syncState.state),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SyncState state) {
    switch (state) {
      case SyncState.idle:
        return Colors.grey;
      case SyncState.syncing:
        return Colors.blue;
      case SyncState.success:
        return Colors.green;
      case SyncState.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(SyncState state) {
    switch (state) {
      case SyncState.idle:
        return Icons.sync_disabled;
      case SyncState.syncing:
        return Icons.sync;
      case SyncState.success:
        return Icons.check_circle;
      case SyncState.error:
        return Icons.error;
    }
  }

  String _getStatusText(SyncStateData state) {
    switch (state.state) {
      case SyncState.idle:
        return 'Not synced';
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.success:
        if (state.lastSyncTime != null) {
          final diff = DateTime.now().difference(state.lastSyncTime!);
          if (diff.inMinutes < 1) {
            return 'Just now';
          } else if (diff.inHours < 1) {
            return '${diff.inMinutes}m ago';
          } else if (diff.inDays < 1) {
            return '${diff.inHours}h ago';
          } else {
            return '${diff.inDays}d ago';
          }
        }
        return 'Synced';
      case SyncState.error:
        return 'Error';
    }
  }
}
