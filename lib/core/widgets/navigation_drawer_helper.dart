// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cash_bank/presentation/payment_accounts_list_screen.dart';
import '../config/providers.dart';

class NavigationDrawerHelper {
  static Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color? color,
    double horizontalPadding = 20.0,
    bool isTablet = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 14, vertical: isTablet ? 4 : 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
        color: selected
            ? theme.colorScheme.primaryContainer.withOpacity(0.20)
            : Colors.transparent,
        border: selected
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              )
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
          hoverColor: theme.colorScheme.primary.withOpacity(0.12),
          splashColor: theme.colorScheme.primary.withOpacity(0.20),
          highlightColor: theme.colorScheme.primary.withOpacity(0.15),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.fastEaseInToSlowEaseOut,
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: isTablet ? 16 : 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary.withOpacity(0.12)
                        : (color ?? theme.colorScheme.primary)
                            .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? theme.colorScheme.primary
                        : color ?? theme.colorScheme.onSurfaceVariant,
                    size: isTablet ? 26 : 22,
                  ),
                ),
                SizedBox(width: isTablet ? 18 : 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: isTablet ? 17 : 16,
                      letterSpacing: -0.1,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
    bool isTablet = false,
  }) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastEaseInToSlowEaseOut,
      margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 14, vertical: isTablet ? 6 : 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
        color: theme.colorScheme.surfaceContainer.withOpacity(0.4),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            collapsedIconColor:
                theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          child: ExpansionTile(
            leading: Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (iconColor ?? theme.colorScheme.primary).withOpacity(0.15),
                    (iconColor ?? theme.colorScheme.primary).withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? theme.colorScheme.primary)
                        .withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 17 : 16,
                letterSpacing: -0.1,
                height: 1.3,
              ),
            ),
            tilePadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 20, vertical: isTablet ? 12 : 8),
            childrenPadding: EdgeInsets.only(
              left: isTablet ? 20 : 16,
              right: isTablet ? 20 : 16,
              bottom: isTablet ? 12 : 8,
              top: isTablet ? 4 : 2,
            ),
            maintainState: true,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.centerLeft,
            expansionAnimationStyle: const AnimationStyle(
              duration: Duration(milliseconds: 400),
              curve: Curves.fastEaseInToSlowEaseOut,
            ),
            children: children,
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    bool indent = false,
    double leftPadding = 32.0,
    double rightPadding = 16.0,
    bool isTablet = false,
    bool isHeader = false,
  }) {
    final theme = Theme.of(context);

    if (isHeader) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 8,
          vertical: isTablet ? 8 : 6,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 8 : 6,
        ),
        child: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: isTablet ? 14 : 12,
            color: theme.colorScheme.primary.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            height: 1.2,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 2 : 1.5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          hoverColor: theme.colorScheme.primary.withOpacity(0.10),
          splashColor: theme.colorScheme.primary.withOpacity(0.16),
          highlightColor: theme.colorScheme.primary.withOpacity(0.08),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastEaseInToSlowEaseOut,
            padding: EdgeInsets.only(
              left: indent ? leftPadding + (isTablet ? 20 : 16) : leftPadding,
              right: rightPadding,
              top: isTablet ? 12 : 10,
              bottom: isTablet ? 12 : 10,
            ),
            child: Row(
              children: [
                if (indent && !title.startsWith('  '))
                  Container(
                    margin: EdgeInsets.only(right: isTablet ? 16 : 12),
                    child: Container(
                      width: isTablet ? 6 : 4,
                      height: isTablet ? 6 : 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    title.startsWith('  ') ? title.substring(2) : title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: isTablet ? 15 : 14,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.05,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _modernDivider({double padding = 18.0, bool isTablet = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastEaseInToSlowEaseOut,
      margin: EdgeInsets.symmetric(
          horizontal: padding + (isTablet ? 8 : 4),
          vertical: isTablet ? 16 : 12),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.grey.withOpacity(0.12),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  static Widget buildNavigationDrawer(
    BuildContext context, {
    required WidgetRef ref,
    String? selectedItem,
  }) {
    final currentCompany = ref.watch(currentCompanyProvider);
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final avatarRadius = isTablet ? 36.0 : 28.0;
        final headerPadding = isTablet
            ? const EdgeInsets.fromLTRB(32, 48, 32, 32)
            : const EdgeInsets.fromLTRB(20, 32, 16, 20);
        final tileHorizontal = isTablet ? 32.0 : 20.0;
        final menuTileLeft = isTablet ? 72.0 : 32.0;
        final menuTileRight = isTablet ? 32.0 : 16.0;
        final dividerPadding = isTablet ? 32.0 : 18.0;

        return Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            elevation: 16,
            backgroundColor: theme.colorScheme.surface.withOpacity(0.98),
            shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
            width: isTablet ? 400 : 320,
            child: GestureDetector(
                onTap: () {}, // Prevent accidental closes when tapping content
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    child: SafeArea(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(
                          parent: ClampingScrollPhysics(),
                          decelerationRate: ScrollDecelerationRate.fast,
                        ),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primaryContainer
                                      .withOpacity(0.9),
                                  theme.colorScheme.primaryContainer
                                      .withOpacity(0.6),
                                  theme.colorScheme.surface.withOpacity(0.8),
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(28),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                  spreadRadius: -4,
                                ),
                                BoxShadow(
                                  color: theme.colorScheme.shadow
                                      .withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: headerPadding,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: avatarRadius,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      child: Text(
                                        currentUser?.fullName.isNotEmpty == true
                                            ? currentUser!.fullName[0]
                                                .toUpperCase()
                                            : 'M',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 24 : 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isTablet ? 24 : 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Matrix Accounts',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w700,
                                            fontSize: isTablet ? 26 : 22,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(height: isTablet ? 8 : 4),
                                        if (currentCompany != null)
                                          Text(
                                            currentCompany.name,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              color: theme.colorScheme
                                                  .onPrimaryContainer
                                                  .withOpacity(0.9),
                                              fontWeight: FontWeight.w600,
                                              fontSize: isTablet ? 17 : 15,
                                              letterSpacing: -0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (currentUser != null)
                                          Text(
                                            currentUser.fullName,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme.colorScheme
                                                  .onPrimaryContainer
                                                  .withOpacity(0.75),
                                              fontSize: isTablet ? 15 : 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (currentCompany == null &&
                                            currentUser == null)
                                          Text(
                                            'Accounting & Inventory Management',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme.colorScheme
                                                  .onPrimaryContainer
                                                  .withOpacity(0.75),
                                              fontSize: isTablet ? 15 : 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 20 : 12),
                          // Dashboard
                          _buildTile(
                            context: context,
                            icon: Icons.dashboard_outlined,
                            title: 'Dashboard',
                            selected: selectedItem == 'dashboard',
                            onTap: () {
                              Navigator.pop(context);
                              Future.microtask(() => context.go('/dashboard'));
                            },
                            color: theme.colorScheme.primary,
                            horizontalPadding: tileHorizontal,
                            isTablet: isTablet,
                          ),
                          _modernDivider(
                              padding: dividerPadding, isTablet: isTablet),

                          // Sales Section
                          _buildExpansionTile(
                            context: context,
                            title: 'Sales',
                            icon: Icons.shopping_cart_outlined,
                            iconColor: theme.colorScheme.secondary,
                            isTablet: isTablet,
                            children: [
                              _buildMenuTile(
                                context: context,
                                title: 'Sale Invoice',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/sales'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: 'Sale Return',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/sale/return'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                            ],
                          ),

                          // Purchase Section
                          _buildExpansionTile(
                            context: context,
                            title: 'Purchase',
                            icon: Icons.shopping_bag_outlined,
                            iconColor: theme.colorScheme.tertiary,
                            isTablet: isTablet,
                            children: [
                              _buildMenuTile(
                                context: context,
                                title: 'Purchase Invoice',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/purchases'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: 'Purchase Return',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/purchase/return'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                            ],
                          ),
                          _buildExpansionTile(
                            context: context,
                            title: 'Payments',
                            icon: Icons.shopping_cart_outlined,
                            iconColor: theme.colorScheme.secondary,
                            isTablet: isTablet,
                            children: [
                              _buildMenuTile(
                                context: context,
                                title: 'Payment In',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/payments/in'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: 'Payment Out',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/payments/out'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              // Expenses
                              _buildTile(
                                context: context,
                                icon: Icons.receipt_long_outlined,
                                title: 'Expenses',
                                selected: selectedItem == 'expenses',
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.go('/expenses'));
                                },
                                color: theme.colorScheme.secondary,
                                horizontalPadding: tileHorizontal,
                                isTablet: isTablet,
                              ),
                            ],
                          ),

                          // Accounts Section
                          _buildExpansionTile(
                            context: context,
                            title: 'Accounts/Parties',
                            icon: Icons.account_balance_outlined,
                            iconColor: theme.colorScheme.primary,
                            isTablet: isTablet,
                            children: [
                              _buildMenuTile(
                                context: context,
                                title: 'Accounts/Parties List',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/masters/parties'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: 'Account Ledger',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/accounts/ledger'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                            ],
                          ),

                          // Cash and Bank Section
                          _buildExpansionTile(
                            context: context,
                            title: 'Cash and Bank',
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: theme.colorScheme.secondary,
                            isTablet: isTablet,
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
                                      builder: (_) =>
                                          const PaymentAccountsListScreen(),
                                    ),
                                  );
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: 'Cash In Hand',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/cash-in-hand'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                            ],
                          ),

                          // Masters Section
                          _buildExpansionTile(
                            context: context,
                            title: 'Masters',
                            icon: Icons.inventory_2_outlined,
                            iconColor: theme.colorScheme.tertiary,
                            isTablet: isTablet,
                            children: [
                              _buildMenuTile(
                                context: context,
                                title: 'Companies',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/masters/companies'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: 'Products',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/masters/products'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: 'Parties',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/masters/parties'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                            ],
                          ),

                          // Reports Section
                          _buildExpansionTile(
                            context: context,
                            title: 'Reports',
                            icon: Icons.analytics_outlined,
                            iconColor: theme.colorScheme.primary,
                            isTablet: isTablet,
                            children: [
                              // // Inventory Reports
                              // _buildMenuTile(
                              //   context: context,
                              //   title: 'Inventory Reports',
                              //   indent: false,
                              //   onTap: () {}, // Header - no action
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              //   isHeader: true,
                              // ),
                              _buildMenuTile(
                                context: context,
                                title: '  Stock Report',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/reports/stock'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              // _buildMenuTile(
                              //   context: context,
                              //   title: '  Profit & Costing',
                              //   indent: true,
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     Future.microtask(
                              //         () => context.push('/reports/profit'));
                              //   },
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              // ),

                              SizedBox(height: isTablet ? 12 : 8),

                              // // Transaction Reports
                              // _buildMenuTile(
                              //   context: context,
                              //   title: 'Transaction Reports',
                              //   indent: false,
                              //   onTap: () {}, // Header - no action
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              //   isHeader: true,
                              // ),
                              _buildMenuTile(
                                context: context,
                                title: '  Sales Report',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/sales/report'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: '  Purchase Report',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/reports/purchases'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: '  Daybook',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/reports/daybook'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              // _buildMenuTile(
                              //   context: context,
                              //   title: '  All Transactions',
                              //   indent: true,
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     Future.microtask(
                              //         () => context.push('/reports/transactions/all'));
                              //   },
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              // ),

                              SizedBox(height: isTablet ? 12 : 8),

                              // // Financial Reports
                              // _buildMenuTile(
                              //   context: context,
                              //   title: 'Financial Reports',
                              //   indent: false,
                              //   onTap: () {}, // Header - no action
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              //   isHeader: true,
                              // ),
                              _buildMenuTile(
                                context: context,
                                title: '  Profit & Loss',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/profit/loss'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: '  Cash Flow',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/reports/cashflow'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: '  Balance Sheet',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(() =>
                                      context.push('/reports/balance-sheet'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              // _buildMenuTile(
                              //   context: context,
                              //   title: '  Trial Balance',
                              //   indent: true,
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     Future.microtask(
                              //         () => context.push('/reports/trial-balance'));
                              //   },
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              // ),

                              // // Party Reports
                              // _buildMenuTile(
                              //   context: context,
                              //   title: 'Party Reports',
                              //   indent: false,
                              //   onTap: () {}, // Header - no action
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              //   isHeader: true,
                              // ),
                              // _buildMenuTile(
                              //   context: context,
                              //   title: '  Party Statement',
                              //   indent: true,
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     Future.microtask(
                              //         () => context.push('/parties/stateentry'));
                              //   },
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              // ),
                              // _buildMenuTile(
                              //   context: context,
                              //   title: '  Party Wise Account',
                              //   indent: true,
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     Future.microtask(() =>
                              //         context.push('/reports/party/wise-account'));
                              //   },
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              // ),
                            ],
                          ),

                          _modernDivider(isTablet: isTablet),

                          // Others Section
                          _buildExpansionTile(
                            context: context,
                            title: 'Others',
                            icon: Icons.more_horiz_outlined,
                            iconColor: theme.colorScheme.secondary,
                            isTablet: isTablet,
                            children: [
                              _buildMenuTile(
                                context: context,
                                title: 'Manage Companies',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.go('/company'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              _buildMenuTile(
                                context: context,
                                title: 'Settings',
                                indent: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  Future.microtask(
                                      () => context.push('/settings'));
                                },
                                leftPadding: menuTileLeft,
                                rightPadding: menuTileRight,
                                isTablet: isTablet,
                              ),
                              // _buildMenuTile(
                              //   context: context,
                              //   title: 'Plans',
                              //   indent: true,
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     Future.microtask(() => context.push('/plans'));
                              //   },
                              //   leftPadding: menuTileLeft,
                              //   rightPadding: menuTileRight,
                              //   isTablet: isTablet,
                              // ),
                            ],
                          ),

                          _modernDivider(isTablet: isTablet),

                          // Switch Company
                          _buildTile(
                            context: context,
                            icon: Icons.swap_horizontal_circle_outlined,
                            title: 'Switch Company',
                            onTap: () async {
                              Navigator.pop(context);

                              // Clear current company selection
                              ref.read(currentCompanyProvider.notifier).state =
                                  null;
                              ref
                                  .read(selectedCompanyIdProvider.notifier)
                                  .state = null;

                              // Navigate to company selector
                              Future.microtask(() => context.go('/company'));
                            },
                            color: theme.colorScheme.tertiary,
                            horizontalPadding: tileHorizontal,
                            isTablet: isTablet,
                          ),

                          // Logout
                          _buildTile(
                            context: context,
                            icon: Icons.logout_outlined,
                            title: 'Logout',
                            onTap: () async {
                              Navigator.pop(context);

                              // Get auth service and clear login state
                              final authService = ref.read(authServiceProvider);
                              await authService.logout();

                              // Clear current user and company
                              ref.read(currentUserProvider.notifier).state =
                                  null;
                              ref.read(currentCompanyProvider.notifier).state =
                                  null;
                              ref
                                  .read(selectedCompanyIdProvider.notifier)
                                  .state = null;

                              // Navigate to login
                              Future.microtask(() => context.go('/login'));
                            },
                            color: theme.colorScheme.error,
                            horizontalPadding: tileHorizontal,
                            isTablet: isTablet,
                          ),
                          SizedBox(height: isTablet ? 20 : 12),
                        ],
                      ),
                    ))));
      },
    );
  }
}
