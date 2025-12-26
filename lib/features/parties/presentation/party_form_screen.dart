import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/party_dao.dart';
import '../../../data/models/party_model.dart';
import '../logic/party_provider.dart';

class PartyFormScreen extends ConsumerStatefulWidget {
  final Party? party;

  const PartyFormScreen({super.key, this.party});

  @override
  ConsumerState<PartyFormScreen> createState() => _PartyFormScreenState();
}

class _PartyFormScreenState extends ConsumerState<PartyFormScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _openingCtrl = TextEditingController();
  final _creditLimitCtrl = TextEditingController();
  final _paymentTermsCtrl = TextEditingController();

  PartyType _partyType = PartyType.customer;
  CustomerClass _customerClass = CustomerClass.retailer;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final p = widget.party;
    if (p != null) {
      _nameCtrl.text = p.name;
      _phoneCtrl.text = p.phone ?? '';
      _emailCtrl.text = p.email ?? '';
      _addressCtrl.text = p.address ?? '';
      _openingCtrl.text = p.openingBalance.toString();
      _creditLimitCtrl.text = p.creditLimit.toString();
      _paymentTermsCtrl.text = p.paymentTermsDays.toString();
      _partyType = p.partyType;
      _customerClass = p.customerClass;
      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _openingCtrl.dispose();
    _creditLimitCtrl.dispose();
    _paymentTermsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.read(partyDaoProvider);
    final company = ref.read(currentCompanyProvider)!;
    final isEditing = widget.party != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Party' : 'Add New Party'),
        elevation: 0,
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
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameCtrl,
                label: 'Party Name',
                hint: 'Enter party name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeSelector(),
                  ),
                  const SizedBox(width: 12),
                  if (_partyType != PartyType.supplier)
                    Expanded(
                      child: _buildCustomerClassSelector(),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                hint: 'Enter phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'Enter email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressCtrl,
                label: 'Address',
                hint: 'Enter address',
                icon: Icons.location_on,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Financial Information Section
              _buildSectionHeader('Financial Information'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _openingCtrl,
                      label: 'Opening Balance',
                      hint: '0.00',
                      icon: Icons.account_balance,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _creditLimitCtrl,
                      label: 'Credit Limit',
                      hint: '0.00',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _paymentTermsCtrl,
                label: 'Payment Terms (Days)',
                hint: '0',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Status Section
              _buildSectionHeader('Status'),
              const SizedBox(height: 16),
              _buildStatusSwitch(),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (_nameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter party name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final party = widget.party ?? Party();

                    party.companyId = company.id;
                    party.name = _nameCtrl.text.trim();
                    party.phone = _phoneCtrl.text.trim();
                    party.email = _emailCtrl.text.trim();
                    party.address = _addressCtrl.text.trim();
                    party.openingBalance =
                        double.tryParse(_openingCtrl.text) ?? 0;
                    party.creditLimit =
                        double.tryParse(_creditLimitCtrl.text) ?? 0;
                    party.paymentTermsDays =
                        int.tryParse(_paymentTermsCtrl.text) ?? 0;
                    party.partyType = _partyType;
                    if (_partyType != PartyType.supplier) {
                      party.customerClass = _customerClass;
                    }
                    party.isActive = _isActive;

                    await dao.saveParty(party);
                    ref.invalidate(partyListProvider);
                    Navigator.pop(context);
                  },
                  child: Text(
                    isEditing ? 'Update Party' : 'Add Party',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _showDeleteConfirmation(context, dao);
                    },
                    child: const Text(
                      'Delete Party',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: maxLines == 1 ? 1 : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PartyType>(
          value: _partyType,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          items: PartyType.values
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.name[0].toUpperCase() + e.name.substring(1),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _partyType = v);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCustomerClassSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CustomerClass>(
          value: _customerClass,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          items: CustomerClass.values
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.name[0].toUpperCase() + e.name.substring(1),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _customerClass = v);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Active Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (v) {
              setState(() => _isActive = v);
            },
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PartyDao dao) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Party'),
          content: const Text(
            'Are you sure you want to delete this party? This action cannot be undone.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                if (widget.party != null) {
                  await dao.deleteParty(widget.party!.id);
                  ref.invalidate(partyListProvider);
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Party deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
