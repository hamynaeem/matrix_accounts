import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/providers.dart';
import '../../features/companies/services/company_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Small delay to show splash
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final authService = ref.read(authServiceProvider);

    // Check if user is logged in
    if (authService.isLoggedIn) {
      // Get persisted user
      final user = authService.getPersistedUser();

      if (user != null) {
        // Restore user state
        ref.read(currentUserProvider.notifier).state = user;

        // Check if company has been selected
        if (authService.hasSelectedCompany) {
          // Load and set the selected company
          final companyId = authService.selectedCompanyId;
          if (companyId != null) {
            try {
              final isar = ref.read(isarServiceProvider).isar;
              final service = CompanyService(isar);
              final company = await service.getCompanyById(companyId);

              if (company != null && company.isActive) {
                // Restore company state
                ref.read(currentCompanyProvider.notifier).state = company;
                ref.read(selectedCompanyIdProvider.notifier).state = company.id;

                // Navigate to dashboard
                context.go('/dashboard');
              } else {
                // Company no longer exists or is inactive, go to company selection
                await authService.clearSelectedCompany();
                context.go('/company');
              }
            } catch (e) {
              // Error loading company, go to company selection
              await authService.clearSelectedCompany();
              context.go('/company');
            }
          } else {
            // Invalid company ID, go to company selection
            context.go('/company');
          }
        } else {
          // No company selected, go to company selection
          context.go('/company');
        }
      } else {
        // Invalid persisted state, go to login
        await authService.logout();
        context.go('/login');
      }
    } else {
      // Not logged in, go to login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Matrix Accounts',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
