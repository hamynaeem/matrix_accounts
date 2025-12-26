import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/party_dao.dart';
import '../../../data/models/party_model.dart';

final partyDaoProvider = Provider<PartyDao>((ref) {
  final isar = ref.read(isarServiceProvider).isar;
  return PartyDao(isar);
});

final partyListProvider = FutureProvider<List<Party>>((ref) async {
  final dao = ref.read(partyDaoProvider);
  final company = ref.read(currentCompanyProvider);
  if (company == null) return [];
  return dao.getAllByCompany(company.id);
});
