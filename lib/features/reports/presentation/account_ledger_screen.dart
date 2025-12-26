import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/account_models.dart';

class AccountLedgerScreen extends ConsumerStatefulWidget {
  const AccountLedgerScreen({super.key});

  @override
  ConsumerState<AccountLedgerScreen> createState() =>
      _AccountLedgerScreenState();
}

class _AccountLedgerScreenState extends ConsumerState<AccountLedgerScreen> {
  Account? _selectedAccount;
  DateTime? _fromDate;
  DateTime? _toDate;
  final dateFormat = DateFormat('dd MMM yyyy');

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Ledger'),
        elevation: 0,
        actions: [
          if (_selectedAccount != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export to PDF',
              onPressed: () => _exportToPDF(company.id),
            ),
        ],
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'account-ledger',
      ),
      body: Column(
        children: [
          _buildAccountSelector(company.id),
          if (_selectedAccount != null) ...[
            _buildFilterSection(),
            Expanded(
              child: _buildLedgerContent(company.id, accountDao),
            ),
          ] else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Select an account to view ledger',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountSelector(int companyId) {
    final accountDao = ref.watch(accountDaoProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<List<Account>>(
        future: accountDao.getAccounts(companyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = snapshot.data!;
          accounts.sort((a, b) => a.code.compareTo(b.code));

          return DropdownButtonFormField<Account>(
            decoration: InputDecoration(
              labelText: 'Select Account',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.account_balance),
            ),
            initialValue: _selectedAccount,
            isExpanded: true,
            items: accounts.map((account) {
              return DropdownMenuItem<Account>(
                value: account,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getAccountTypeColor(account.accountType),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        account.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        account.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '₹${account.currentBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: account.currentBalance >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (account) {
              setState(() {
                _selectedAccount = account;
                _fromDate = null;
                _toDate = null;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context, isFromDate: true),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _fromDate != null
                            ? 'From: ${dateFormat.format(_fromDate!)}'
                            : 'From Date',
                        style: TextStyle(
                          fontSize: 13,
                          color: _fromDate != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    if (_fromDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _fromDate = null),
                        child: Icon(Icons.clear,
                            size: 16, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context, isFromDate: false),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _toDate != null
                            ? 'To: ${dateFormat.format(_toDate!)}'
                            : 'To Date',
                        style: TextStyle(
                          fontSize: 13,
                          color: _toDate != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    if (_toDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _toDate = null),
                        child: Icon(Icons.clear,
                            size: 16, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerContent(int companyId, accountDao) {
    return FutureBuilder<List<AccountTransaction>>(
      future: accountDao.getAccountTransactions(
        companyId: companyId,
        accountCode: _selectedAccount!.code,
        fromDate: _fromDate,
        toDate: _toDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error loading transactions',
                  style: TextStyle(fontSize: 16, color: Colors.red.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        // Calculate current balance
        double currentBalance = transactions.isNotEmpty
            ? transactions.first.runningBalance
            : _selectedAccount!.currentBalance;

        return Column(
          children: [
            _buildBalanceCard(currentBalance),
            _buildLedgerHeader(),
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
    );
  }

  Widget _buildBalanceCard(double balance) {
    final accountType = _selectedAccount!.accountType;

    // Determine if this is a normal balance for this account type
    bool isNormalBalance = false;
    switch (accountType) {
      case AccountType.asset:
      case AccountType.expense:
        isNormalBalance = balance >= 0; // Normal: Debit (positive)
        break;
      case AccountType.liability:
      case AccountType.equity:
      case AccountType.revenue:
        isNormalBalance =
            balance >= 0; // Normal: Credit (positive in our system)
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNormalBalance
              ? [Colors.green.shade600, Colors.green.shade700]
              : [Colors.orange.shade600, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isNormalBalance ? Colors.green : Colors.orange)
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedAccount!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedAccount!.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${balance.abs().toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getBalanceDescription(accountType, balance),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Debit',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              'Credit',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 2,
            child: Text(
              'Balance',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(AccountTransaction txn) {
    final isDebit = txn.debit > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(txn.transactionDate),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (txn.referenceNo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          txn.referenceNo!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.description ?? '-',
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTransactionTypeColor(txn.transactionType),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getTransactionTypeLabel(txn.transactionType),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    isDebit ? '₹${txn.debit.toStringAsFixed(2)}' : '-',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDebit
                          ? Colors.green.shade700
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    !isDebit ? '₹${txn.credit.toStringAsFixed(2)}' : '-',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          !isDebit ? Colors.red.shade700 : Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${txn.runningBalance.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: txn.runningBalance >= 0
                          ? Colors.blue.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
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
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _fromDate != null || _toDate != null
                ? 'Try adjusting the date filter'
                : 'No transactions recorded yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isFromDate}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isFromDate ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = date;
        } else {
          _toDate = date;
        }
      });
    }
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return Colors.green.shade700;
      case AccountType.liability:
        return Colors.red.shade700;
      case AccountType.equity:
        return Colors.blue.shade700;
      case AccountType.revenue:
        return Colors.purple.shade700;
      case AccountType.expense:
        return Colors.orange.shade700;
    }
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.saleInvoice:
        return Colors.green.shade600;
      case TransactionType.purchaseInvoice:
        return Colors.blue.shade600;
      case TransactionType.paymentIn:
        return Colors.teal.shade600;
      case TransactionType.paymentOut:
        return Colors.orange.shade600;
      case TransactionType.journalEntry:
        return Colors.purple.shade600;
      case TransactionType.saleReturn:
        return Colors.red.shade700;
      case TransactionType.purchaseReturn:
        return Colors.indigo.shade700;
      case TransactionType.expense:
        return Colors.deepOrange.shade600;
    }
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.saleInvoice:
        return 'SALE';
      case TransactionType.purchaseInvoice:
        return 'PURCHASE';
      case TransactionType.paymentIn:
        return 'RECEIPT';
      case TransactionType.paymentOut:
        return 'PAYMENT';
      case TransactionType.journalEntry:
        return 'JOURNAL';
      case TransactionType.saleReturn:
        return 'SALE RTN';
      case TransactionType.purchaseReturn:
        return 'PURCH RTN';
      case TransactionType.expense:
        return 'EXPENSE';
    }
  }

  String _getBalanceDescription(AccountType type, double balance) {
    switch (type) {
      case AccountType.asset:
        return balance >= 0
            ? 'Asset Balance (Debit)'
            : 'Credit Balance (Unusual)';
      case AccountType.liability:
        return balance >= 0
            ? 'Liability Balance (Credit)'
            : 'Debit Balance (Unusual)';
      case AccountType.equity:
        return balance >= 0
            ? 'Equity Balance (Credit)'
            : 'Debit Balance (Unusual)';
      case AccountType.revenue:
        return balance >= 0
            ? 'Revenue Balance (Credit)'
            : 'Debit Balance (Unusual)';
      case AccountType.expense:
        return balance >= 0
            ? 'Expense Balance (Debit)'
            : 'Credit Balance (Unusual)';
    }
  }

  Future<void> _exportToPDF(int companyId) async {
    if (_selectedAccount == null) return;

    final accountDao = ref.read(accountDaoProvider);
    final company = ref.read(currentCompanyProvider);

    // Get transactions
    final transactions = await accountDao.getAccountTransactions(
      companyId: companyId,
      accountCode: _selectedAccount!.code,
      fromDate: _fromDate,
      toDate: _toDate,
    );

    // Create PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Header
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  company?.name ?? 'Company',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Account Ledger Report',
                  style: const pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Account: ${_selectedAccount!.code} - ${_selectedAccount!.name}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Type: ${_selectedAccount!.accountType.name.toUpperCase()}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        if (_fromDate != null || _toDate != null) ...[
                          pw.Text(
                            'Period:',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            '${_fromDate != null ? dateFormat.format(_fromDate!) : "Start"} to ${_toDate != null ? dateFormat.format(_toDate!) : "End"}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
              ],
            ),

            // Transactions table
            if (transactions.isNotEmpty)
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _pdfCell('Date', bold: true),
                      _pdfCell('Description', bold: true),
                      _pdfCell('Ref No.', bold: true),
                      _pdfCell('Debit', bold: true, align: pw.TextAlign.right),
                      _pdfCell('Credit', bold: true, align: pw.TextAlign.right),
                      _pdfCell('Balance',
                          bold: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Data rows
                  ...transactions.map((txn) {
                    return pw.TableRow(
                      children: [
                        _pdfCell(dateFormat.format(txn.transactionDate)),
                        _pdfCell(txn.description ?? '-'),
                        _pdfCell(txn.referenceNo ?? '-'),
                        _pdfCell(
                          txn.debit > 0
                              ? '₹${txn.debit.toStringAsFixed(2)}'
                              : '-',
                          align: pw.TextAlign.right,
                        ),
                        _pdfCell(
                          txn.credit > 0
                              ? '₹${txn.credit.toStringAsFixed(2)}'
                              : '-',
                          align: pw.TextAlign.right,
                        ),
                        _pdfCell(
                          '₹${txn.runningBalance.toStringAsFixed(2)}',
                          align: pw.TextAlign.right,
                          bold: true,
                        ),
                      ],
                    );
                  }).toList(),
                  // Summary row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      border: pw.Border.all(color: PdfColors.grey800),
                    ),
                    children: [
                      _pdfCell('TOTAL', bold: true),
                      _pdfCell(''),
                      _pdfCell(''),
                      _pdfCell(
                        '₹${transactions.fold(0.0, (sum, txn) => sum + txn.debit).toStringAsFixed(2)}',
                        align: pw.TextAlign.right,
                        bold: true,
                      ),
                      _pdfCell(
                        '₹${transactions.fold(0.0, (sum, txn) => sum + txn.credit).toStringAsFixed(2)}',
                        align: pw.TextAlign.right,
                        bold: true,
                      ),
                      _pdfCell(
                        transactions.isNotEmpty
                            ? '₹${transactions.first.runningBalance.toStringAsFixed(2)}'
                            : '₹0.00',
                        align: pw.TextAlign.right,
                        bold: true,
                      ),
                    ],
                  ),
                ],
              )
            else
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Text(
                    'No transactions found',
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ),
          ];
        },
      ),
    );

    // Show PDF preview
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name:
          'Account_Ledger_${_selectedAccount!.code}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _pdfCell(
    String text, {
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }
}
