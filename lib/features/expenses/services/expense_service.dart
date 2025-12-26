import 'package:isar/isar.dart';

import '../../../data/models/transaction_model.dart';

class ExpenseService {
  final Isar isar;

  ExpenseService(this.isar);

  /// Get all expenses for a company
  Future<List<Transaction>> getAllExpenses(int companyId) async {
    return await isar.transactions
        .filter()
        .companyIdEqualTo(companyId)
        .typeEqualTo(TransactionType.expense)
        .sortByDateDesc()
        .findAll();
  }

  /// Search expenses by reference number
  Future<List<Transaction>> searchExpenses(int companyId, String query) async {
    final allExpenses = await getAllExpenses(companyId);

    final lowerQuery = query.toLowerCase();
    return allExpenses.where((expense) {
      return expense.referenceNo.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Delete an expense
  Future<void> deleteExpense(int expenseId) async {
    await isar.writeTxn(() async {
      final expense = await isar.transactions.get(expenseId);
      if (expense == null) return;

      // Delete transaction lines
      final lines = await isar.transactionLines
          .filter()
          .transactionIdEqualTo(expenseId)
          .findAll();

      for (final line in lines) {
        await isar.transactionLines.delete(line.id);
      }

      // Delete the expense transaction
      await isar.transactions.delete(expenseId);
    });
  }

  /// Get expense by ID
  Future<Transaction?> getExpenseById(int expenseId) async {
    return await isar.transactions.get(expenseId);
  }
}
