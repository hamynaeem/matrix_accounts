// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/account_models.dart';
import '../../../data/models/party_model.dart';

class PartyLedgerScreen extends ConsumerStatefulWidget {
  final Party party;

  const PartyLedgerScreen({super.key, required this.party});

  @override
  ConsumerState<PartyLedgerScreen> createState() => _PartyLedgerScreenState();
}

class _PartyLedgerScreenState extends ConsumerState<PartyLedgerScreen> {
  String _selectedFilter = 'All Time';
  DateTime? _startDate;
  DateTime? _endDate;
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _setDateRange('All Time');
  }

  void _setDateRange(String filter) {
    final now = DateTime.now();

    switch (filter) {
      case 'Today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        _startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Monthly':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'Day to Day':
        _showDateRangePicker();
        return;
      default:
        _startDate = null;
        _endDate = null;
    }

    setState(() {
      _selectedFilter = filter;
    });
  }

  void _showDateRangePicker() async {
    final now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange:
          _startDate != null && _endDate != null && !_endDate!.isAfter(now)
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = DateTime(
            picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
        _selectedFilter = 'Day to Day';
      });
    }
  }

  List<AccountTransaction> _filterTransactions(
      List<AccountTransaction> transactions) {
    if (_startDate == null || _endDate == null) {
      return transactions;
    }

    return transactions.where((txn) {
      return txn.transactionDate
              .isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          txn.transactionDate.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _exportToPDF(List<AccountTransaction> transactions) async {
    try {
      _showSnackBar('Generating PDF...');

      final company = ref.read(currentCompanyProvider);
      final pdf = pw.Document();

      // Calculate balance
      double totalBalance =
          transactions.isNotEmpty ? transactions.first.runningBalance : 0;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  'PARTY LEDGER',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Company: ${company?.name ?? 'Company'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Party: ${widget.party.name}',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                if (_selectedFilter != 'All Time') ...[
                  pw.Text(
                    'Period: $_selectedFilter${_startDate != null ? ' (${_dateFormat.format(_startDate!)} - ${_dateFormat.format(_endDate!)})' : ''}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
                pw.Text(
                  'Current Balance: ₹${totalBalance.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),

                // Transactions Table
                if (transactions.isNotEmpty) ...[
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Description',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Date',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Debit',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.right),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Credit',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.right),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Balance',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.right),
                          ),
                        ],
                      ),
                      // Data rows
                      ...transactions.map((txn) {
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(txn.description ?? ''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  _dateFormat.format(txn.transactionDate)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  txn.debit > 0
                                      ? txn.debit.toStringAsFixed(2)
                                      : '',
                                  textAlign: pw.TextAlign.right),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  txn.credit > 0
                                      ? txn.credit.toStringAsFixed(2)
                                      : '',
                                  textAlign: pw.TextAlign.right),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  txn.runningBalance.toStringAsFixed(2),
                                  textAlign: pw.TextAlign.right),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ] else ...[
                  pw.Text('No transactions found for the selected period.'),
                ],
              ],
            );
          },
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/ledger_${widget.party.name.replaceAll(' ', '_')}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)],
          subject: '${widget.party.name} - Ledger Report');
      _showSnackBar('Ledger exported successfully');
    } catch (e) {
      _showSnackBar('Error exporting ledger: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('${widget.party.name} - Ledger'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _setDateRange,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All Time', child: Text('All Time')),
              const PopupMenuItem(value: 'Today', child: Text('Today')),
              const PopupMenuItem(value: 'Weekly', child: Text('This Week')),
              const PopupMenuItem(value: 'Monthly', child: Text('This Month')),
              const PopupMenuItem(
                  value: 'Day to Day', child: Text('Custom Range')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<AccountTransaction>>(
        future: accountDao.getCustomerLedger(
          companyId: company.id,
          customerId: widget.party.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allTransactions = snapshot.data ?? [];
          final filteredTransactions = _filterTransactions(allTransactions);

          if (allTransactions.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate total balance from original transactions
          double totalBalance = 0;
          for (var txn in allTransactions) {
            totalBalance = txn.runningBalance;
            break; // First transaction has current balance
          }

          return Column(
            children: [
              _buildFilterHeader(),
              _buildBalanceCard(totalBalance),
              if (filteredTransactions.isEmpty && _selectedFilter != 'All Time')
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found for $_selectedFilter',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final txn = filteredTransactions[index];
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

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Filter: $_selectedFilter${_selectedFilter == 'Day to Day' && _startDate != null ? ' (${_dateFormat.format(_startDate!)} - ${_dateFormat.format(_endDate!)})' : ''}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final accountDao = ref.read(accountDaoProvider);
              final company = ref.read(currentCompanyProvider);
              if (company != null) {
                final transactions = await accountDao.getCustomerLedger(
                  companyId: company.id,
                  customerId: widget.party.id,
                );
                final filteredTransactions = _filterTransactions(transactions);
                await _exportToPDF(filteredTransactions);
              }
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
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
