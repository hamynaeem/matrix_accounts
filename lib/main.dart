import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/providers.dart';
import 'core/config/routes.dart';
import 'core/config/theme.dart';
import 'core/database/dao/account_dao.dart';
import 'core/database/dao/payment_dao.dart';
import 'core/database/dao/sales_dao.dart';
import 'core/database/isar_service.dart';
import 'core/database/seed_data.dart';
import 'core/services/auth_service.dart';
import 'features/payments/logic/payment_providers.dart';
import 'features/sales/logic/sales_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  try {
    final isarService = IsarService();
    await isarService.init();

    // Seed database with sample data (only runs once)
    final seedData = SeedData(isarService.isar);
    await seedData.seedAll();

    final prefs = await SharedPreferences.getInstance();
    final authService = AuthService(prefs);

    final salesDao = SalesDao(isarService.isar);
    final paymentDao = PaymentDao(isarService.isar);
    final accountDao = AccountDao(isarService.isar);

    runApp(
      ProviderScope(
        overrides: [
          isarServiceProvider.overrideWithValue(isarService),
          authServiceProvider.overrideWithValue(authService),
          salesDaoProvider.overrideWithValue(salesDao),
          paymentDaoProvider.overrideWithValue(paymentDao),
          accountDaoProvider.overrideWithValue(accountDao),
        ],
        child: const MatrixAccountsApp(),
      ),
    );
  } catch (e, stack) {
    print('Initialization error: $e');
    print('Stack trace: $stack');

    // Show error UI if initialization fails
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

class MatrixAccountsApp extends ConsumerWidget {
  const MatrixAccountsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = buildRouter();

    return MaterialApp.router(
      title: 'Matrix Accounts',
      theme: buildMatrixTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Add error boundary wrapper
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler:
                const TextScaler.linear(1.0), // Prevent text scaling issues
          ),
          child: child ?? Container(),
        );
      },
    );
  }
}
