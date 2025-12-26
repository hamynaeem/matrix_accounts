import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/payment_models.dart';
import '../../payments/logic/payment_providers.dart';

final cashBankAccountsProvider =
    FutureProvider<List<PaymentAccount>>((ref) async {
  final paymentDao = ref.watch(paymentDaoProvider);
  final company = ref.watch(currentCompanyProvider);

  if (company == null) return [];

  return await paymentDao.getPaymentAccounts(company.id);
});
