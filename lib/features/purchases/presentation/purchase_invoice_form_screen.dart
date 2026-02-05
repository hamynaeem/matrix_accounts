// ignore_for_file: avoid_print, avoid_unnecessary_containers, use_build_context_synchronously, unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:matrix_accounts/data/models/invoice_stock_models.dart';
import 'package:matrix_accounts/data/models/transaction_model.dart'
    show GetTransactionCollection;
import 'package:matrix_accounts/features/parties/logic/party_provider.dart'
    show partyListProvider;

import '../../../core/config/providers.dart';
import '../../../core/database/dao/party_dao.dart';
import '../../../core/database/dao/purchase_dao.dart';
import '../../../core/database/dao/sales_dao.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../data/models/account_models.dart' as account_models;
import '../../../data/models/company_model.dart';
import '../../../data/models/inventory_models.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/models/user_model.dart';
import '../../parties/presentation/party_form_screen.dart';
import '../../payments/logic/payment_providers.dart';
import '../../sales/logic/sales_providers.dart';
import '../logic/purchase_providers.dart';
import '../services/purchase_invoice_generator.dart';

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
  final _supplierSearchCtrl = TextEditingController();
  final _supplierSearchFocus = FocusNode();
  final _itemSearchCtrl = TextEditingController();
  final _cashAmountCtrl = TextEditingController();
  final _itemSearchFocus = FocusNode();
  final List<PurchaseLineDraft> _lines = [];
  final List<PaymentLineDraft> _paymentLines = [];
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _rateControllers = {};
  final String _discountType = 'Flat';
  final double _discountValue = 0;
  final double _vat = 0;
  final double _shippingCharge = 0;
  double _paidAmount = 0;
  double _previousBalance = 0;
  double _totalPayableAmount = 0;
  double _remainingBalance = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showAllItems = false;

  @override
  void initState() {
    super.initState();
    _supplierSearchFocus.addListener(() {
      setState(() {});
    });
    _itemSearchFocus.addListener(() {
      setState(() {
        _showAllItems = _itemSearchFocus.hasFocus;
        // Force rebuild when focus changes
      });
    });
    if (widget.invoiceId != null) {
      _loadInvoice();
    } else {
      _refNoCtrl.text = 'PUR-${DateTime.now().millisecondsSinceEpoch}';
      _addDefaultCashPayment().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
          _calculateTotalPayable(); // Initialize calculations
        }
      });
    }
  }

  /// Get current supplier balance from accounting ledger
  Future<double> _getSupplierBalance(int supplierId) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return 0.0;

    final isarService = ref.read(isarServiceProvider);
    final partyDao = PartyDao(isarService.isar);

    try {
      return await partyDao.getPartyBalance(
        partyId: supplierId,
        companyId: company.id,
      );
    } catch (e) {
      print('Error getting supplier balance: $e');
      return 0.0;
    }
  }

  /// Get previous unpaid balance for a supplier including opening balance
  Future<double> _getPreviousUnpaidBalance(int supplierId) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return 0.0;

    final isarService = ref.read(isarServiceProvider);
    final isar = isarService.isar;

    try {
      // Get supplier to access opening balance
      final supplier = await isar.partys.get(supplierId);
      double balance = supplier?.openingBalance ?? 0.0;

      // Get all account transactions for this supplier
      final allAccountTransactions =
          await isar.accountTransactions.where().findAll();
      final supplierTransactions = allAccountTransactions
          .where((t) =>
              t.companyId == company.id &&
              t.partyId == supplierId &&
              (t.transactionType ==
                      account_models.TransactionType.purchaseInvoice ||
                  t.transactionType ==
                      account_models.TransactionType.paymentOut ||
                  t.transactionType ==
                      account_models.TransactionType.paymentIn))
          .toList();

      // Calculate balance: credit (amount owed to supplier) - debit (amount paid to supplier)
      for (final transaction in supplierTransactions) {
        balance += transaction.credit - transaction.debit;
      }

      return balance > 0 ? balance : 0.0; // Only return positive unpaid balance
    } catch (e) {
      print('Error getting previous unpaid balance: $e');
      return 0.0;
    }
  }

  /// Calculate total payable amount (previous balance + new purchase amount)
  void _calculateTotalPayable() {
    final newPurchaseAmount =
        _subTotal; // Use subtotal instead of grandTotal to avoid circular calls
    _totalPayableAmount = _previousBalance + newPurchaseAmount;
    _remainingBalance = _totalPayableAmount - _paidAmount;
    if (mounted) {
      setState(() {});
    }
  }

  /// Update supplier selection and fetch previous balance
  Future<void> _onSupplierSelected(Party supplier) async {
    setState(() {
      _selectedSupplier = supplier;
      _supplierSearchCtrl.text = supplier.name;
    });

    // Fetch previous unpaid balance
    final previousBalance = await _getPreviousUnpaidBalance(supplier.id);
    setState(() {
      _previousBalance = previousBalance;
    });

    _calculateTotalPayable();
    _supplierSearchFocus.unfocus();
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

        // Always ensure at least one line exists
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

      double totalPaidAmount = 0;

      for (final payment in payments) {
        // Get the account to check if it's a cash/bank account (not AP)
        final account = await isar.accounts.get(payment.accountId);

        if (account != null &&
            (account.code == '1000' || account.code == '1100')) {
          // This is a cash/bank payment, determine the account type
          PaymentAccountType accountType;
          if (account.code == '1000') {
            accountType = PaymentAccountType.cash;
          } else {
            accountType = PaymentAccountType.bank;
          }

          // Find a matching payment account or use first of same type
          final matchingAccounts = paymentAccounts
              .where((pa) => pa.accountType == accountType)
              .toList();

          if (matchingAccounts.isNotEmpty && mounted) {
            final paymentAccount = matchingAccounts.first;
            final paidAmount = payment.credit; // Credit represents cash paid

            setState(() {
              _paymentLines.add(PaymentLineDraft(
                accountId: paymentAccount.id,
                accountName: paymentAccount.accountName,
                accountIcon: paymentAccount.icon,
                amount: paidAmount,
              ));
              totalPaidAmount += paidAmount;
            });
          }
        }
      }

      // Set the total paid amount
      if (mounted) {
        setState(() {
          _paidAmount = totalPaidAmount;
          _cashAmountCtrl.text =
              totalPaidAmount > 0 ? totalPaidAmount.toString() : '';
        });
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
            _paidAmount = 0;
            _cashAmountCtrl.text = ''; // Clear cash amount field
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
    _supplierSearchCtrl.dispose();
    _supplierSearchFocus.dispose();
    _itemSearchCtrl.dispose();
    _itemSearchFocus.dispose();
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (var controller in _rateControllers.values) {
      controller.dispose();
    }
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

  double get _grandTotal {
    return _afterDiscount + _totalVAT + _shippingCharge;
  }

  /// Update paid amount and recalculate remaining balance
  void _updatePaidAmount(double amount) {
    setState(() {
      _paidAmount = amount;
      _calculateTotalPayable(); // Recalculate when paid amount changes
    });
  }

  /// Trigger recalculation when line items change
  void _onLineItemChanged() {
    _calculateTotalPayable();
  }

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
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          // Share button for all invoices (new and existing)
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: 'Share Invoice',
            onSelected: (String value) {
              if (value == 'whatsapp') {
                _shareToWhatsApp(company);
              } else if (value == 'pdf') {
                _shareAsPDF(company);
              } else if (value == 'image') {
                _shareAsImage(purchaseDao, company, user);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.chat, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Share to WhatsApp'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'image',
                child: Row(
                  children: [
                    Icon(Icons.image, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Share as Image'),
                  ],
                ),
              ),
            ],
          ),
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
          padding:
              EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSupplierSelector(context),
              SizedBox(
                  height: MediaQuery.of(context).size.width > 600 ? 28 : 20),
              productAsync.when(
                data: (products) => Column(
                  children: [
                    _buildAddItemsSearch(
                      MediaQuery.of(context).size.width > 600,
                      MediaQuery.of(context).size.width > 600 ? 15 : 13,
                      context,
                      products,
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width > 600 ? 20 : 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _lines.length,
                      itemBuilder: (_, i) => Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.width > 600
                                ? 16
                                : 12),
                        child: Dismissible(
                          key: Key('line_item_$i'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (_lines.length <= 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('At least one item is required'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return false;
                            }
                            return true;
                          },
                          onDismissed: (direction) {
                            setState(() {
                              _lines.removeAt(i);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item deleted'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child:
                              _buildLineItem(context, _lines[i], products, i),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Error loading products')),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.width > 600 ? 28 : 20),
              _buildCalculationCard(),
              SizedBox(
                  height: MediaQuery.of(context).size.width > 600 ? 28 : 20),
              SizedBox(
                  height: MediaQuery.of(context).size.width > 600 ? 28 : 20),
              _buildPaymentLinesSection(),
              SizedBox(
                  height: MediaQuery.of(context).size.width > 600 ? 28 : 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          await _savePurchaseInvoice(
                              purchaseDao, company, user);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSaving ? Colors.grey : Colors.orange,
                    padding: EdgeInsets.symmetric(
                        vertical:
                            MediaQuery.of(context).size.width > 600 ? 18 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Purchase',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 600 ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePurchaseInvoice(
      PurchaseDao purchaseDao, Company company, User? user) async {
    // Prevent multiple simultaneous saves
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
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

      // Prepare payment lines - combine manual payments with paid amount
      final allPaymentLines = <PaymentLineDraft>[..._paymentLines];

      // If user entered a paid amount, update the first payment line (usually cash)
      if (_paidAmount > 0 && allPaymentLines.isNotEmpty) {
        allPaymentLines[0].amount = _paidAmount;
      }

      final validPaymentLines = allPaymentLines
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
          // Stay on the screen - don't navigate away
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
          // Stay on the screen - don't navigate away
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSupplierSelector(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final partyAsync = ref.watch(partyListProvider);

    return partyAsync.when(
      data: (parties) {
        final suppliers = parties; // Show all types of parties
        final searchQuery = _supplierSearchCtrl.text.toLowerCase();
        final filtered = suppliers
            .where((s) => s.name.toLowerCase().contains(searchQuery))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Single row with supplier selector and balance
            Row(
              children: [
                // Supplier Selector (left side)
                Expanded(
                  flex: _selectedSupplier != null ? 2 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedSupplier != null
                            ? const Color(0xFFFF8C42)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      controller: _supplierSearchCtrl,
                      focusNode: _supplierSearchFocus,
                      onChanged: (value) => setState(() {}),
                      onTap: () {
                        // Show all suppliers when field is tapped
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText:
                            _selectedSupplier?.name ?? 'Search Supplier...',
                        hintStyle: TextStyle(
                          color: _selectedSupplier?.name != null
                              ? Colors.grey.shade900
                              : Colors.grey.shade500,
                          fontSize: isTablet ? 15 : 13,
                        ),
                        prefixIcon: Icon(
                          Icons.business,
                          size: isTablet ? 20 : 18,
                          color: _selectedSupplier != null
                              ? const Color(0xFFFF8C42)
                              : Colors.grey.shade400,
                        ),
                        suffixIcon: _selectedSupplier != null
                            ? IconButton(
                                icon:
                                    Icon(Icons.clear, size: isTablet ? 18 : 16),
                                onPressed: () {
                                  setState(() {
                                    _selectedSupplier = null;
                                    _supplierSearchCtrl.clear();
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 10,
                          vertical: isTablet ? 12 : 10,
                        ),
                      ),
                    ),
                  ),
                ),
                // Supplier Opening Balance Display (right side)
                if (_selectedSupplier != null) ...[
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedSupplier!.openingBalance >= 0
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedSupplier!.openingBalance >= 0
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 12 : 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedSupplier!.openingBalance >= 0
                                ? Icons.account_balance_wallet
                                : Icons.warning,
                            size: isTablet ? 18 : 16,
                            color: _selectedSupplier!.openingBalance >= 0
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                          ),
                          SizedBox(width: isTablet ? 8 : 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Opening Balance',
                                  style: TextStyle(
                                    fontSize: isTablet ? 10 : 9,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _selectedSupplier!.openingBalance >= 0
                                      ? 'Opening Credit: Rs ${_selectedSupplier!.openingBalance.toStringAsFixed(0)}'
                                      : 'Opening Due: Rs ${_selectedSupplier!.openingBalance.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        _selectedSupplier!.openingBalance >= 0
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // Dropdown suggestions - show all suppliers when focused
            if (_supplierSearchFocus.hasFocus)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight: searchQuery.isEmpty
                      ? (suppliers.length * (isTablet ? 65.0 : 55.0)) +
                          (_selectedSupplier == null
                              ? (isTablet ? 70.0 : 60.0)
                              : 0)
                      : (filtered.length * (isTablet ? 65.0 : 55.0)) +
                          (_selectedSupplier == null
                              ? (isTablet ? 70.0 : 60.0)
                              : 0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add New Party button (only show when no supplier is selected)
                    if (_selectedSupplier == null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.business_outlined,
                            color: Colors.green.shade600,
                            size: isTablet ? 20 : 18,
                          ),
                          title: Text(
                            searchQuery.isNotEmpty
                                ? 'Add "$searchQuery" as new supplier'
                                : 'Add New Supplier',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: isTablet ? 16 : 14,
                            color: Colors.green.shade600,
                          ),
                          onTap: () {
                            if (searchQuery.isNotEmpty) {
                              _addNewPartyWithName(searchQuery);
                            } else {
                              _addNewParty();
                            }
                          },
                        ),
                      ),
                    // Existing suppliers list
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: searchQuery.isEmpty
                            ? suppliers.length
                            : filtered.length,
                        itemBuilder: (context, index) {
                          final party = searchQuery.isEmpty
                              ? suppliers[index]
                              : filtered[index];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: isTablet ? 16 : 14,
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                party.name.isNotEmpty
                                    ? party.name[0].toUpperCase()
                                    : 'S',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                            title: Text(
                              party.name,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: FutureBuilder<double>(
                              future: _getSupplierBalance(party.id),
                              builder: (context, balanceSnapshot) {
                                final balance = balanceSnapshot.data ?? 0.0;
                                final isLoading =
                                    balanceSnapshot.connectionState ==
                                        ConnectionState.waiting;

                                if (isLoading) {
                                  return Text(
                                    'Loading balance...',
                                    style: TextStyle(
                                      fontSize: isTablet ? 11 : 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  );
                                }

                                return Text(
                                  balance >= 0
                                      ? 'Credit: Rs ${balance.toStringAsFixed(2)}'
                                      : 'Due: Rs ${balance.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 11 : 10,
                                    color: balance >= 0
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                                  ),
                                );
                              },
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: isTablet ? 14 : 12,
                              color: Colors.grey.shade400,
                            ),
                            onTap: () {
                              _onSupplierSelected(party);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text('Error loading suppliers'),
      ),
    );
  }

  Widget _buildLineItem(
    BuildContext context,
    PurchaseLineDraft line,
    List<Product> products,
    int index,
  ) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final amount = (line.qty * line.rate).toStringAsFixed(2);

    // Ensure controllers exist for this index
    if (!_qtyControllers.containsKey(index)) {
      _qtyControllers[index] = TextEditingController(
        text: line.qty > 0
            ? (line.qty == line.qty.roundToDouble()
                ? line.qty.toStringAsFixed(0)
                : line.qty.toString())
            : '',
      );
    }
    if (!_rateControllers.containsKey(index)) {
      _rateControllers[index] = TextEditingController(
        text: line.rate > 0 ? line.rate.toStringAsFixed(2) : '',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
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
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      '${line.qty == line.qty.roundToDouble() ? line.qty.toStringAsFixed(0) : line.qty.toStringAsFixed(2)} X ${line.rate.toStringAsFixed(2)} = $amount',
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quantity Field
                  SizedBox(
                    width: isTablet ? 90 : 70,
                    height: isTablet ? 40 : 32,
                    child: TextField(
                      controller: _qtyControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                      decoration: InputDecoration(
                        hintText: 'Qty',
                        border: const OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final qty = double.tryParse(value);
                          if (qty != null && qty > 0) {
                            setState(() {
                              line.qty = qty;
                            });
                            _onLineItemChanged(); // Trigger recalculation
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  // Rate Field
                  SizedBox(
                    width: isTablet ? 90 : 70,
                    height: isTablet ? 40 : 32,
                    child: TextField(
                      controller: _rateControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                      decoration: InputDecoration(
                        hintText: 'Rate',
                        border: const OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final rate = double.tryParse(value);
                          if (rate != null && rate >= 0) {
                            setState(() {
                              line.rate = rate;
                            });
                            _onLineItemChanged(); // Trigger recalculation
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemsSearch(bool isTablet, double fontSize,
      BuildContext context, List<Product> products) {
    final searchQuery = _itemSearchCtrl.text.toLowerCase();

    // Enhanced search - search by name, SKU, and category
    final filtered = searchQuery.isEmpty
        ? products // Show all products when no search query
        : products.where((p) {
            final nameMatch = p.name.toLowerCase().contains(searchQuery);
            final skuMatch = p.sku.toLowerCase().contains(searchQuery);
            return nameMatch || skuMatch;
          }).toList();

    // Sort filtered results by relevance (exact matches first, then partial matches)
    if (searchQuery.isNotEmpty) {
      filtered.sort((a, b) {
        final aNameExact = a.name.toLowerCase() == searchQuery;
        final bNameExact = b.name.toLowerCase() == searchQuery;
        final aSkuExact = a.sku.toLowerCase() == searchQuery;
        final bSkuExact = b.sku.toLowerCase() == searchQuery;

        if (aNameExact && !bNameExact) return -1;
        if (bNameExact && !aNameExact) return 1;
        if (aSkuExact && !bSkuExact) return -1;
        if (bSkuExact && !aSkuExact) return 1;

        return a.name.compareTo(b.name);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _itemSearchCtrl,
            focusNode: _itemSearchFocus,
            onChanged: (value) => setState(() {}),
            onTap: () {
              setState(() {
                _showAllItems = true;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search & Add Items (Name, SKU)...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: isTablet ? 15 : 13,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: isTablet ? 22 : 20,
                color: Colors.blue.shade600,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_itemSearchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, size: isTablet ? 18 : 16),
                      onPressed: () {
                        setState(() {
                          _itemSearchCtrl.clear();
                        });
                      },
                    ),
                  Icon(
                    Icons.add_circle_outline,
                    size: isTablet ? 20 : 18,
                    color: Colors.blue.shade600,
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                ],
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 10,
                vertical: isTablet ? 12 : 10,
              ),
            ),
          ),
        ),
        // Enhanced dropdown suggestions - show all items when focused or filtered results
        if (_showAllItems || searchQuery.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: isTablet ? 300 : 250,
            ),
            child: Column(
              children: [
                // Header showing count
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 10,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        searchQuery.isEmpty
                            ? 'All Items (${filtered.length})'
                            : 'Found ${filtered.length} items',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        Text(
                          'Tap to add',
                          style: TextStyle(
                            fontSize: isTablet ? 10 : 9,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Items list
                Expanded(
                  child: filtered.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: isTablet ? 32 : 28,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: isTablet ? 8 : 6),
                                Text(
                                  searchQuery.isNotEmpty
                                      ? 'No items found for "$searchQuery"'
                                      : 'No products available',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final product = filtered[index];
                            final isAlreadyAdded = _lines
                                .any((line) => line.productId == product.id);
                            final addedCount = _lines
                                .where((line) => line.productId == product.id)
                                .length;

                            return ListTile(
                              dense: true,
                              leading: Container(
                                width: isTablet ? 40 : 32,
                                height: isTablet ? 40 : 32,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: isAlreadyAdded
                                    ? Center(
                                        child: Text(
                                          addedCount.toString(),
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.add,
                                        size: isTablet ? 20 : 16,
                                        color: Colors.blue.shade600,
                                      ),
                              ),
                              title: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.sku.isNotEmpty)
                                    Text(
                                      'SKU: ${product.sku}',
                                      style: TextStyle(
                                        fontSize: isTablet ? 10 : 9,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _lines.add(PurchaseLineDraft(
                                    productId: product.id,
                                    productName: product.name,
                                    qty: 1,
                                    rate: product.lastCost > 0
                                        ? product.lastCost
                                        : product.salePrice,
                                  ));
                                  _itemSearchCtrl.clear();
                                });
                                _onLineItemChanged(); // Trigger recalculation

                                // Show success feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${product.name} added to purchase${isAlreadyAdded ? ' (${addedCount + 1} times total)' : ''}'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCalculationCard() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final totalPaid =
        _paymentLines.fold<double>(0, (sum, payment) => sum + payment.amount);
    final balanceAmount = _grandTotal - totalPaid;
    final totalQty = _lines.fold<double>(0, (sum, l) => sum + l.qty);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Column(
        children: [
          _buildCalcRow('Total Quantity', totalQty,
              isTablet: isTablet, isQuantity: true),
          const Divider(),
          _buildCalcRow('Total', _grandTotal, isBold: true, isTablet: isTablet),
          const Divider(),
          _buildCalcRow('Paid Amount', totalPaid,
              isTablet: isTablet, color: Colors.green.shade700),
          const Divider(),
          _buildCalcRow('Balance Amount', balanceAmount,
              isBold: true,
              isTablet: isTablet,
              color: balanceAmount > 0
                  ? Colors.red.shade700
                  : Colors.green.shade700),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, double value,
      {bool isBold = false,
      bool isTablet = false,
      Color? color,
      bool isQuantity = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isTablet ? 16 : 14,
            color: color,
          ),
        ),
        Text(
          isQuantity
              ? value.toStringAsFixed(0)
              : 'Rs ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isTablet ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSummaryCard(bool isTablet) {
    final validLines =
        _lines.where((l) => l.productId != null && l.qty > 0 && l.rate > 0);
    final totalQty = validLines.fold<double>(0, (sum, l) => sum + l.qty);
    final totalAmount =
        validLines.fold<double>(0, (sum, l) => sum + (l.qty * l.rate));
    // Only calculate balance due if paid amount is entered (> 0)
    final balanceDue = _paidAmount > 0 ? totalAmount - _paidAmount : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Billed Items Header
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Colors.grey.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Billed Items',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    'Delete Items',
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Items List Table
            if (validLines.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 12 : 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text('Item Name',
                            style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600))),
                    Expanded(
                        child: Text('Qty',
                            style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600),
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: Text('Rate',
                            style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600),
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: Text('Amount',
                            style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600),
                            textAlign: TextAlign.right)),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ...validLines
                  .map((line) => Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 10 : 8),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(line.productName ?? 'Unknown',
                                    style: TextStyle(
                                        fontSize: isTablet ? 13 : 11,
                                        color: Colors.grey.shade900),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                            Expanded(
                                child: Text(
                                    line.qty == line.qty.roundToDouble()
                                        ? line.qty.toStringAsFixed(0)
                                        : line.qty.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: isTablet ? 13 : 11,
                                        color: Colors.grey.shade700),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                child: Text(line.rate.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: isTablet ? 13 : 11,
                                        color: Colors.grey.shade700),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                child: Text(
                                    (line.qty * line.rate).toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: isTablet ? 13 : 11,
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.right)),
                          ],
                        ),
                      ))
                  .toList(),
              Divider(height: 1, color: Colors.grey.shade300),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 10 : 8),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text('Total',
                            style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900))),
                    Expanded(
                        child: Text(
                            totalQty == totalQty.roundToDouble()
                                ? totalQty.toStringAsFixed(0)
                                : totalQty.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900),
                            textAlign: TextAlign.center)),
                    const Expanded(child: SizedBox()),
                    Expanded(
                        child: Text(totalAmount.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900),
                            textAlign: TextAlign.right)),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
            ],
            // Total Amount

            Divider(height: 1, color: Colors.grey.shade200),

            Divider(height: 1, color: Colors.grey.shade300),
            // Balance Due
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                  color: const Color(0xFF26C485).withOpacity(0.05)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Balance Due',
                        style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF26C485))),
                    Row(children: [
                      Text('Rs',
                          style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: const Color(0xFF26C485),
                              fontWeight: FontWeight.w600)),
                      SizedBox(width: isTablet ? 16 : 12),
                      Text(balanceDue.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF26C485)))
                    ]),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSummary() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        // Balance Summary Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Purchase Summary',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),

              // Previous Balance - always show
              _buildSummaryRow(
                'Previous Balance',
                _previousBalance,
                color: _previousBalance > 0
                    ? Colors.orange.shade700
                    : Colors.grey.shade600,
                isTablet: isTablet,
              ),
              SizedBox(height: isTablet ? 12 : 8),

              // New Purchase Amount
              _buildSummaryRow(
                'New Purchase Amount',
                _grandTotal,
                color: Colors.blue.shade700,
                isTablet: isTablet,
              ),

              if (_previousBalance > 0) ...[
                SizedBox(height: isTablet ? 12 : 8),
                Divider(color: Colors.grey.shade300),
                SizedBox(height: isTablet ? 12 : 8),

                // Total Payable Amount
                _buildSummaryRow(
                  'Total Payable Amount',
                  _totalPayableAmount,
                  color: Colors.grey.shade900,
                  isTablet: isTablet,
                  isBold: true,
                  fontSize: isTablet ? 18 : 16,
                ),
              ],

              SizedBox(height: isTablet ? 12 : 8),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: isTablet ? 12 : 8),

              // Paid Amount
              _buildSummaryRow(
                'Paid Amount',
                _paidAmount,
                color: Colors.green.shade700,
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 12 : 8),

              // Remaining Balance
              _buildSummaryRow(
                'Remaining Balance',
                _remainingBalance,
                color: _remainingBalance > 0
                    ? Colors.red.shade700
                    : Colors.green.shade700,
                isTablet: isTablet,
                isBold: true,
                backgroundColor: _remainingBalance > 0
                    ? Colors.red.shade50
                    : Colors.green.shade50,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    required Color color,
    required bool isTablet,
    bool isBold = false,
    double? fontSize,
    Color? backgroundColor,
  }) {
    return Container(
      padding: backgroundColor != null
          ? EdgeInsets.symmetric(
              vertical: isTablet ? 8 : 6, horizontal: isTablet ? 12 : 8)
          : EdgeInsets.zero,
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize ?? (isTablet ? 14 : 12),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            'Rs ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: fontSize ?? (isTablet ? 14 : 12),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLinesSection() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final paymentAccountsAsync = ref.watch(paymentAccountsProvider);

    return paymentAccountsAsync.when(
      data: (accounts) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cash Amount Input Field
            Text(
              'Cash Payment',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _cashAmountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
                decoration: InputDecoration(
                  hintText: 'Enter cash amount',
                  prefixIcon: Icon(
                    Icons.payments,
                    size: isTablet ? 20 : 18,
                    color: Colors.green.shade600,
                  ),
                  prefixText: 'Rs ',
                  prefixStyle: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.green.shade50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 14 : 12,
                  ),
                ),
                onChanged: (value) {
                  final cashAmount = double.tryParse(value) ?? 0;
                  _updatePaidAmount(cashAmount);
                  // Update the first cash payment line if it exists
                  if (_paymentLines.isNotEmpty) {
                    final cashLineIndex = _paymentLines.indexWhere(
                      (line) =>
                          line.accountName?.toLowerCase().contains('cash') ==
                          true,
                    );
                    if (cashLineIndex >= 0) {
                      _paymentLines[cashLineIndex].amount = cashAmount;
                    }
                  }
                },
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            if (_paymentLines.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                child: Center(
                  child: Text(
                    'No payment methods added',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: isTablet ? 16 : 14),
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
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 8 : 4, vertical: isTablet ? 8 : 6),
      child: Row(
        children: [
          Text(
            line.accountIcon ?? '💰',
            style: TextStyle(fontSize: isTablet ? 28 : 22),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              line.accountName ?? 'Unknown',
              style: TextStyle(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Colors.red, size: isTablet ? 24 : 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() => _paymentLines.removeAt(index));
            },
          ),
          SizedBox(width: isTablet ? 12 : 8),
          SizedBox(
            width: isTablet ? 160 : 140,
            child: TextFormField(
              key: ValueKey('payment_amount_${index}_${line.accountId}'),
              initialValue:
                  line.amount > 0 ? line.amount.toStringAsFixed(2) : '',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: isTablet ? 16 : 14),
              decoration: InputDecoration(
                prefixText: 'Rs ',
                prefixStyle: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Colors.blue.shade600,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8, vertical: isTablet ? 10 : 8),
              ),
              onChanged: (value) {
                try {
                  final newAmount = double.tryParse(value) ?? 0;
                  if (newAmount != line.amount) {
                    setState(() {
                      line.amount = newAmount;
                    });
                  }
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
    final isTablet = MediaQuery.of(context).size.width > 600;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Account',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              ...accounts.where((account) {
                final name = account.accountName.toLowerCase();
                return !name.contains('cheque') && !name.contains('check');
              }).map((account) {
                return ListTile(
                  leading: Text(
                    account.icon ?? '💰',
                    style: TextStyle(fontSize: isTablet ? 28 : 24),
                  ),
                  title: Text(
                    account.accountName,
                    style: TextStyle(fontSize: isTablet ? 16 : 15),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: isTablet ? 8 : 4),
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
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareAsImage(
      PurchaseDao purchaseDao, Company company, User? user) async {
    try {
      // First save the invoice if needed
      if (widget.invoiceId == null && _selectedSupplier != null) {
        await _savePurchaseInvoice(purchaseDao, company, user);
      }

      if (_selectedSupplier == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a supplier first'),
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
            content: Text('Please add at least one item to share'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get the invoice and transaction data
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;

      // Find the most recent invoice for this supplier and date
      Invoice? invoice;
      if (widget.invoiceId != null) {
        invoice = await purchaseDao.getInvoiceById(widget.invoiceId!);
      } else {
        // For newly created invoice, find by date and supplier
        final allInvoices = await isar.invoices
            .filter()
            .companyIdEqualTo(company.id)
            .invoiceTypeEqualTo(InvoiceType.purchase)
            .findAll();

        invoice = allInvoices
            .where((i) =>
                i.invoiceDate.day == _date.day &&
                i.invoiceDate.month == _date.month &&
                i.invoiceDate.year == _date.year &&
                i.partyId == _selectedSupplier!.id)
            .lastOrNull;
      }

      if (invoice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice not found. Please save first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final transaction =
          await purchaseDao.getTransactionForInvoice(invoice.id);
      if (transaction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Prepare line items
      final lineItems = <Map<String, dynamic>>[];
      for (final line in validLines) {
        final product = line.productId != null
            ? await isar.products.get(line.productId!)
            : null;
        lineItems.add({
          'productName': product?.name ?? line.productName ?? 'Unknown Product',
          'qty': line.qty,
          'rate': line.rate,
        });
      }

      // Prepare payment lines
      final paymentDetails = <Map<String, dynamic>>[];
      final validPaymentLines = _paymentLines
          .where((p) => p.accountId != null && p.amount > 0)
          .toList();

      for (final payLine in validPaymentLines) {
        if (payLine.accountId != null) {
          final account = await isar.accounts.get(payLine.accountId!);
          paymentDetails.add({
            'accountName': account?.name ?? payLine.accountName ?? 'Unknown',
            'amount': payLine.amount,
          });
        }
      }

      // Calculate the current supplier balance
      final supplierBalance = await _getSupplierBalance(_selectedSupplier!.id);

      // Generate and share the image
      await PurchaseInvoiceGenerator.shareAsImage(
        company: company,
        supplier: _selectedSupplier!,
        invoice: invoice,
        transaction: transaction,
        lineItems: lineItems,
        paymentLines: paymentDetails.isNotEmpty ? paymentDetails : null,
        supplierBalance: supplierBalance,
        openingBalance: _selectedSupplier!.openingBalance,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase invoice image shared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareAsPdf(
      PurchaseDao purchaseDao, Company company, User? user) async {
    try {
      // First save the invoice if needed
      if (widget.invoiceId == null && _selectedSupplier != null) {
        await _savePurchaseInvoice(purchaseDao, company, user);
      }

      if (_selectedSupplier == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a supplier first'),
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
            content: Text('Please add at least one item to share'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get the invoice and transaction data
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;

      // Find the most recent invoice for this supplier and date
      Invoice? invoice;
      if (widget.invoiceId != null) {
        invoice = await purchaseDao.getInvoiceById(widget.invoiceId!);
      } else {
        // For newly created invoice, find by date and supplier
        final allInvoices = await isar.invoices
            .filter()
            .companyIdEqualTo(company.id)
            .invoiceTypeEqualTo(InvoiceType.purchase)
            .findAll();

        invoice = allInvoices
            .where((i) =>
                i.invoiceDate.day == _date.day &&
                i.invoiceDate.month == _date.month &&
                i.invoiceDate.year == _date.year &&
                i.partyId == _selectedSupplier!.id)
            .lastOrNull;
      }

      if (invoice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice not found. Please save first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final transaction =
          await purchaseDao.getTransactionForInvoice(invoice.id);
      if (transaction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Prepare line items
      final lineItems = <Map<String, dynamic>>[];
      for (final line in validLines) {
        final product = line.productId != null
            ? await isar.products.get(line.productId!)
            : null;
        lineItems.add({
          'productName': product?.name ?? line.productName ?? 'Unknown Product',
          'qty': line.qty,
          'rate': line.rate,
        });
      }

      // Prepare payment lines
      final paymentDetails = <Map<String, dynamic>>[];
      final validPaymentLines = _paymentLines
          .where((p) => p.accountId != null && p.amount > 0)
          .toList();

      for (final payLine in validPaymentLines) {
        if (payLine.accountId != null) {
          final account = await isar.accounts.get(payLine.accountId!);
          paymentDetails.add({
            'accountName': account?.name ?? payLine.accountName ?? 'Unknown',
            'amount': payLine.amount,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase invoice PDF shared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to add new party form
  Future<void> _addNewParty() async {
    final result = await Navigator.of(context).push<Party>(
      MaterialPageRoute(
        builder: (context) => const PartyFormScreen(),
      ),
    );

    if (result != null) {
      // Refresh the parties list
      ref.refresh(partyListProvider);

      // Select the newly added party
      setState(() {
        _selectedSupplier = result;
        _supplierSearchCtrl.text = result.name;
        _supplierSearchFocus.unfocus();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Supplier "${result.name}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Navigate to add new party with pre-filled name
  Future<void> _addNewPartyWithName(String name) async {
    // Create a new Party instance with the searched name
    final newParty = Party()
      ..name = name
      ..partyType = PartyType.supplier
      ..openingBalance = 0
      ..creditLimit = 0
      ..paymentTermsDays = 0
      ..isActive = true;

    final result = await Navigator.of(context).push<Party>(
      MaterialPageRoute(
        builder: (context) => PartyFormScreen(party: newParty),
      ),
    );

    if (result != null) {
      // Refresh the parties list
      ref.refresh(partyListProvider);

      // Select the newly added party
      setState(() {
        _selectedSupplier = result;
        _supplierSearchCtrl.text = result.name;
        _supplierSearchFocus.unfocus();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Supplier "${result.name}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _shareAsPDF(Company company) async {
    if (widget.invoiceId == null) return;

    try {
      // Get the invoice data
      final invoiceData = await _getInvoiceData(company);
      if (invoiceData == null) return;
    } catch (e) {
      print('Error sharing PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _getInvoiceData(Company company) async {
    // Get the invoice using Isar
    final isarService = ref.read(isarServiceProvider);
    final isar = isarService.isar;
    final purchaseDao = PurchaseDao(isar);

    // Fetch the invoice
    final invoice = await isar.invoices.get(widget.invoiceId!);
    if (invoice == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    // Get the supplier
    final supplier = await isar.partys.get(invoice.partyId);
    if (supplier == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    // Get transaction
    final transaction = await isar.transactions.get(invoice.transactionId);
    if (transaction == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    // Get transaction lines
    final transactionLines =
        await purchaseDao.getTransactionLines(transaction.id);

    // Prepare line items with product names
    final lineItems = <Map<String, dynamic>>[];
    for (final txLine in transactionLines) {
      if (txLine.productId != null) {
        final product = await isar.products.get(txLine.productId!);
        lineItems.add({
          'productName': product?.name ?? 'Unknown',
          'qty': txLine.quantity,
          'rate': txLine.unitPrice,
        });
      }
    }

    // Get payment details - set to null for now
    List<Map<String, dynamic>>? paymentDetails = null;

    // Calculate supplier current balance
    final partyDao = PartyDao(isar);
    final supplierBalance = await partyDao.getPartyBalance(
      partyId: supplier.id,
      companyId: company.id,
    );

    // Get opening balance
    final openingBalance = supplier.openingBalance;

    return {
      'invoice': invoice,
      'supplier': supplier,
      'transaction': transaction,
      'lineItems': lineItems,
      'paymentDetails': paymentDetails,
      'supplierBalance': supplierBalance,
      'openingBalance': openingBalance,
    };
  }

  Future<void> _shareExistingInvoice(Company company) async {
    if (widget.invoiceId == null) return;

    try {
      // Get the invoice using Isar
      final isarService = ref.read(isarServiceProvider);
      final isar = isarService.isar;
      final purchaseDao = PurchaseDao(isar);

      // Fetch the invoice
      final invoice = await isar.invoices.get(widget.invoiceId!);
      if (invoice == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get the supplier
      final supplier = await isar.partys.get(invoice.partyId);
      if (supplier == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Supplier not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get transaction
      final transaction = await isar.transactions.get(invoice.transactionId);
      if (transaction == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get transaction lines
      final transactionLines =
          await purchaseDao.getTransactionLines(transaction.id);

      // Prepare line items with product names
      final lineItems = <Map<String, dynamic>>[];
      for (final txLine in transactionLines) {
        if (txLine.productId != null) {
          final product = await isar.products.get(txLine.productId!);
          lineItems.add({
            'productName': product?.name ?? 'Unknown',
            'qty': txLine.quantity,
            'rate': txLine.unitPrice,
          });
        }
      }

      // Get payment details - set to null for now
      List<Map<String, dynamic>>? paymentDetails = null;

      // Calculate supplier current balance
      final partyDao = PartyDao(isar);
      final supplierBalance = await partyDao.getPartyBalance(
        partyId: supplier.id,
        companyId: company.id,
      );

      // Get opening balance
      final openingBalance = supplier.openingBalance;

      // Call purchase invoice generator
      await PurchaseInvoiceGenerator.sharePurchaseInvoice(
        context: context,
        company: company,
        supplier: supplier,
        invoice: invoice,
        transaction: transaction,
        lineItems: lineItems,
        paymentLines: paymentDetails,
        supplierBalance: supplierBalance,
        openingBalance: openingBalance,
      );
    } catch (e) {
      print('Error sharing invoice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareToWhatsApp(Company company) async {
    if (widget.invoiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save the invoice first before sharing'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sending via WhatsApp...'),
            ],
          ),
        ),
      );

      final isar = ref.read(isarServiceProvider).isar;
      final purchaseDao = ref.read(purchaseDaoProvider);

      // Get invoice details
      final invoice = await isar.invoices.get(widget.invoiceId!);
      if (invoice == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      // Get supplier
      final supplier = await isar.partys.get(invoice.partyId);
      if (supplier == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      // Get transaction
      final transaction = await isar.transactions.get(invoice.transactionId);
      if (transaction == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      if (mounted) Navigator.pop(context); // Close loading dialog

      // Use enhanced WhatsApp service with automatic phone detection
      final whatsappService = WhatsAppService();

      // Extract supplier phone number from various sources
      String? supplierPhone = supplier.phone;
      if (supplierPhone == null || supplierPhone.isEmpty) {
        // Try to extract from supplier name or address
        supplierPhone = WhatsAppService.extractPhoneNumber(supplier.name) ??
            WhatsAppService.extractPhoneNumber(supplier.address);
      }

      final success = await whatsappService.shareInvoice(
        invoiceNumber: transaction.referenceNo ?? 'N/A',
        amount: invoice.grandTotal,
        currency: 'Rs',
        customerName: supplier.name,
        customerPhone: supplierPhone,
        invoiceType: 'Purchase Invoice',
        additionalDetails:
            'Date: ${invoice.invoiceDate.toString().split(' ')[0]}',
      );

      if (mounted) {
        if (success && supplierPhone != null && supplierPhone.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Purchase invoice sent to ${supplier.name} via WhatsApp!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Invoice shared via WhatsApp! (No phone number found for direct messaging)'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to send via WhatsApp. Please check supplier phone number.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error sharing to WhatsApp: $e');
    }
  }
}
