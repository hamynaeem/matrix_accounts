import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/payment_models.dart';
import '../../payments/logic/payment_providers.dart';
import '../logic/payment_accounts_provider.dart';

class PaymentAccountFormScreen extends ConsumerStatefulWidget {
  final PaymentAccount? account;

  const PaymentAccountFormScreen({super.key, this.account});

  @override
  ConsumerState<PaymentAccountFormScreen> createState() =>
      _PaymentAccountFormScreenState();
}

class _PaymentAccountFormScreenState
    extends ConsumerState<PaymentAccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  PaymentAccountType _selectedType = PaymentAccountType.bank;
  String? _selectedIcon;
  bool _isLoading = false;

  final List<String> cashIcons = ['💵', '💰', '💸', '💳', '💴', '💶', '💷'];
  final List<String> bankIcons = ['🏦', '🏧', '💳', '🏛️', '🏪'];
  final List<String> chequeIcons = ['📄', '📝', '📋', '🧾'];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _loadAccount();
    }
  }

  void _loadAccount() {
    final account = widget.account!;
    _nameController.text = account.accountName;
    _selectedType = account.accountType;
    _selectedIcon = account.icon;
    if (account.accountType == PaymentAccountType.bank) {
      _bankNameController.text = account.bankName ?? '';
      _accountNumberController.text = account.accountNumber ?? '';
      _ifscController.text = account.ifscCode ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? 'Add Account' : 'Edit Account'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountTypeSelector(),
                    const SizedBox(height: 24),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildIconSelector(),
                    const SizedBox(height: 24),
                    if (_selectedType == PaymentAccountType.bank) ...[
                      _buildBankFields(),
                      const SizedBox(height: 24),
                    ],
                    _buildActionButtons(company),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeChip(
              'Cash',
              PaymentAccountType.cash,
              Icons.money,
            ),
            const SizedBox(width: 12),
            _buildTypeChip(
              'Bank',
              PaymentAccountType.bank,
              Icons.account_balance,
            ),
            const SizedBox(width: 12),
            _buildTypeChip(
              'Cheque',
              PaymentAccountType.cheque,
              Icons.receipt_long,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, PaymentAccountType type, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedIcon = null; // Reset icon when type changes
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Account Name *',
        hintText: 'e.g., Main Cash, SBI Current Account',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter account name';
        }
        return null;
      },
    );
  }

  Widget _buildIconSelector() {
    List<String> icons;
    switch (_selectedType) {
      case PaymentAccountType.cash:
        icons = cashIcons;
        break;
      case PaymentAccountType.bank:
        icons = bankIcons;
        break;
      case PaymentAccountType.cheque:
        icons = chequeIcons;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: icons.map((icon) {
            final isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = icon;
                });
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue.shade600
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBankFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bankNameController,
          decoration: InputDecoration(
            labelText: 'Bank Name',
            hintText: 'e.g., State Bank of India',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNumberController,
          decoration: InputDecoration(
            labelText: 'Account Number',
            hintText: 'Enter account number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ifscController,
          decoration: InputDecoration(
            labelText: 'IFSC Code',
            hintText: 'Enter IFSC code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }

  Widget _buildActionButtons(Company? company) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _saveAccount(company),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.account == null ? 'Add Account' : 'Update Account',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveAccount(Company? company) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (company == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No company selected')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentDao = ref.read(paymentDaoProvider);

      if (widget.account == null) {
        // Create new account
        await paymentDao.createPaymentAccount(
          companyId: company.id,
          accountType: _selectedType,
          accountName: _nameController.text.trim(),
          icon: _selectedIcon,
          bankName: _selectedType == PaymentAccountType.bank
              ? _bankNameController.text.trim()
              : null,
          accountNumber: _selectedType == PaymentAccountType.bank
              ? _accountNumberController.text.trim()
              : null,
          ifscCode: _selectedType == PaymentAccountType.bank
              ? _ifscController.text.trim()
              : null,
        );
      } else {
        // Update existing account
        await paymentDao.updatePaymentAccount(
          accountId: widget.account!.id,
          accountName: _nameController.text.trim(),
          icon: _selectedIcon,
          bankName: _selectedType == PaymentAccountType.bank
              ? _bankNameController.text.trim()
              : null,
          accountNumber: _selectedType == PaymentAccountType.bank
              ? _accountNumberController.text.trim()
              : null,
          ifscCode: _selectedType == PaymentAccountType.bank
              ? _ifscController.text.trim()
              : null,
        );
      }

      // Refresh the list
      ref.invalidate(cashBankAccountsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.account == null
                  ? 'Account added successfully'
                  : 'Account updated successfully',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }
}
