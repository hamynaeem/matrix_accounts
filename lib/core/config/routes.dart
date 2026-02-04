import 'package:go_router/go_router.dart';
import 'package:matrix_accounts/features/cash_in_hand.dart';
import 'package:matrix_accounts/features/parties/presentation/party_form_screen.dart';
import 'package:matrix_accounts/features/plans.dart';
import 'package:matrix_accounts/features/profit_loss.dart';
import 'package:matrix_accounts/features/purchases/presentation/purchase_return_list_screen.dart'
    show PurchaseReturnListScreen;
import 'package:matrix_accounts/features/purchases/presentation/purchase_return_form_screen.dart';
import 'package:matrix_accounts/features/purchases/purchase_report.dart';
import 'package:matrix_accounts/features/reports/presentation/account_ledger_screen.dart';

import 'package:matrix_accounts/features/sales/presentation/sale_return_list_screen.dart';
import 'package:matrix_accounts/features/sales/presentation/sale_return_form_screen.dart';
import 'package:matrix_accounts/features/settings/presentation/company_settings_screen.dart';
import 'package:matrix_accounts/settings/about_settings_screen.dart';
import 'package:matrix_accounts/settings/financial_year_settings_screen.dart';
import 'package:matrix_accounts/settings/lock_screen.dart';
import 'package:matrix_accounts/settings/setting.dart';
import 'package:matrix_accounts/settings/tax_settings_screen.dart'
    show TaxSettingsScreen;
import 'package:matrix_accounts/settings/theme_settings_screen.dart';

import '../../features/companies/presentation/company_form_screen.dart';
import '../../features/companies/presentation/company_list_screen.dart';
import '../../features/expenses/presentation/expense_form_screen.dart';
import '../../features/expenses/presentation/expense_list_screen.dart';
import '../../features/inventory/presentation/product_list_screen.dart';
import '../../features/parties/presentation/party_list_screen.dart';
import '../../features/payments/presentation/payment_in_form_screen.dart';
import '../../features/payments/presentation/payment_in_list_screen.dart';
import '../../features/payments/presentation/payment_out_form_screen.dart';
import '../../features/payments/presentation/payment_out_list_screen.dart';
import '../../features/purchases/presentation/purchase_invoice_form_screen.dart';
import '../../features/purchases/presentation/purchase_invoice_list_screen.dart';
import '../../features/reports/presentation/balance_sheet_screen.dart';
import '../../features/reports/presentation/cashflow_screen.dart';
import '../../features/reports/presentation/daybook_screen.dart';
import '../../features/reports/presentation/profit_report_screen.dart';
import '../../features/reports/presentation/stock_report_screen.dart';
import '../../features/reports/presentation/trial_balance_screen.dart';
import '../../features/sales/presentation/sale_invoice_list_screen.dart';
import '../../features/sales/presentation/sales_invoice_form_screen.dart';
import '../../presentation/screens/about_screen.dart';
import '../../presentation/screens/company_selector_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/help_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/splash_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/company',
        builder: (context, state) => const CompanySelectorScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/plans',
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SaleInvoiceListScreen(),
      ),
      GoRoute(
        path: '/sales/invoice/form',
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final invoiceId = idParam != null ? int.tryParse(idParam) : null;
          return SalesInvoiceFormScreen(invoiceId: invoiceId);
        },
      ),
      GoRoute(
        path: '/purchases',
        builder: (context, state) => const PurchaseInvoiceListScreen(),
      ),
      GoRoute(
        path: '/purchases/invoice/form',
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final invoiceId = idParam != null ? int.tryParse(idParam) : null;
          return PurchaseInvoiceFormScreen(invoiceId: invoiceId);
        },
      ),
      GoRoute(
        path: '/purchases/return/form',
        builder: (context, state) => const PurchaseReturnFormScreen(),
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: '/expenses/form',
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final expenseId = idParam != null ? int.tryParse(idParam) : null;
          return ExpenseFormScreen(expenseId: expenseId);
        },
      ),
      GoRoute(
        path: '/payments/in',
        builder: (context, state) => const PaymentInListScreen(),
      ),
      GoRoute(
        path: '/payments/in/form',
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final paymentInId = idParam != null ? int.tryParse(idParam) : null;
          return PaymentInFormScreen(paymentInId: paymentInId);
        },
      ),
      GoRoute(
        path: '/payments/out',
        builder: (context, state) => const PaymentOutListScreen(),
      ),
      GoRoute(
        path: '/payments/out/form',
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final paymentOutId = idParam != null ? int.tryParse(idParam) : null;
          return PaymentOutFormScreen(paymentOutId: paymentOutId);
        },
      ),
      GoRoute(
        path: '/masters/companies',
        builder: (context, state) => const CompanyListScreen(),
      ),
      GoRoute(
        path: '/masters/companies/form',
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final companyId = idParam != null ? int.tryParse(idParam) : null;
          return CompanyFormScreen(companyId: companyId);
        },
      ),
      GoRoute(
        path: '/masters/parties',
        builder: (context, state) => const PartyListScreen(),
      ),
      GoRoute(
        path: '/masters/products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/reports/stock',
        builder: (context, state) => const StockReportScreen(),
      ),
      GoRoute(
        path: '/reports/profit',
        builder: (context, state) => const ProfitReportScreen(),
      ),
      GoRoute(
        path: '/reports/daybook',
        builder: (context, state) => const DaybookScreen(),
      ),
      GoRoute(
        path: '/reports/balance-sheet',
        builder: (context, state) => const BalanceSheetScreen(),
      ),
      GoRoute(
        path: '/reports/cashflow',
        builder: (context, state) => const CashFlowScreen(),
      ),
      GoRoute(
        path: '/reports/trial-balance',
        builder: (context, state) => const TrialBalanceScreen(),
      ),
      GoRoute(
          path: '/accounts/ledger',
          builder: (context, state) => const AccountLedgerScreen()),
      GoRoute(
          path: '/parties/stateentry',
          builder: (context, state) => const PartyFormScreen()),
      GoRoute(
        path: '/cash-in-hand',
        builder: (context, state) => const CashInHandScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const Settings_Screen(),
      ),
      GoRoute(
        path: '/reports/purchases',
        builder: (context, state) => const PurchaseReportScreen(),
      ),
      GoRoute(
          path: '/profit/loss',
          builder: (context, state) {
            return const ProfitLossScreen();
          }),
      GoRoute(
          path: '/purchase/return',
          builder: (context, state) {
            return const PurchaseReturnListScreen();
          }),
      GoRoute(
        path: '/sale/return',
        builder: (context, state) => const SaleReturnListScreen(),
      ),
      GoRoute(
        path: '/sales/return/form',
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final returnId = idParam != null ? int.tryParse(idParam) : null;
          return SaleReturnFormScreen(returnId: returnId);
        },
      ),

      // Main Settings Screen
      GoRoute(
        path: '/settings',
        builder: (context, state) => const Settings_Screen(),
      ),

      // Settings Sub-screens
      GoRoute(
        path: '/settings/company-settings',
        builder: (context, state) => const CompanySettingsScreen(),
      ),
      GoRoute(
        path: '/settings/financial-year',
        builder: (context, state) => const FinancialYearSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/tax-settings',
        builder: (context, state) => const TaxSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/theme-settings',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/about-settings',
        builder: (context, state) => const AboutSettingsScreen(),
      ),

      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
