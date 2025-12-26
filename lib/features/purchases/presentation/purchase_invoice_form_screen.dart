import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/purchase_dao.dart';
import '../../../core/database/dao/sales_dao.dart';
import '../../../data/models/account_models.dart' as account_models;
import '../../../data/models/company_model.dart';
import '../../../data/models/inventory_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/models/user_model.dart';
import '../../inventory/presentation/product_selection_screen.dart';
import '../../parties/presentation/party_selection_screen.dart';
import '../../payments/logic/payment_providers.dart';
import '../../sales/logic/sales_providers.dart';
import '../logic/purchase_providers.dart';

class PurchaseLineDraft {
  int? productId;
  String? productName;
  double qty;
  double rate;

  PurchaseLineDraft({
    this.productId,
    this.productName,
    this.qty = 1,
    this.rate = 0,
  });
}

class PaymentLineDraft {
  int? accountId;
  String? accountName;
  String? accountIcon;
  double amount;

  PaymentLineDraft({
    this.accountId,
    this.accountName,
    this.accountIcon,
    this.amount = 0,
  });
}

class PurchaseInvoiceFormScreen extends ConsumerStatefulWidget {
  final int? invoiceId;

  const PurchaseInvoiceFormScreen({super.key, this.invoiceId});

  @override
  ConsumerState<PurchaseInvoiceFormScreen> createState() {
    return _PurchaseInvoiceFormScreenState();
  }
}

class _PurchaseInvoiceFormScreenState
    extends ConsumerState<PurchaseInvoiceFormScreen> {
  Party? _selectedSupplier;
  DateTime _date = DateTime.now();
  final _refNoCtrl = TextEditingController();
  final List<PurchaseLineDraft> _lines = [];
  final List<PaymentLineDraft> _paymentLines = [];
  final String _discountType = 'Flat';
  final double _discountValue = 0;
  final double _vat = 0;
  final double _shippingCharge = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.invoiceId != null) {
      _loadInvoice();
    } else {
      _refNoCtrl.text = 'PUR-${DateTime.now().millisecondsSinceEpoch}';
      _addDefaultCashPayment().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  Future<void> _addDefaultCashPayment() async {
    final paymentDao = ref.read(paymentDaoProvider);
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      final accounts = await paymentDao.getPaymentAccounts(company.id);
      final cashAccount = accounts
          .where((a) => a.accountType == PaymentAccountType.cash)
          .firstOrNull;

      if (cashAccount != null && mounted) {
        setState(() {
          _paymentLines.add(PaymentLineDraft(
            accountId: cashAccount.id,
            accountName: cashAccount.accountName,
            accountIcon: cashAccount.icon,
            amount: 0,
          ));
        });
      }
    }
  }

  Future<void> _loadInvoice() async {
    try {
      final purchaseDao = ref.read(purchaseDaoProvider);
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;

      final invoice = await purchaseDao.getInvoiceById(widget.invoiceId!);
      if (invoice == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice not found')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final transaction =
          await purchaseDao.getTransactionForInvoice(widget.invoiceId!);
      if (transaction == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction not found')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final lines = await purchaseDao.getTransactionLines(transaction.id);
      final supplier = await isar.partys.get(invoice.partyId);

      setState(() {
        _selectedSupplier = supplier;
        _date = invoice.invoiceDate;
        _refNoCtrl.text = transaction.referenceNo;
        _lines.clear();

        for (final line in lines) {
          final productId = line.productId;
          final product =
              productId != null ? isar.products.getSync(productId) : null;
          _lines.add(PurchaseLineDraft(
            productId: line.productId,
            productName: product?.name ?? 'Unknown',
            qty: line.quantity,
            rate: line.unitPrice,
          ));
        }

        if (_lines.isEmpty) {
          _lines.add(PurchaseLineDraft());
        }

        _paymentLines.clear();
        _loadPaymentLines(invoice.companyId, invoice.id);

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoice: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadPaymentLines(int companyId, int invoiceId) async {
    try {
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;
      final paymentDao = ref.read(paymentDaoProvider);

      // Get all payment account transactions for this invoice
      final allAccountTransactions =
          await isar.accountTransactions.where().findAll();

      final payments = allAccountTransactions
          .where((p) =>
              p.companyId == companyId &&
              p.referenceId == invoiceId &&
              (p.transactionType ==
                      account_models.TransactionType.purchaseInvoice ||
                  p.transactionType ==
                      account_models.TransactionType.paymentOut))
          .toList();

      final paymentAccounts = await paymentDao.getPaymentAccounts(companyId);

      for (final payment in payments) {
        // Get the account to check if it's a cash/bank account (not AP)
        final account = await isar.accounts.get(payment.accountId);

        if (account != null &&
            (account.code == '1000' ||
                account.code == '1050' ||
                account.code == '1100')) {
          // This is a cash/bank payment, determine the account type
          PaymentAccountType accountType;
          if (account.code == '1000') {
            accountType = PaymentAccountType.cash;
          } else if (account.code == '1050') {
            accountType = PaymentAccountType.cheque;
          } else {
            accountType = PaymentAccountType.bank;
          }

          // Find a matching payment account or use first of same type
          final matchingAccounts = paymentAccounts
              .where((pa) => pa.accountType == accountType)
              .toList();

          if (matchingAccounts.isNotEmpty && mounted) {
            final paymentAccount = matchingAccounts.first;

            setState(() {
              _paymentLines.add(PaymentLineDraft(
                accountId: paymentAccount.id,
                accountName: paymentAccount.accountName,
                accountIcon: paymentAccount.icon,
                amount: payment.credit, // Credit represents cash paid
              ));
            });
          }
        }
      }

      // If no payment lines were loaded, add a default cash line
      if (mounted && _paymentLines.isEmpty) {
        final cashAccount = paymentAccounts
            .where((a) => a.accountType == PaymentAccountType.cash)
            .firstOrNull;

        if (cashAccount != null) {
          setState(() {
            _paymentLines.add(PaymentLineDraft(
              accountId: cashAccount.id,
              accountName: cashAccount.accountName,
              accountIcon: cashAccount.icon,
              amount: 0,
            ));
          });
        }
      }
    } catch (e) {
      // Silently fail - user can manually add payments
      print('Error loading payment lines: $e');
    }
  }

  @override
  void dispose() {
    _refNoCtrl.dispose();
    super.dispose();
  }

  double get _subTotal =>
      _lines.fold<double>(0, (sum, l) => sum + (l.qty * l.rate));

  double get _totalDiscount {
    if (_discountType == 'Flat') return _discountValue;
    return _subTotal * (_discountValue / 100);
  }

  double get _afterDiscount => _subTotal - _totalDiscount;

  double get _totalVAT => _afterDiscount * (_vat / 100);

  double get _grandTotal => _afterDiscount + _totalVAT + _shippingCharge;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final user = ref.watch(currentUserProvider);
    final productAsync = ref.watch(productListProvider);
    final purchaseDao = ref.read(purchaseDaoProvider);

    if (company == null) {
      return const Scaffold(
        body: Center(child: Text('No company selected')),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.invoiceId != null ? 'Edit Purchase' : 'Add Purchase'),
        elevation: 0,
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSupplierSelector(context),
              const SizedBox(height: 20),
              productAsync.when(
                data: (products) => Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _lines.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildLineItem(context, _lines[i], products, i),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                        ),
                        onPressed: () async {
                          final selected = await Navigator.push<Product>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductSelectionScreen(
                                title: 'Select Product',
                              ),
                            ),
                          );
                          if (selected != null) {
                            setState(() {
                              _lines.add(PurchaseLineDraft(
                                productId: selected.id,
                                productName: selected.name,
                                qty: 1,
                                rate: selected.lastCost > 0
                                    ? selected.lastCost
                                    : selected.salePrice,
                              ));
                            });
                          }
                        },
                        child: Text(
                          'Add Items',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Error loading products')),
              ),
              const SizedBox(height: 20),
              _buildCalculationCard(),
              const SizedBox(height: 20),
              _buildPaymentLinesSection(),
              const SizedBox(height: 20),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.note),
                ),
                onChanged: (v) {},
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _savePurchaseInvoice(purchaseDao, company, user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save Purchase',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePurchaseInvoice(
      PurchaseDao purchaseDao, Company company, User? user) async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a supplier'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final validLines = _lines
        .where((l) => l.productId != null && l.qty > 0 && l.rate > 0)
        .toList();

    if (validLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final inputs = validLines
        .map((l) => PurchaseLineInput(
              productId: l.productId!,
              qty: l.qty,
              rate: l.rate,
            ))
        .toList();

    final validPaymentLines = _paymentLines
        .where((p) => p.accountId != null && p.amount > 0)
        .toList();

    final paymentInputs = validPaymentLines.isNotEmpty
        ? validPaymentLines
            .map((p) => PaymentLineInput(
                  paymentAccountId: p.accountId!,
                  amount: p.amount,
                ))
            .toList()
        : null;

    if (widget.invoiceId != null) {
      await purchaseDao.updatePurchaseInvoice(
        invoiceId: widget.invoiceId!,
        companyId: company.id,
        supplier: _selectedSupplier!,
        date: _date,
        referenceNo: _refNoCtrl.text.trim(),
        lines: inputs,
        paymentLines: paymentInputs,
        userId: user?.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      await purchaseDao.createPurchaseInvoice(
        companyId: company.id,
        supplier: _selectedSupplier!,
        date: _date,
        referenceNo: _refNoCtrl.text.trim(),
        lines: inputs,
        paymentLines: paymentInputs,
        userId: user?.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Widget _buildSupplierSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await Navigator.push<Party>(
          context,
          MaterialPageRoute(
            builder: (_) => const PartySelectionScreen(
              showSuppliers: true,
              showCustomers: false,
              title: 'Select Supplier',
            ),
          ),
        );
        if (selected != null) {
          setState(() => _selectedSupplier = selected);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _selectedSupplier?.name.isNotEmpty == true
                      ? _selectedSupplier!.name[0].toUpperCase()
                      : 'S',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedSupplier?.name ?? 'Select Supplier',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedSupplier != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Balance: \$${_selectedSupplier!.openingBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(
    BuildContext context,
    PurchaseLineDraft line,
    List<Product> products,
    int index,
  ) {
    final amount = (line.qty * line.rate).toStringAsFixed(0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
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
                      line.productName ?? 'Select product',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${line.qty.toStringAsFixed(0)} X ${line.rate.toStringAsFixed(0)} = $amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      color: Colors.orange.shade700,
                      onPressed: () {
                        setState(() {
                          if (line.qty > 1) line.qty--;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    line.qty.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      color: Colors.orange.shade700,
                      onPressed: () {
                        setState(() => line.qty++);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      color: Colors.red.shade700,
                      onPressed: () {
                        setState(() => _lines.removeAt(index));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Cost',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) {
              setState(() {
                line.rate = double.tryParse(v) ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalcRow('Sub Total', _subTotal),
          const Divider(),
          _buildCalcRow('Total', _grandTotal, isBold: true),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentLinesSection() {
    final paymentAccountsAsync = ref.watch(paymentAccountsProvider);

    return paymentAccountsAsync.when(
      data: (accounts) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Payment Methods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => _showPaymentTypeDialog(accounts),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_paymentLines.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No payment methods added',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ...List.generate(_paymentLines.length, (index) {
                return _buildPaymentLine(_paymentLines[index], accounts, index);
              }),
          ],
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading payment accounts'),
    );
  }

  Widget _buildPaymentLine(
    PaymentLineDraft line,
    List<PaymentAccount> accounts,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Text(
            line.accountIcon ?? '💰',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              line.accountName ?? 'Unknown',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() => _paymentLines.removeAt(index));
            },
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: TextField(
              key: ValueKey('payment_amount_${index}_${line.accountId}'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: 'Rs ',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (value) {
                try {
                  line.amount = double.tryParse(value) ?? 0;
                  setState(() {});
                } catch (e) {
                  print('Error updating payment amount: $e');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentTypeDialog(List<PaymentAccount> accounts) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Payment Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...accounts.map((account) {
                return ListTile(
                  leading: Text(
                    account.icon ?? '💰',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(account.accountName),
                  onTap: () {
                    setState(() {
                      _paymentLines.add(PaymentLineDraft(
                        accountId: account.id,
                        accountName: account.accountName,
                        accountIcon: account.icon,
                        amount: 0,
                      ));
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
