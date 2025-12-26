import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart' as app_providers;
import '../../../core/database/dao/payment_dao.dart';
import '../../../data/models/payment_models.dart';

final paymentDaoProvider = Provider<PaymentDao>((ref) {
  throw UnimplementedError('PaymentDao must be overridden in main.dart');
});

final paymentAccountsProvider =
    FutureProvider.autoDispose<List<PaymentAccount>>((ref) async {
  final paymentDao = ref.read(paymentDaoProvider);
  final company = ref.read(app_providers.currentCompanyProvider);

  if (company == null) return [];

  // Ensure default accounts exist
  await paymentDao.createDefaultAccounts(company.id);

  return await paymentDao.getPaymentAccounts(company.id);
});

final paymentInsProvider =
    FutureProvider.autoDispose<List<PaymentIn>>((ref) async {
  final paymentDao = ref.read(paymentDaoProvider);
  final company = ref.read(app_providers.currentCompanyProvider);

  if (company == null) return [];

  return await paymentDao.getPaymentIns(company.id);
});

final paymentOutsProvider =
    FutureProvider.autoDispose<List<PaymentOut>>((ref) async {
  final paymentDao = ref.read(paymentDaoProvider);
  final company = ref.read(app_providers.currentCompanyProvider);

  if (company == null) return [];

  return await paymentDao.getPaymentOuts(company.id);
});
