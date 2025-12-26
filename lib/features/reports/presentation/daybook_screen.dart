import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/account_models.dart' as account_models;
import '../../../data/models/invoice_stock_models.dart';

class DaybookScreen extends ConsumerStatefulWidget {
  const DaybookScreen({super.key});

  @override
  ConsumerState<DaybookScreen> createState() => _DaybookScreenState();
}

class _DaybookScreenState extends ConsumerState<DaybookScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final currentCompany = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daybook'),
        backgroundColor: Colors.indigo.shade700,
      ),
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'daybook',
      ),
      body: Column(
        children: [
          // Date selector
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.indigo.shade50,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20, color: Colors.indigo.shade700),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_drop_down,
                              color: Colors.indigo.shade700),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                  tooltip: 'Previous Day',
                ),
                IconButton(
                  icon: const Icon(Icons.today),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                    });
                  },
                  tooltip: 'Today',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
                  tooltip: 'Next Day',
                ),
              ],
            ),
          ),

          // Daybook content
          Expanded(
            child: _buildDaybook(currentCompany?.id),
          ),
        ],
      ),
    );
  }

  Widget _buildDaybook(int? companyId) {
    if (companyId == null) {
      return const Center(child: Text('Please select a company'));
    }

    final isar = ref.read(isarServiceProvider).isar;

    return FutureBuilder<_DaybookData>(
      future: _loadDaybookData(isar, companyId, _selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('No data available'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Summary cards
              _buildSummarySection(data),

              // All transactions
              _buildTransactionsList(data),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(_DaybookData data) {
    final netCash = data.cashReceived - data.cashPaid;
    final otherCashReceipts = data.cashReceived - data.cashFromSales;
    final otherCashPayments = data.cashPaid - data.cashFromPurchases;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Summary cards row 1
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Sales',
                  'Rs. ${data.totalSales.toStringAsFixed(2)}',
                  Colors.green,
                  Icons.shopping_cart,
                  subtitle: data.cashFromSales > 0
                      ? 'Cash: Rs. ${data.cashFromSales.toStringAsFixed(2)}'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Purchases',
                  'Rs. ${data.totalPurchases.toStringAsFixed(2)}',
                  Colors.orange,
                  Icons.shopping_bag,
                  subtitle: data.cashFromPurchases > 0
                      ? 'Cash: Rs. ${data.cashFromPurchases.toStringAsFixed(2)}'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary cards row 2
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Cash Received',
                  'Rs. ${data.cashReceived.toStringAsFixed(2)}',
                  Colors.blue,
                  Icons.arrow_downward,
                  subtitle: otherCashReceipts > 0
                      ? 'Other: Rs. ${otherCashReceipts.toStringAsFixed(2)}'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Cash Paid',
                  'Rs. ${data.cashPaid.toStringAsFixed(2)}',
                  Colors.red,
                  Icons.arrow_upward,
                  subtitle: otherCashPayments > 0
                      ? 'Other: Rs. ${otherCashPayments.toStringAsFixed(2)}'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Net cash card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: netCash >= 0
                    ? [Colors.green.shade400, Colors.green.shade700]
                    : [Colors.red.shade400, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (netCash >= 0 ? Colors.green : Colors.red)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        netCash >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Net Cash Flow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs. ${netCash.abs().toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (netCash < 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'DEFICIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, Color color, IconData icon,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsList(_DaybookData data) {
    if (data.transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No transactions for this day',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transactions (${data.transactions.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...data.transactions.map((txn) => _buildTransactionCard(txn)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(_DaybookTransaction txn) {
    Color color;
    IconData icon;
    String typeLabel;

    switch (txn.type) {
      case 'Sale':
        color = Colors.green;
        icon = Icons.shopping_cart;
        typeLabel = 'SALE';
        break;
      case 'Purchase':
        color = Colors.orange;
        icon = Icons.shopping_bag;
        typeLabel = 'PURCHASE';
        break;
      case 'Cash Receipt':
        color = Colors.blue;
        icon = Icons.arrow_downward;
        typeLabel = 'CASH IN';
        break;
      case 'Cash Payment':
        color = Colors.red;
        icon = Icons.arrow_upward;
        typeLabel = 'CASH OUT';
        break;
      default:
        color = Colors.grey;
        icon = Icons.receipt;
        typeLabel = txn.type.toUpperCase();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              typeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            txn.referenceNo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        txn.partyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (txn.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          txn.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${txn.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      _formatTime(txn.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (txn.cashAmount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payments, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Cash: Rs. ${txn.cashAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (txn.accountName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${txn.accountName})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<_DaybookData> _loadDaybookData(
      Isar isar, int companyId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final transactions = <_DaybookTransaction>[];
    double totalSales = 0;
    double totalPurchases = 0;
    double cashReceived = 0;
    double cashPaid = 0;
    double cashFromSales = 0;
    double cashFromPurchases = 0;

    // Get all sales for the day
    final sales = await isar
        .collection<Transaction>()
        .filter()
        .companyIdEqualTo(companyId)
        .typeEqualTo(TransactionType.sale)
        .dateBetween(startOfDay, endOfDay)
        .sortByDate()
        .findAll();

    for (final sale in sales) {
      final party = sale.partyId != null && sale.partyId != 0
          ? await isar.collection<Party>().get(sale.partyId!)
          : null;

      totalSales += sale.totalAmount;

      // Get the invoice for this sale transaction
      final invoice = await isar
          .collection<Invoice>()
          .filter()
          .transactionIdEqualTo(sale.id)
          .findFirst();

      double cashAmount = 0;
      String accountName = '';

      if (invoice != null) {
        // Get payment info from account transactions using invoice ID
        // Sale invoice payments are recorded with TransactionType.saleInvoice
        final payments = await isar
            .collection<account_models.AccountTransaction>()
            .filter()
            .companyIdEqualTo(companyId)
            .referenceIdEqualTo(invoice.id)
            .transactionTypeEqualTo(account_models.TransactionType.saleInvoice)
            .findAll();

        for (final payment in payments) {
          // Only count cash/bank accounts (not AR)
          final account = await isar
              .collection<account_models.Account>()
              .get(payment.accountId);
          if (account != null &&
              (account.code == '1000' ||
                  account.code == '1050' ||
                  account.code == '1100')) {
            cashReceived += payment.debit;
            cashFromSales += payment.debit;
            cashAmount += payment.debit;
            if (accountName.isEmpty) {
              accountName = account.name;
            }
          }
        }
      }

      transactions.add(_DaybookTransaction(
        type: 'Sale',
        referenceNo: sale.referenceNo,
        partyName: party?.name ?? 'Walk-in Customer',
        amount: sale.totalAmount,
        cashAmount: cashAmount,
        date: sale.date,
        description: '',
        accountName: accountName,
      ));
    }

    // Get all purchases for the day
    final purchases = await isar
        .collection<Transaction>()
        .filter()
        .companyIdEqualTo(companyId)
        .typeEqualTo(TransactionType.purchase)
        .dateBetween(startOfDay, endOfDay)
        .sortByDate()
        .findAll();

    for (final purchase in purchases) {
      final party = purchase.partyId != null && purchase.partyId != 0
          ? await isar.collection<Party>().get(purchase.partyId!)
          : null;

      totalPurchases += purchase.totalAmount;

      // Get the invoice for this purchase transaction
      final invoice = await isar
          .collection<Invoice>()
          .filter()
          .transactionIdEqualTo(purchase.id)
          .findFirst();

      double cashAmount = 0;
      String accountName = '';

      if (invoice != null) {
        // Get payment info from account transactions using invoice ID
        // Purchase invoice payments are recorded with TransactionType.purchaseInvoice
        final payments = await isar
            .collection<account_models.AccountTransaction>()
            .filter()
            .companyIdEqualTo(companyId)
            .referenceIdEqualTo(invoice.id)
            .transactionTypeEqualTo(
                account_models.TransactionType.purchaseInvoice)
            .findAll();

        for (final payment in payments) {
          // Only count cash/bank accounts (not AP)
          final account = await isar
              .collection<account_models.Account>()
              .get(payment.accountId);
          if (account != null &&
              (account.code == '1000' ||
                  account.code == '1050' ||
                  account.code == '1100')) {
            cashPaid += payment.credit;
            cashFromPurchases += payment.credit;
            cashAmount += payment.credit;
            if (accountName.isEmpty) {
              accountName = account.name;
            }
          }
        }
      }

      transactions.add(_DaybookTransaction(
        type: 'Purchase',
        referenceNo: purchase.referenceNo,
        partyName: party?.name ?? 'Unknown Supplier',
        amount: purchase.totalAmount,
        cashAmount: cashAmount,
        date: purchase.date,
        description: '',
        accountName: accountName,
      ));
    }

    // Get other cash receipts (Payment In)
    final paymentIns = await isar
        .collection<account_models.AccountTransaction>()
        .filter()
        .companyIdEqualTo(companyId)
        .transactionTypeEqualTo(account_models.TransactionType.paymentIn)
        .transactionDateBetween(startOfDay, endOfDay)
        .sortByTransactionDate()
        .findAll();

    final processedPaymentInRefs = <int>{};
    for (final payment in paymentIns) {
      // Skip if already processed as part of sale
      if (processedPaymentInRefs.contains(payment.referenceId)) {
        continue;
      }

      // Only add if it's not part of a sale invoice
      final relatedSale = await isar
          .collection<Transaction>()
          .filter()
          .idEqualTo(payment.referenceId)
          .typeEqualTo(TransactionType.sale)
          .findFirst();

      if (relatedSale == null && payment.debit > 0) {
        final party = payment.partyId != null && payment.partyId != 0
            ? await isar.collection<Party>().get(payment.partyId!)
            : null;

        final account = await isar
            .collection<account_models.Account>()
            .get(payment.accountId);

        cashReceived += payment.debit;

        transactions.add(_DaybookTransaction(
          type: 'Cash Receipt',
          referenceNo: payment.referenceNo ?? 'N/A',
          partyName: party?.name ?? 'Cash Receipt',
          amount: payment.debit,
          cashAmount: payment.debit,
          date: payment.transactionDate,
          description: payment.description ?? '',
          accountName: account?.name ?? '',
        ));

        processedPaymentInRefs.add(payment.referenceId);
      }
    }

    // Get other cash payments (Payment Out)
    final paymentOuts = await isar
        .collection<account_models.AccountTransaction>()
        .filter()
        .companyIdEqualTo(companyId)
        .transactionTypeEqualTo(account_models.TransactionType.paymentOut)
        .transactionDateBetween(startOfDay, endOfDay)
        .sortByTransactionDate()
        .findAll();

    final processedPaymentOutRefs = <int>{};
    for (final payment in paymentOuts) {
      // Skip if already processed as part of purchase
      if (processedPaymentOutRefs.contains(payment.referenceId)) {
        continue;
      }

      // Only add if it's not part of a purchase invoice
      final relatedPurchase = await isar
          .collection<Transaction>()
          .filter()
          .idEqualTo(payment.referenceId)
          .typeEqualTo(TransactionType.purchase)
          .findFirst();

      if (relatedPurchase == null && payment.credit > 0) {
        final party = payment.partyId != null && payment.partyId != 0
            ? await isar.collection<Party>().get(payment.partyId!)
            : null;

        final account = await isar
            .collection<account_models.Account>()
            .get(payment.accountId);

        cashPaid += payment.credit;

        transactions.add(_DaybookTransaction(
          type: 'Cash Payment',
          referenceNo: payment.referenceNo ?? 'N/A',
          partyName: party?.name ?? 'Cash Payment',
          amount: payment.credit,
          cashAmount: payment.credit,
          date: payment.transactionDate,
          description: payment.description ?? '',
          accountName: account?.name ?? '',
        ));

        processedPaymentOutRefs.add(payment.referenceId);
      }
    }

    // Sort all transactions by time
    transactions.sort((a, b) => a.date.compareTo(b.date));

    return _DaybookData(
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      cashReceived: cashReceived,
      cashPaid: cashPaid,
      cashFromSales: cashFromSales,
      cashFromPurchases: cashFromPurchases,
      transactions: transactions,
    );
  }
}

class _DaybookData {
  final double totalSales;
  final double totalPurchases;
  final double cashReceived;
  final double cashPaid;
  final double cashFromSales;
  final double cashFromPurchases;
  final List<_DaybookTransaction> transactions;

  _DaybookData({
    required this.totalSales,
    required this.totalPurchases,
    required this.cashReceived,
    required this.cashPaid,
    required this.cashFromSales,
    required this.cashFromPurchases,
    required this.transactions,
  });
}

class _DaybookTransaction {
  final String type;
  final String referenceNo;
  final String partyName;
  final double amount;
  final double cashAmount;
  final DateTime date;
  final String description;
  final String accountName;

  _DaybookTransaction({
    required this.type,
    required this.referenceNo,
    required this.partyName,
    required this.amount,
    required this.cashAmount,
    required this.date,
    required this.description,
    required this.accountName,
  });
}
