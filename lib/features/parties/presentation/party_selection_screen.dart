import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/party_model.dart';
import '../logic/party_provider.dart';
import 'party_form_screen.dart';

class PartySelectionScreen extends ConsumerStatefulWidget {
  final PartyType? initialPartyType;
  final bool showSuppliers;
  final bool showCustomers;
  final String title;

  const PartySelectionScreen({
    super.key,
    this.initialPartyType,
    this.showSuppliers = true,
    this.showCustomers = true,
    this.title = 'Select Party',
  });

  @override
  ConsumerState<PartySelectionScreen> createState() =>
      _PartySelectionScreenState();
}

class _PartySelectionScreenState extends ConsumerState<PartySelectionScreen> {
  late PartyType? _selectedPartyType;
  CustomerClass? _selectedCustomerClass;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedPartyType = widget.initialPartyType;
  }

  @override
  Widget build(BuildContext context) {
    final partyAsync = ref.watch(partyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push<Party>(
                context,
                MaterialPageRoute(
                  builder: (_) => const PartyFormScreen(),
                ),
              );
              if (result != null && mounted) {
                Navigator.pop(context, result);
              }
            },
            tooltip: 'Add New Party',
          ),
        ],
      ),
      body: partyAsync.when(
        data: (parties) {
          var filteredList = parties.where((party) {
            final matchesSearch =
                party.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesType = _selectedPartyType == null ||
                party.partyType == _selectedPartyType;
            final matchesClass = _selectedCustomerClass == null ||
                party.customerClass == _selectedCustomerClass;

            // Apply visibility filters
            if (!widget.showSuppliers &&
                party.partyType == PartyType.supplier) {
              return false;
            }
            if (!widget.showCustomers &&
                party.partyType != PartyType.supplier) {
              return false;
            }

            return matchesSearch && matchesType && matchesClass;
          }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  _buildSearchBar(),
                  const SizedBox(height: 20),

                  // Filter dropdowns
                  _buildFilterDropdowns(),
                  const SizedBox(height: 20),

                  // Party list
                  if (filteredList.isEmpty)
                    _buildEmptyState()
                  else
                    _buildPartyList(filteredList),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading parties')),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      decoration: InputDecoration(
        hintText: 'Search party name...',
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
    );
  }

  Widget _buildFilterDropdowns() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade50,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<PartyType?>(
              value: _selectedPartyType,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Party Type'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Types'),
                ),
                if (widget.showCustomers)
                  const DropdownMenuItem(
                    value: PartyType.customer,
                    child: Text('Customer'),
                  ),
                if (widget.showCustomers)
                  const DropdownMenuItem(
                    value: PartyType.both,
                    child: Text('Customer & Supplier'),
                  ),
                if (widget.showSuppliers)
                  const DropdownMenuItem(
                    value: PartyType.supplier,
                    child: Text('Supplier'),
                  ),
              ],
              onChanged: (value) {
                setState(() => _selectedPartyType = value);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade50,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<CustomerClass?>(
              value: _selectedCustomerClass,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Customer Type'),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('All Classes'),
                ),
                DropdownMenuItem(
                  value: CustomerClass.retailer,
                  child: Text('Retailer'),
                ),
                DropdownMenuItem(
                  value: CustomerClass.wholesaler,
                  child: Text('Wholesaler'),
                ),
                DropdownMenuItem(
                  value: CustomerClass.other,
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedCustomerClass = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartyList(List<Party> parties) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parties.length,
      itemBuilder: (context, index) {
        final party = parties[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context, party);
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
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: party.partyType == PartyType.supplier
                          ? Colors.orange.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        party.name.isNotEmpty
                            ? party.name[0].toUpperCase()
                            : 'P',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: party.partyType == PartyType.supplier
                              ? Colors.orange.shade600
                              : Colors.red.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          party.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPartyTypeBgColor(party.partyType),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                party.partyType.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      _getPartyTypeTextColor(party.partyType),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (party.partyType != PartyType.supplier)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  party.customerClass.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Phone: ${party.phone ?? 'N/A'} • Balance: \$${party.openingBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Checkmark or arrow
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No parties found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPartyTypeBgColor(PartyType type) {
    switch (type) {
      case PartyType.supplier:
        return Colors.orange.shade100;
      case PartyType.customer:
        return Colors.red.shade100;
      case PartyType.both:
        return Colors.purple.shade100;
    }
  }

  Color _getPartyTypeTextColor(PartyType type) {
    switch (type) {
      case PartyType.supplier:
        return Colors.orange.shade700;
      case PartyType.customer:
        return Colors.red.shade700;
      case PartyType.both:
        return Colors.purple.shade700;
    }
  }
}
