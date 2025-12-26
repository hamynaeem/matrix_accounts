import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cash_bank/presentation/payment_accounts_list_screen.dart';
import '../config/providers.dart';

class NavigationDrawerHelper {
  static Widget buildNavigationDrawer(
    BuildContext context, {
    required WidgetRef ref,
    String? selectedItem,
  }) {
    final currentCompany = ref.watch(currentCompanyProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Matrix Accounts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (currentCompany != null)
                  Text(
                    currentCompany.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (currentUser != null)
                  Text(
                    currentUser.fullName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                if (currentCompany == null && currentUser == null)
                  const Text(
                    'Accounting & Inventory',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Dashboard
          _buildTile(
            context: context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            selected: selectedItem == 'dashboard',
            onTap: () {
              Navigator.pop(context);
              Future.microtask(() => context.go('/dashboard'));
            },
          ),
          const Divider(height: 2),

          // Sales Section
          _buildExpansionTile(
            context: context,
            title: 'Sales',
            icon: Icons.shopping_cart,
            children: [
              _buildMenuTile(
                context: context,
                title: 'Sale Invoice',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/sales'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Payment In',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/payments/in'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Sale Return',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/sales/return');
                },
              ),
            ],
          ),

          // Purchase Section
          _buildExpansionTile(
            context: context,
            title: 'Purchase',
            icon: Icons.shopping_bag,
            children: [
              _buildMenuTile(
                context: context,
                title: 'Purchase Invoice',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/purchases'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Payment Out',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/payments/out'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Purchase Return',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/purchase/return');
                },
              ),
            ],
          ),

          // Expenses
          _buildTile(
            context: context,
            icon: Icons.receipt_long,
            title: 'Expenses',
            selected: selectedItem == 'expenses',
            onTap: () {
              Navigator.pop(context);
              Future.microtask(() => context.go('/expenses'));
            },
          ),

          // Accounts Section
          _buildExpansionTile(
            context: context,
            title: 'Accounts',
            icon: Icons.account_balance,
            children: [
              _buildMenuTile(
                context: context,
                title: 'Accounts/Parties List',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/masters/parties'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Account Ledger',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/accounts/ledger');
                },
              ),
            ],
          ),

          // Cash and Bank Section
          _buildExpansionTile(
            context: context,
            title: 'Cash and Bank',
            icon: Icons.account_balance_wallet,
            children: [
              _buildMenuTile(
                context: context,
                title: 'Payment Accounts',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentAccountsListScreen(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Cash In Hand',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/cash/hand');
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Cheques',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/cheques');
                },
              ),
            ],
          ),

          // Masters Section
          _buildExpansionTile(
            context: context,
            title: 'Masters',
            icon: Icons.inventory,
            children: [
              _buildMenuTile(
                context: context,
                title: 'Companies',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/masters/companies'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Products',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/masters/products'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Parties',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/masters/parties'));
                },
              ),
            ],
          ),

          // Reports Section
          _buildExpansionTile(
            context: context,
            title: 'Reports',
            icon: Icons.assessment,
            children: [
              // Inventory Reports
              _buildMenuTile(
                context: context,
                title: 'Inventory Reports',
                indent: true,
                onTap: () {}, // Header - no action
              ),
              _buildMenuTile(
                context: context,
                title: '  Stock Report',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/reports/stock'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  Profit & Costing',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/reports/profit'));
                },
              ),
              const Divider(height: 8),
              // Transaction Report SubSection
              _buildMenuTile(
                context: context,
                title: 'Transaction Report',
                indent: true,
                onTap: () {}, // Header - no action
              ),
              _buildMenuTile(
                context: context,
                title: '  Sale',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/reports/transactions/sale');
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  Purchase',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/reports/transactions/purchase');
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  Daybook',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/reports/daybook'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  All Transactions',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/reports/transactions/all');
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  Bill Wise Profit',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/reports/transactions/bill-wise-profit');
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  Profit Loss',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/reports/transactions/profit-loss');
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  CashFlow',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.push('/reports/cashflow'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  Balance Sheet',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(
                      () => context.push('/reports/balance-sheet'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  Trial Balance',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(
                      () => context.push('/reports/trial-balance'));
                },
              ),
              const Divider(height: 8),
              // Party Reports SubSection
              _buildMenuTile(
                context: context,
                title: 'Party Reports',
                indent: true,
                onTap: () {}, // Header - no action
              ),
              _buildMenuTile(
                context: context,
                title: '  Party Statement',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/reports/party/statement');
                },
              ),
              _buildMenuTile(
                context: context,
                title: '  Party Wise Account',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/reports/party/wise-account');
                },
              ),
            ],
          ),

          const Divider(height: 2),

          // Others Section
          _buildExpansionTile(
            context: context,
            title: 'Others',
            icon: Icons.more_horiz,
            children: [
              _buildMenuTile(
                context: context,
                title: 'Manage Companies',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => context.go('/company'));
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Settings',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/settings');
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Plans',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/plans');
                },
              ),
              _buildMenuTile(
                context: context,
                title: 'Utilities',
                indent: true,
                onTap: () {
                  Navigator.pop(context);
                  // Future: context.push('/utilities');
                },
              ),
            ],
          ),

          const Divider(height: 2),

          // Switch Company
          _buildTile(
            context: context,
            icon: Icons.swap_horiz,
            title: 'Switch Company',
            onTap: () async {
              Navigator.pop(context);

              // Clear current company selection
              ref.read(currentCompanyProvider.notifier).state = null;
              ref.read(selectedCompanyIdProvider.notifier).state = null;

              // Navigate to company selector
              Future.microtask(() => context.go('/company'));
            },
          ),

          // Logout
          _buildTile(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              Navigator.pop(context);

              // Get auth service and clear login state
              final authService = ref.read(authServiceProvider);
              await authService.logout();

              // Clear current user and company
              ref.read(currentUserProvider.notifier).state = null;
              ref.read(currentCompanyProvider.notifier).state = null;
              ref.read(selectedCompanyIdProvider.notifier).state = null;

              // Navigate to login
              Future.microtask(() => context.go('/login'));
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selected,
      selectedTileColor: Colors.blue.shade50,
      onTap: onTap,
    );
  }

  static Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        children: children,
      ),
    );
  }

  static Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    bool indent = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: indent ? 56 : 16,
        right: 16,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
      ),
      onTap: onTap,
    );
  }
}
