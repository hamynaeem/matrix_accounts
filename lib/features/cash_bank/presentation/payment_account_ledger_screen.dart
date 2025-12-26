import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/account_models.dart';
import '../../../data/models/payment_models.dart';

class PaymentAccountLedgerScreen extends ConsumerStatefulWidget {
  final PaymentAccount account;

  const PaymentAccountLedgerScreen({super.key, required this.account});

  @override
  ConsumerState<PaymentAccountLedgerScreen> createState() =>
      _PaymentAccountLedgerScreenState();
}

class _PaymentAccountLedgerScreenState
    extends ConsumerState<PaymentAccountLedgerScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final accountDao = ref.watch(accountDaoProvider);

    if (company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Ledger')),
        body: const Center(child: Text('No company selected')),
      );
    }

    // Determine account code based on account type
    String accountCode = _getAccountCode(widget.account.accountType);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.account.accountName} - Ledger'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<AccountTransaction>>(
        future: accountDao.getAccountTransactions(
          companyId: company.id,
          accountCode: accountCode,
          fromDate: _fromDate,
          toDate: _toDate,
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

          // Calculate current balance
          double currentBalance = 0;
          if (transactions.isNotEmpty) {
            currentBalance = transactions.first.runningBalance;
          }

          return Column(
            children: [
              _buildBalanceCard(currentBalance),
              if (_fromDate != null || _toDate != null) _buildFilterChip(),
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

  String _getAccountCode(PaymentAccountType type) {
    switch (type) {
      case PaymentAccountType.cash:
        return '1000'; // Cash account
      case PaymentAccountType.cheque:
        return '1050'; // Cheque account
      case PaymentAccountType.bank:
        return '1100'; // Bank account
    }
  }

  Widget _buildBalanceCard(double balance) {
    final isPositive = balance >= 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [Colors.green.shade600, Colors.green.shade700]
              : [Colors.red.shade600, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
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
              Row(
                children: [
                  Text(
                    widget.account.icon ?? '💰',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getAccountTypeLabel(widget.account.accountType),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (widget.account.accountType == PaymentAccountType.bank &&
                  widget.account.bankName != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.account.bankName!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip() {
    final dateFormat = DateFormat('dd MMM yyyy');
    String filterText = '';

    if (_fromDate != null && _toDate != null) {
      filterText =
          '${dateFormat.format(_fromDate!)} - ${dateFormat.format(_toDate!)}';
    } else if (_fromDate != null) {
      filterText = 'From ${dateFormat.format(_fromDate!)}';
    } else if (_toDate != null) {
      filterText = 'To ${dateFormat.format(_toDate!)}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Chip(
            label: Text(filterText),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _fromDate = null;
                _toDate = null;
              });
            },
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDebit ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isDebit ? '+' : '-'}₹${(isDebit ? txn.debit : txn.credit).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDebit
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateFormat.format(txn.transactionDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Balance: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '₹${txn.runningBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: txn.runningBalance >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            'No Transactions Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _fromDate != null || _toDate != null
                ? 'Try adjusting your filters'
                : 'Transactions will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
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
        return 'Payment Receipt';
      case TransactionType.purchaseInvoice:
        return 'Purchase Invoice';
      case TransactionType.purchaseReturn:
        return 'Purchase Return';
      case TransactionType.paymentOut:
        return 'Payment Out';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.journalEntry:
        return 'Journal Entry';
    }
  }

  String _getAccountTypeLabel(PaymentAccountType type) {
    switch (type) {
      case PaymentAccountType.cash:
        return 'Cash';
      case PaymentAccountType.cheque:
        return 'Cheque';
      case PaymentAccountType.bank:
        return 'Bank';
    }
  }

  Future<void> _showFilterDialog() async {
    DateTime? tempFromDate = _fromDate;
    DateTime? tempToDate = _toDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('From Date'),
                subtitle: Text(
                  tempFromDate == null
                      ? 'Not set'
                      : DateFormat('dd MMM yyyy').format(tempFromDate!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tempFromDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setDialogState(() {
                            tempFromDate = null;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempFromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() {
                            tempFromDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('To Date'),
                subtitle: Text(
                  tempToDate == null
                      ? 'Not set'
                      : DateFormat('dd MMM yyyy').format(tempToDate!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tempToDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setDialogState(() {
                            tempToDate = null;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempToDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() {
                            tempToDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  tempFromDate = null;
                  tempToDate = null;
                });
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _fromDate = tempFromDate;
                  _toDate = tempToDate;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
