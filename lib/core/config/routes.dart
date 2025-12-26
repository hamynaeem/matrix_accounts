import 'package:go_router/go_router.dart';

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
import '../../presentation/screens/company_selector_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/login_screen.dart';
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
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
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
    ],
  );
}
