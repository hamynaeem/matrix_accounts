import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/account_models.dart';
import '../../../data/models/party_model.dart';

class PartyLedgerScreen extends ConsumerWidget {
  final Party party;

  const PartyLedgerScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(currentCompanyProvider);
    final accountDao = ref.watch(accountDaoProvider);

    if (company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Party Ledger')),
        body: const Center(child: Text('No company selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${party.name} - Ledger'),
        elevation: 0,
      ),
      body: FutureBuilder<List<AccountTransaction>>(
        future: accountDao.getCustomerLedger(
          companyId: company.id,
          customerId: party.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate total balance
          double totalBalance = 0;
          for (var txn in transactions) {
            totalBalance = txn.runningBalance;
            break; // First transaction has current balance
          }

          return Column(
            children: [
              _buildBalanceCard(totalBalance),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    return _buildTransactionCard(txn);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    final isReceivable = balance > 0;
    final isPayable = balance < 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isReceivable
              ? [Colors.green.shade600, Colors.green.shade700]
              : isPayable
                  ? [Colors.red.shade600, Colors.red.shade700]
                  : [Colors.grey.shade600, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isReceivable
                    ? Colors.green
                    : isPayable
                        ? Colors.red
                        : Colors.grey)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Icon(
                isReceivable
                    ? Icons.trending_up
                    : isPayable
                        ? Icons.trending_down
                        : Icons.trending_flat,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${balance.abs().toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isReceivable
                ? 'To Receive'
                : isPayable
                    ? 'To Pay'
                    : 'Settled',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(AccountTransaction txn) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final isDebit = txn.debit > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.description ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTransactionTypeLabel(txn.transactionType),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isDebit ? '+' : '-'}₹${(isDebit ? txn.debit : txn.credit).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDebit
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance: ₹${txn.runningBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  dateFormat.format(txn.transactionDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                if (txn.referenceNo != null && txn.referenceNo!.isNotEmpty) ...[
                  Icon(Icons.receipt, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    txn.referenceNo!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.saleInvoice:
        return 'Sale Invoice';
      case TransactionType.saleReturn:
        return 'Sale Return';
      case TransactionType.paymentIn:
        return 'Payment Received';
      case TransactionType.purchaseInvoice:
        return 'Purchase Invoice';
      case TransactionType.purchaseReturn:
        return 'Purchase Return';
      case TransactionType.paymentOut:
        return 'Payment Made';
      case TransactionType.journalEntry:
        return 'Journal Entry';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
