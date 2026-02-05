import 'dart:async';

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
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();

    // Safety timeout to prevent infinite loading
    Timer(const Duration(seconds: 10), () {
      if (mounted && !_isNavigating) {
        print('Splash timeout reached, navigating to login');
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (!_isNavigating && mounted) {
      _isNavigating = true;
      context.go('/login');
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
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
                  ref.read(selectedCompanyIdProvider.notifier).state =
                      company.id;

                  // Navigate to dashboard with safety check
                  if (mounted && !_isNavigating) {
                    _isNavigating = true;
                    context.go('/dashboard');
                  }
                } else {
                  // Company no longer exists or is inactive, go to company selection
                  await authService.clearSelectedCompany();
                  if (mounted && !_isNavigating) {
                    _isNavigating = true;
                    context.go('/company');
                  }
                }
              } catch (e) {
                print('Error loading company: $e');
                // Error loading company, go to company selection
                await authService.clearSelectedCompany();
                if (mounted && !_isNavigating) {
                  _isNavigating = true;
                  context.go('/company');
                }
              }
            } else {
              // Invalid company ID, go to company selection
              if (mounted && !_isNavigating) {
                _isNavigating = true;
                context.go('/company');
              }
            }
          } else {
            // No company selected, go to company selection
            if (mounted && !_isNavigating) {
              _isNavigating = true;
              context.go('/company');
            }
          }
        } else {
          // Invalid persisted state, go to login
          await authService.logout();
          if (mounted && !_isNavigating) {
            _isNavigating = true;
            context.go('/login');
          }
        }
      } else {
        // Not logged in, go to login
        if (mounted && !_isNavigating) {
          _isNavigating = true;
          context.go('/login');
        }
      }
    } catch (e, stackTrace) {
      print('Error in _checkAuthAndNavigate: $e');
      print('Stack trace: $stackTrace');

      // Fallback to login on any error
      if (mounted && !_isNavigating) {
        try {
          final authService = ref.read(authServiceProvider);
          await authService.logout();
        } catch (_) {
          // Ignore logout errors
        }
        _isNavigating = true;
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
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
