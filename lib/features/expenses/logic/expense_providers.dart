import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder for expense-related providers
// Can be expanded with expense list, expense state, etc.

final expenseListProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return [];
});
