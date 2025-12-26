import 'package:isar/isar.dart';

import '../../../data/models/account_models.dart';
import '../../../data/models/party_model.dart';

class PartyDao {
  final Isar isar;

  PartyDao(this.isar);

  Future<void> saveParty(Party party) async {
    await isar.writeTxn(() async {
      await isar.partys.put(party);
    });
  }

  Future<List<Party>> getAllByCompany(int companyId) async {
    return isar.partys.filter().companyIdEqualTo(companyId).findAll();
  }

  Future<void> deleteParty(int id) async {
    await isar.writeTxn(() async {
      await isar.partys.delete(id);
    });
  }

  /// Update party opening balance and record in AR/AP account
  /// For customers: positive balance = customer owes us (debit AR)
  /// For suppliers: positive balance = we owe them (credit AP)
  Future<void> updatePartyOpeningBalance({
    required int partyId,
    required int companyId,
    required double openingBalance,
    DateTime? asOfDate,
  }) async {
    await isar.writeTxn(() async {
      final party = await isar.partys.get(partyId);
      if (party == null) {
        throw Exception('Party not found');
      }

      // Calculate the difference to adjust accounting
      final difference = openingBalance - party.openingBalance;

      if (difference != 0) {
        // Determine which account to update based on party type
        String accountCode;
        if (party.partyType == PartyType.customer || 
            party.partyType == PartyType.both) {
          accountCode = '1200'; // Accounts Receivable
        } else {
          accountCode = '2000'; // Accounts Payable
        }

        // Get the account
        final account = await isar.accounts
            .filter()
            .companyIdEqualTo(companyId)
            .codeEqualTo(accountCode)
            .findFirst();

        if (account != null) {
          // Update account balance
          if (accountCode == '1200') {
            // AR increases with debit (customer owes us)
            account.currentBalance += difference;
          } else {
            // AP increases with credit (we owe supplier)
            account.currentBalance += difference;
          }

          await isar.accounts.put(account);

          // Create/update opening balance transaction for this party
          final existingOB = await isar.accountTransactions
              .filter()
              .companyIdEqualTo(companyId)
              .accountIdEqualTo(account.id)
              .partyIdEqualTo(partyId)
              .transactionTypeEqualTo(TransactionType.journalEntry)
              .descriptionContains('Opening Balance')
              .findFirst();

          if (existingOB != null) {
            // Delete old opening balance entry
            // Reverse its effect
            account.currentBalance -= (existingOB.debit - existingOB.credit);
            await isar.accountTransactions.delete(existingOB.id);
          }

          if (openingBalance != 0) {
            // Create new opening balance transaction
            final transaction = AccountTransaction()
              ..companyId = companyId
              ..accountId = account.id
              ..transactionType = TransactionType.journalEntry
              ..referenceId = 0
              ..transactionDate = asOfDate ?? DateTime.now()
              ..description = 'Opening Balance - ${party.name}'
              ..referenceNo = 'OB-${party.name}'
              ..partyId = partyId;

            // For AR (Asset): Debit increases, Credit decreases
            // For AP (Liability): Credit increases, Debit decreases
            if (accountCode == '1200') {
              // Accounts Receivable
              if (openingBalance > 0) {
                transaction.debit = openingBalance;
                transaction.credit = 0;
              } else {
                transaction.debit = 0;
                transaction.credit = openingBalance.abs();
              }
            } else {
              // Accounts Payable
              if (openingBalance > 0) {
                transaction.debit = 0;
                transaction.credit = openingBalance;
              } else {
                transaction.debit = openingBalance.abs();
                transaction.credit = 0;
              }
            }

            // Update account balance with new opening balance
            account.currentBalance += (transaction.debit - transaction.credit);
            transaction.runningBalance = account.currentBalance;

            await isar.accountTransactions.put(transaction);
            await isar.accounts.put(account);
          }
        }
      }

      // Update party record
      party.openingBalance = openingBalance;
      await isar.partys.put(party);
    });
  }

  /// Get party balance from ledger (AR or AP account)
  Future<double> getPartyBalance({
    required int partyId,
    required int companyId,
  }) async {
    final party = await isar.partys.get(partyId);
    if (party == null) return 0;

    // Determine which account to check
    String accountCode;
    if (party.partyType == PartyType.customer || 
        party.partyType == PartyType.both) {
      accountCode = '1200'; // Accounts Receivable
    } else {
      accountCode = '2000'; // Accounts Payable
    }

    final account = await isar.accounts
        .filter()
        .companyIdEqualTo(companyId)
        .codeEqualTo(accountCode)
        .findFirst();

    if (account == null) return 0;

    // Get latest transaction for this party
    final latestTransaction = await isar.accountTransactions
        .filter()
        .companyIdEqualTo(companyId)
        .accountIdEqualTo(account.id)
        .partyIdEqualTo(partyId)
        .sortByTransactionDateDesc()
        .findFirst();

    return latestTransaction?.runningBalance ?? 0;
  }
}
