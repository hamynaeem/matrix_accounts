import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/party_model.dart';
import '../logic/party_provider.dart';
import 'party_form_screen.dart';
import 'party_ledger_screen.dart';

class PartyListScreen extends ConsumerStatefulWidget {
  const PartyListScreen({super.key});

  @override
  ConsumerState<PartyListScreen> createState() => _PartyListScreenState();
}

class _PartyListScreenState extends ConsumerState<PartyListScreen> {
  PartyType? selectedPartyType;
  CustomerClass? selectedCustomerClass;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final partyAsync = ref.watch(partyListProvider);
    final company = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Master'),
        elevation: 0,
        actions: [
          if (company != null)
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
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'parties',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PartyFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: partyAsync.when(
        data: (list) {
          // Filter logic
          var filteredList = list.where((party) {
            final matchesSearch =
                party.name.toLowerCase().contains(searchQuery.toLowerCase());
            final matchesType = selectedPartyType == null ||
                party.partyType == selectedPartyType;
            final matchesClass = selectedCustomerClass == null ||
                party.customerClass == selectedCustomerClass;
            return matchesSearch && matchesType && matchesClass;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                if (filteredList.isEmpty)
                  _buildEmptyState()
                else
                  _buildPartyList(filteredList),
              ],
            ),
          );
        },
        error: (_, __) => const Center(child: Text('Error loading parties')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
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
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedPartyType != null ||
              selectedCustomerClass != null ||
              searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Text(
                    'Active Filters',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Party Type Filters
                _buildFilterChip(
                  label: 'Customer',
                  isSelected: selectedPartyType == PartyType.customer,
                  onTap: () {
                    setState(() {
                      selectedPartyType =
                          selectedPartyType == PartyType.customer
                              ? null
                              : PartyType.customer;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Supplier',
                  isSelected: selectedPartyType == PartyType.supplier,
                  onTap: () {
                    setState(() {
                      selectedPartyType =
                          selectedPartyType == PartyType.supplier
                              ? null
                              : PartyType.supplier;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Both',
                  isSelected: selectedPartyType == PartyType.both,
                  onTap: () {
                    setState(() {
                      selectedPartyType = selectedPartyType == PartyType.both
                          ? null
                          : PartyType.both;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Customer Class Filters
                _buildFilterChip(
                  label: 'Retailer',
                  isSelected: selectedCustomerClass == CustomerClass.retailer,
                  onTap: () {
                    setState(() {
                      selectedCustomerClass =
                          selectedCustomerClass == CustomerClass.retailer
                              ? null
                              : CustomerClass.retailer;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Wholesaler',
                  isSelected: selectedCustomerClass == CustomerClass.wholesaler,
                  onTap: () {
                    setState(() {
                      selectedCustomerClass =
                          selectedCustomerClass == CustomerClass.wholesaler
                              ? null
                              : CustomerClass.wholesaler;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Other',
                  isSelected: selectedCustomerClass == CustomerClass.other,
                  onTap: () {
                    setState(() {
                      selectedCustomerClass =
                          selectedCustomerClass == CustomerClass.other
                              ? null
                              : CustomerClass.other;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildPartyList(List<Party> parties) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: parties.length,
        itemBuilder: (_, i) {
          final p = parties[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPartyCard(p),
          );
        },
      ),
    );
  }

  Widget _buildPartyCard(Party party) {
    final company = ref.watch(currentCompanyProvider);
    final accountDao = ref.watch(accountDaoProvider);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PartyFormScreen(party: party)),
        );
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          party.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildBadge(
                              party.partyType.name.toUpperCase(),
                              Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            _buildBadge(
                              party.customerClass.name,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<double>(
                    future: company != null
                        ? accountDao
                            .getAccountBalance(company.id, '1200')
                            .then((arBalance) async {
                            // Get customer's AR balance from ledger
                            final ledger = await accountDao.getCustomerLedger(
                              companyId: company.id,
                              customerId: party.id,
                            );
                            if (ledger.isEmpty) return 0.0;
                            return ledger.first.runningBalance;
                          })
                        : Future.value(0.0),
                    builder: (context, snapshot) {
                      final balance = snapshot.data ?? 0.0;
                      final isReceivable = balance > 0;
                      final isPayable = balance < 0;

                      return Container(
                        decoration: BoxDecoration(
                          color: isReceivable
                              ? Colors.green.shade50
                              : isPayable
                                  ? Colors.red.shade50
                                  : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Balance',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '₹${balance.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isReceivable
                                    ? Colors.green.shade700
                                    : isPayable
                                        ? Colors.red.shade700
                                        : Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              isReceivable
                                  ? 'To Receive'
                                  : isPayable
                                      ? 'To Pay'
                                      : 'Settled',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (party.phone != null && party.phone!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            party.phone!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PartyLedgerScreen(party: party),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 16),
                          label: const Text('Ledger',
                              style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PartyFormScreen(party: party)),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PartyLedgerScreen(party: party),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 16),
                          label: const Text('Ledger',
                              style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PartyFormScreen(party: party)),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Parties Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'No parties match your search'
                : 'No parties added yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedPartyType = null;
      selectedCustomerClass = null;
      searchQuery = '';
    });
  }
}
