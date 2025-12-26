import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/purchase_dao.dart';

final purchaseDaoProvider = Provider<PurchaseDao>((ref) {
  final isar = ref.read(isarServiceProvider).isar;
  return PurchaseDao(isar);
});
