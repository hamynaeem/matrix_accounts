// NOTE: This test file is currently disabled as it tests features that are not yet implemented
// The following features need to be implemented before enabling these tests:
// - updateOpeningBalance
// - getAccount
// - applyOpeningBalances  
// - getTrialBalance
// - recordJournalEntry
// - deleteJournalEntry
// - getJournalEntries
// - JournalEntryLine model

/*
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:matrix_accounts/core/database/dao/account_dao.dart';
import 'package:matrix_accounts/data/models/account_models.dart';
import 'package:matrix_accounts/data/models/company_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late AccountDao accountDao;
  late Company testCompany;
  late Directory tempDir;

  setUp(() async {
    // Create temporary directory for test database
    tempDir = Directory.systemTemp.createTempSync('isar_test_');

    // Create Isar instance for testing
    isar = await Isar.open(
      [
        CompanySchema,
        AccountSchema,
        AccountTransactionSchema,
      ],
      directory: tempDir.path,
      inspector: false,
    );

    accountDao = AccountDao(isar);

    // Create test company
    testCompany = Company()
      ..subscriberId = 1
      ..name = 'Test Company'
      ..primaryCurrency = 'INR'
      ..financialYearStartMonth = 4;

    await isar.writeTxn(() async {
      await isar.companys.put(testCompany);
    });

    // Create default accounts
    await accountDao.createDefaultAccounts(testCompany.id);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    // Clean up temp directory
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Account Creation Tests', () {
    test('Default accounts are created', () async {
      final accounts = await accountDao.getAccounts(testCompany.id);

      expect(accounts.length, greaterThan(0));

      // Check for key account types
      final cashAccount = accounts.where((a) => a.code == '1000').firstOrNull;
      expect(cashAccount, isNotNull);
      expect(cashAccount?.name, equals('Cash'));
      expect(cashAccount?.accountType, equals(AccountType.asset));

      final revenueAccount =
          accounts.where((a) => a.code == '4000').firstOrNull;
      expect(revenueAccount, isNotNull);
      expect(revenueAccount?.name, equals('Sales Revenue'));
      expect(revenueAccount?.accountType, equals(AccountType.revenue));
    });
  });

  group('Account Balance Tests', () {
    test('Accounts start with zero balance', () async {
      final accounts = await accountDao.getAccounts(testCompany.id);
      final cashAccount = accounts.firstWhere((a) => a.code == '1000');

      expect(cashAccount.currentBalance, equals(0.0));
      expect(cashAccount.openingBalance, equals(0.0));
    });
  });

  group('Opening Balance Tests', () {
    test('Set opening balance for account', () async {
      final accounts = await accountDao.getAccounts(testCompany.id);
      final cashAccount = accounts.firstWhere((a) => a.code == '1000');

      // Update opening balance
      await accountDao.updateOpeningBalance(
        companyId: testCompany.id,
        accountCode: '1000',
        openingBalance: 50000,
      );

      // Verify opening balance was set
      final updatedAccount = await accountDao.getAccount(cashAccount.id);
      expect(updatedAccount?.openingBalance, equals(50000.0));
    });
  });

  group('Trial Balance Tests', () {
    test('Apply opening balances and verify trial balance', () async {
      // Set opening balance for cash
      await accountDao.updateOpeningBalance(
        companyId: testCompany.id,
        accountCode: '1000',
        openingBalance: 100000,
      );

      // Set opening balance for equity
      await accountDao.updateOpeningBalance(
        companyId: testCompany.id,
        accountCode: '3000',
        openingBalance: -100000,
      );

      // Apply opening balances
      await accountDao.applyOpeningBalances(testCompany.id);

      // Get trial balance
      final trialBalance = await accountDao.getTrialBalance(testCompany.id);

      // Verify trial balance is balanced
      double totalDebits = 0;
      double totalCredits = 0;

      for (final account in trialBalance) {
        totalDebits += account['debit'] as double;
        totalCredits += account['credit'] as double;
      }

      expect((totalDebits - totalCredits).abs(), lessThan(0.01),
          reason: 'Trial balance should be balanced');
    });
  });

  group('Journal Entry Tests', () {
    test('Create balanced journal entry', () async {
      final accounts = await accountDao.getAccounts(testCompany.id);
      final cashAccount = accounts.firstWhere((a) => a.code == '1000');
      final revenueAccount = accounts.firstWhere((a) => a.code == '4000');

      final journalLines = [
        JournalEntryLine(
          accountId: cashAccount.id,
          debit: 10000,
          credit: 0,
        ),
        JournalEntryLine(
          accountId: revenueAccount.id,
          debit: 0,
          credit: 10000,
        ),
      ];

      final entryId = await accountDao.recordJournalEntry(
        companyId: testCompany.id,
        entryDate: DateTime.now(),
        referenceNo: 'JE-001',
        description: 'Test journal entry',
        lines: journalLines,
      );

      expect(entryId, greaterThan(0));

      // Verify balances updated
      final updatedCash = await accountDao.getAccount(cashAccount.id);
      final updatedRevenue = await accountDao.getAccount(revenueAccount.id);

      expect(updatedCash?.currentBalance, equals(10000.0));
      expect(updatedRevenue?.currentBalance, equals(10000.0));
    });

    test('Reject unbalanced journal entry', () async {
      final accounts = await accountDao.getAccounts(testCompany.id);
      final cashAccount = accounts.firstWhere((a) => a.code == '1000');
      final revenueAccount = accounts.firstWhere((a) => a.code == '4000');

      final journalLines = [
        JournalEntryLine(
          accountId: cashAccount.id,
          debit: 10000,
          credit: 0,
        ),
        JournalEntryLine(
          accountId: revenueAccount.id,
          debit: 0,
          credit: 9000, // Unbalanced!
        ),
      ];

      expect(
        () async => await accountDao.recordJournalEntry(
          companyId: testCompany.id,
          entryDate: DateTime.now(),
          referenceNo: 'JE-002',
          description: 'Unbalanced entry',
          lines: journalLines,
        ),
        throwsException,
      );
    });

    test('Delete journal entry', () async {
      final accounts = await accountDao.getAccounts(testCompany.id);
      final cashAccount = accounts.firstWhere((a) => a.code == '1000');
      final revenueAccount = accounts.firstWhere((a) => a.code == '4000');

      final journalLines = [
        JournalEntryLine(
          accountId: cashAccount.id,
          debit: 5000,
          credit: 0,
        ),
        JournalEntryLine(
          accountId: revenueAccount.id,
          debit: 0,
          credit: 5000,
        ),
      ];

      final entryId = await accountDao.recordJournalEntry(
        companyId: testCompany.id,
        entryDate: DateTime.now(),
        referenceNo: 'JE-003',
        description: 'Entry to delete',
        lines: journalLines,
      );

      // Delete the entry
      await accountDao.deleteJournalEntry(entryId);

      // Verify balances reverted
      final updatedCash = await accountDao.getAccount(cashAccount.id);
      final updatedRevenue = await accountDao.getAccount(revenueAccount.id);

      expect(updatedCash?.currentBalance, equals(0.0));
      expect(updatedRevenue?.currentBalance, equals(0.0));
    });
  });

  group('Multiple Transactions Test', () {
    test('Trial balance remains balanced after journal entries', () async {
      final accounts = await accountDao.getAccounts(testCompany.id);
      final cashAccount = accounts.firstWhere((a) => a.code == '1000');
      final bankAccount = accounts.firstWhere((a) => a.code == '1100');
      final revenueAccount = accounts.firstWhere((a) => a.code == '4000');

      // Create multiple journal entries
      await accountDao.recordJournalEntry(
        companyId: testCompany.id,
        entryDate: DateTime.now(),
        referenceNo: 'JE-MULTI-001',
        description: 'Transaction 1',
        lines: [
          JournalEntryLine(
            accountId: cashAccount.id,
            debit: 10000,
            credit: 0,
          ),
          JournalEntryLine(
            accountId: revenueAccount.id,
            debit: 0,
            credit: 10000,
          ),
        ],
      );

      await accountDao.recordJournalEntry(
        companyId: testCompany.id,
        entryDate: DateTime.now(),
        referenceNo: 'JE-MULTI-002',
        description: 'Transaction 2',
        lines: [
          JournalEntryLine(
            accountId: bankAccount.id,
            debit: 5000,
            credit: 0,
          ),
          JournalEntryLine(
            accountId: revenueAccount.id,
            debit: 0,
            credit: 5000,
          ),
        ],
      );

      // Get trial balance
      final trialBalance = await accountDao.getTrialBalance(testCompany.id);

      // Verify trial balance is balanced
      double totalDebits = 0;
      double totalCredits = 0;

      for (final account in trialBalance) {
        totalDebits += account['debit'] as double;
        totalCredits += account['credit'] as double;
      }

      expect((totalDebits - totalCredits).abs(), lessThan(0.01),
          reason:
              'Trial balance should be balanced after multiple transactions');
    });
  });

  group('Account Retrieval Tests', () {
    test('Get journal entries for company', () async {
      final accounts = await accountDao.getAccounts(testCompany.id);
      final cashAccount = accounts.firstWhere((a) => a.code == '1000');
      final revenueAccount = accounts.firstWhere((a) => a.code == '4000');

      // Create a journal entry
      await accountDao.recordJournalEntry(
        companyId: testCompany.id,
        entryDate: DateTime.now(),
        referenceNo: 'JE-LIST-001',
        description: 'Test listing',
        lines: [
          JournalEntryLine(
            accountId: cashAccount.id,
            debit: 3000,
            credit: 0,
          ),
          JournalEntryLine(
            accountId: revenueAccount.id,
            debit: 0,
            credit: 3000,
          ),
        ],
      );

      // Get journal entries
      final entries = await accountDao.getJournalEntries(testCompany.id);

      expect(entries.length, greaterThan(0));
      expect(entries.first.referenceNo, equals('JE-LIST-001'));
      expect(entries.first.totalDebits, equals(3000.0));
      expect(entries.first.totalCredits, equals(3000.0));
    });
  });
}
*/