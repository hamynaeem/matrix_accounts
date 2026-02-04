// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/database/dao/party_dao.dart';
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
  String searchQuery = '';

  /// Get current party balance from accounting ledger
  Future<double> _getPartyBalance(int partyId) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return 0.0;

    final isarService = ref.read(isarServiceProvider);
    final partyDao = PartyDao(isarService.isar);

    try {
      return await partyDao.getPartyBalance(
        partyId: partyId,
        companyId: company.id,
      );
    } catch (e) {
      print('Error getting party balance: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final partyAsync = ref.watch(partyListProvider);
    final company = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
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
            return matchesSearch && matchesType;
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
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: parties.length,
        itemBuilder: (_, i) {
          final p = parties[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Party Name (left) + Balance (right)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      party.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Rs ${party.openingBalance.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: party.openingBalance > 0
                          ? Colors.green.shade700
                          : party.openingBalance < 0
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: Type & Class Badges (left) + Balance Status (right)
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildCompactBadge(
                          party.partyType.name.toUpperCase(),
                          Colors.blue,
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: party.openingBalance > 0
                          ? Colors.green.shade100
                          : party.openingBalance < 0
                              ? Colors.red.shade100
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      party.openingBalance > 0
                          ? 'OPENING CR'
                          : party.openingBalance < 0
                              ? 'OPENING DR'
                              : 'NO OPENING',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: party.openingBalance > 0
                            ? Colors.green.shade700
                            : party.openingBalance < 0
                                ? Colors.red.shade700
                                : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 3: Phone (left) + Action Buttons (right)
              Row(
                children: [
                  Expanded(
                    child: party.phone != null && party.phone!.isNotEmpty
                        ? Row(
                            children: [
                              Icon(Icons.phone,
                                  size: 12, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  party.phone!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'No phone',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PartyLedgerScreen(party: party),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Ledger',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PartyFormScreen(party: party)),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          _showDeleteConfirmation(context, party, ref);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

  Widget _buildCompactBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
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
      searchQuery = '';
    });
  }

  void _showDeleteConfirmation(
      BuildContext context, Party party, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Party'),
        content: Text(
          'Are you sure you want to delete ${party.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final partyDao = ref.read(partyDaoProvider);
                await partyDao.deleteParty(party.id);
                ref.invalidate(partyListProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Party deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting party: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
