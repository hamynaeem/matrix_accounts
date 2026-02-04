// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/providers.dart';
import 'core/config/routes.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/sync_providers.dart';
import 'core/services/auth_service.dart';
import 'core/services/biometric_service.dart';
import 'features/payments/logic/payment_providers.dart';
import 'features/sales/logic/sales_providers.dart';
import 'core/database/dao/account_dao.dart';
import 'core/database/dao/payment_dao.dart';
import 'core/database/dao/sales_dao.dart';
import 'core/database/isar_service.dart';
import 'core/mixins/app_lifecycle_mixin.dart';
import 'core/database/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  try {
    final prefs = await SharedPreferences.getInstance();
    final authService = AuthService(prefs);
    final localAuth = LocalAuthentication();
    final biometricService = BiometricService(localAuth, prefs);

    try {
      // Try to initialize Isar - this will fail on web
      final isarService = IsarService();
      await isarService.init();

      final seedData = SeedData(isarService.isar);
      await seedData.seedAll();

      final salesDao = SalesDao(isarService.isar);
      final paymentDao = PaymentDao(isarService.isar);
      final accountDao = AccountDao(isarService.isar);

      runApp(
        ProviderScope(
          overrides: [
            isarServiceProvider.overrideWithValue(isarService),
            authServiceProvider.overrideWithValue(authService),
            biometricServiceProvider.overrideWithValue(biometricService),
            salesDaoProvider.overrideWithValue(salesDao),
            paymentDaoProvider.overrideWithValue(paymentDao),
            accountDaoProvider.overrideWithValue(accountDao),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MatrixAccountsApp(),
        ),
      );
    } catch (isarError) {
      // If Isar fails (e.g., on web), run without it
      print('Isar initialization failed (likely running on web): $isarError');
      runApp(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
            biometricServiceProvider.overrideWithValue(biometricService),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MatrixAccountsApp(),
        ),
      );
    }
  } catch (e, stack) {
    print('Initialization error: $e');
    print('Stack trace: $stack');

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization Error: $e'),
          ),
        ),
      ),
    );
  }
}

class MatrixAccountsApp extends ConsumerStatefulWidget {
  const MatrixAccountsApp({super.key});

  @override
  ConsumerState<MatrixAccountsApp> createState() => _MatrixAccountsAppState();
}

class _MatrixAccountsAppState extends ConsumerState<MatrixAccountsApp>
    with WidgetsBindingObserver, AppLifecycleMixin {
  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    final theme = ref.watch(themeProvider);
    final appLockState = ref.watch(appLockStateProvider);

    // If app is locked and we're not on the lock screen, navigate to lock screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appLockState == AppLockState.locked) {
        final currentLocation = router.routeInformationProvider.value.location;
        if (currentLocation != '/lock') {
          router.go('/lock');
        }
      }
    });

    return MaterialApp.router(
      title: 'Matrix Accounts',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? Container(),
        );
      },
    );
  }
}
