// ignore_for_file: unused_result, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/payment_models.dart';
import '../logic/payment_accounts_provider.dart';
import 'payment_account_form_screen.dart';
import 'payment_account_ledger_screen.dart';

class PaymentAccountsListScreen extends ConsumerStatefulWidget {
  const PaymentAccountsListScreen({super.key});

  @override
  ConsumerState<PaymentAccountsListScreen> createState() =>
      _PaymentAccountsListScreenState();
}

class _PaymentAccountsListScreenState
    extends ConsumerState<PaymentAccountsListScreen> {
  PaymentAccountType? selectedType;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(cashBankAccountsProvider);
    final company = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash & Bank Accounts'),
        elevation: 0,
        actions: [
          if (company != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  company.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'cash_bank',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PaymentAccountFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          // Filter logic
          var filteredList = accounts.where((account) {
            final matchesSearch = account.accountName
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
            final matchesType =
                selectedType == null || account.accountType == selectedType;
            return matchesSearch && matchesType && account.isActive;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                if (filteredList.isEmpty)
                  _buildEmptyState()
                else
                  _buildAccountsList(filteredList),
              ],
            ),
          );
        },
        error: (_, __) => const Center(child: Text('Error loading accounts')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search accounts...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedType != null || searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Text(
                    'Active Filters',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Cash',
                  isSelected: selectedType == PaymentAccountType.cash,
                  onTap: () {
                    setState(() {
                      selectedType = selectedType == PaymentAccountType.cash
                          ? null
                          : PaymentAccountType.cash;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Bank',
                  isSelected: selectedType == PaymentAccountType.bank,
                  onTap: () {
                    setState(() {
                      selectedType = selectedType == PaymentAccountType.bank
                          ? null
                          : PaymentAccountType.bank;
                    });
                  },
                ),
                const SizedBox(width: 8),
                // _buildFilterChip(
                //   label: 'Cheque',
                //   isSelected: selectedType == PaymentAccountType.cheque,
                //   onTap: () {
                //     setState(() {
                //       selectedType = selectedType == PaymentAccountType.cheque
                //           ? null
                //           : PaymentAccountType.cheque;
                //     });
                //   },
                // ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsList(List<PaymentAccount> accounts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: accounts.length,
        itemBuilder: (_, i) {
          final account = accounts[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAccountCard(account),
          );
        },
      ),
    );
  }

  Widget _buildAccountCard(PaymentAccount account) {
    final company = ref.watch(currentCompanyProvider);
    final accountDao = ref.watch(accountDaoProvider);

    return GestureDetector(
      onTap: account.isDefault
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentAccountFormScreen(account: account),
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getAccountTypeColor(account.accountType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        account.icon ?? _getDefaultIcon(account.accountType),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                account.accountName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (account.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildBadge(
                          account.accountType.name.toUpperCase(),
                          _getAccountTypeColor(account.accountType),
                        ),
                      ],
                    ),
                  ),
                  // Balance
                  FutureBuilder<double>(
                    future: company != null
                        ? _getAccountBalance(
                            accountDao, company.id, account.accountType)
                        : Future.value(0.0),
                    builder: (context, snapshot) {
                      final balance = snapshot.data ?? 0.0;
                      return Container(
                        decoration: BoxDecoration(
                          color: balance >= 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Balance',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '₹${balance.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: balance >= 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (account.accountType == PaymentAccountType.bank) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (account.bankName != null) ...[
                        Row(
                          children: [
                            Icon(Icons.account_balance,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              account.bankName!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (account.accountNumber != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.credit_card,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'A/c: ${account.accountNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (account.ifscCode != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.qr_code,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'IFSC: ${account.ifscCode}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentAccountLedgerScreen(account: account),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('Ledger', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                  if (!account.isDefault) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PaymentAccountFormScreen(account: account),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteAccount(account),
                      icon:
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text('Delete',
                          style: TextStyle(fontSize: 12, color: Colors.red)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<double> _getAccountBalance(
      accountDao, int companyId, PaymentAccountType type) async {
    // Get balance from accounting system based on account type
    String accountCode;
    switch (type) {
      case PaymentAccountType.cash:
        accountCode = '1000'; // Cash account
        break;
      case PaymentAccountType.bank:
        accountCode = '1100'; // Bank account
        break;
    }
    return await accountDao.getAccountBalance(companyId, accountCode);
  }

  Color _getAccountTypeColor(PaymentAccountType type) {
    switch (type) {
      case PaymentAccountType.cash:
        return Colors.green;
      case PaymentAccountType.bank:
        return Colors.blue;
    }
  }

  String _getDefaultIcon(PaymentAccountType type) {
    switch (type) {
      case PaymentAccountType.cash:
        return '💵';
      case PaymentAccountType.bank:
        return '🏦';
    }
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Accounts Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'No accounts match your search'
                : 'Add a new account to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedType = null;
      searchQuery = '';
    });
  }

  Future<void> _deleteAccount(PaymentAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${account.accountName}"?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final isar = ref.read(isarServiceProvider).isar;
        await isar.writeTxn(() async {
          await isar.paymentAccounts.delete(account.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          ref.refresh(cashBankAccountsProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
