import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/providers.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final company = ref.watch(currentCompanyProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    IconData syncIcon;
    Color syncColor;

    switch (syncStatus) {
      case SyncStatus.syncing:
        syncIcon = Icons.sync;
        syncColor = Colors.orange;
        break;
      case SyncStatus.error:
        syncIcon = Icons.sync_problem;
        syncColor = Colors.red;
        break;
      default:
        syncIcon = Icons.check_circle;
        syncColor = Colors.green;
    }

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company?.name ?? 'Select Company',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.fullName ?? 'Guest User',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(syncIcon, size: 18, color: syncColor),
                    const SizedBox(width: 4),
                    Text(
                      'Sync',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.sync),
                      tooltip: 'Manual Sync',
                      onPressed: () {
                        // TODO: trigger sync
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _menuItem(context, 'Dashboard', Icons.dashboard, '/dashboard'),
                const Divider(height: 1),
                _sectionHeader(context, 'Transactions'),
                _menuItem(context, 'Sales', Icons.point_of_sale, '/sales'),
                _menuItem(
                    context, 'Purchases', Icons.shopping_cart, '/purchases'),
                _menuItem(context, 'Expenses', Icons.receipt_long, '/expenses'),
                const Divider(height: 1),
                _sectionHeader(context, 'Reports'),
                // Reports routes to be wired later
                const Divider(height: 1),
                _sectionHeader(context, 'Masters'),
                _menuItem(
                    context, 'Parties', Icons.people_alt, '/masters/parties'),
                _menuItem(
                    context, 'Products', Icons.category, '/masters/products'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
