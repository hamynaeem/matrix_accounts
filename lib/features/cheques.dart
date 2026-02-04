// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/config/providers.dart';
import '../core/widgets/navigation_drawer_helper.dart';
import '../data/models/party_model.dart';
import '../features/parties/presentation/party_selection_screen.dart';

enum ChequeType {
  received,
  issued,
}

enum ChequeStatus {
  pending,
  deposited,
  cleared,
  bounced,
  cancelled,
}

class ChequeData {
  final String? id;
  final String chequeNo;
  final DateTime chequeDate;
  final DateTime dueDate;
  final double amount;
  final Party party;
  final String bankName;
  final String branchName;
  final ChequeType type;
  final ChequeStatus status;
  final String? remarks;
  final DateTime createdAt;

  ChequeData({
    this.id,
    required this.chequeNo,
    required this.chequeDate,
    required this.dueDate,
    required this.amount,
    required this.party,
    required this.bankName,
    required this.branchName,
    required this.type,
    required this.status,
    this.remarks,
    required this.createdAt,
  });
}

// Cheques Provider
class ChequesNotifier extends StateNotifier<List<ChequeData>> {
  ChequesNotifier() : super(_getInitialData());

  static List<ChequeData> _getInitialData() {
    // Sample data to start with - in real app this would come from database
    return [
      ChequeData(
        id: '1',
        chequeNo: 'CHQ001',
        chequeDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 25)),
        amount: 50000,
        party: Party()
          ..id = 1
          ..name = 'ABC Suppliers'
          ..partyType = PartyType.supplier,
        bankName: 'HBL Bank',
        branchName: 'Main Branch',
        type: ChequeType.received,
        status: ChequeStatus.pending,
        remarks: 'Payment for Invoice #INV001',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ChequeData(
        id: '2',
        chequeNo: 'CHQ002',
        chequeDate: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 28)),
        amount: 75000,
        party: Party()
          ..id = 2
          ..name = 'XYZ Enterprises'
          ..partyType = PartyType.customer,
        bankName: 'UBL Bank',
        branchName: 'Commercial Branch',
        type: ChequeType.issued,
        status: ChequeStatus.cleared,
        remarks: 'Advance payment for services',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ChequeData(
        id: '3',
        chequeNo: 'CHQ003',
        chequeDate: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 29)),
        amount: 25000,
        party: Party()
          ..id = 3
          ..name = 'DEF Limited'
          ..partyType = PartyType.customer,
        bankName: 'MCB Bank',
        branchName: 'City Branch',
        type: ChequeType.received,
        status: ChequeStatus.deposited,
        remarks: 'Regular payment',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void addCheque(ChequeData cheque) {
    state = [...state, cheque];
  }

  void updateCheque(ChequeData updatedCheque) {
    state = [
      for (final cheque in state)
        if (cheque.id == updatedCheque.id) updatedCheque else cheque,
    ];
  }

  void deleteCheque(String id) {
    state = state.where((cheque) => cheque.id != id).toList();
  }

  void updateChequeStatus(String id, ChequeStatus newStatus) {
    state = [
      for (final cheque in state)
        if (cheque.id == id) cheque.copyWith(status: newStatus) else cheque,
    ];
  }
}

final chequesProvider =
    StateNotifierProvider<ChequesNotifier, List<ChequeData>>((ref) {
  return ChequesNotifier();
});

class ChequesScreen extends ConsumerStatefulWidget {
  const ChequesScreen({super.key});

  @override
  ConsumerState<ChequesScreen> createState() => _ChequesScreenState();
}

class _ChequesScreenState extends ConsumerState<ChequesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ChequeStatus? _selectedStatus;
  final _currencyFormat = NumberFormat.currency(symbol: 'PKR ');
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'cheques',
      ),
      appBar: AppBar(
        title: const Text('Cheques Management'),
        elevation: 0,
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showChequeFormDialog(),
            tooltip: 'Add New Cheque',
          ),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received Cheques', icon: Icon(Icons.call_received)),
            Tab(text: 'Issued Cheques', icon: Icon(Icons.call_made)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(colorScheme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChequesList(ChequeType.received),
                _buildChequesList(ChequeType.issued),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChequeFormDialog(),
        backgroundColor: Colors.teal.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search cheques...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 12),
          // Status Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: _selectedStatus == null,
                  onTap: () {
                    setState(() {
                      _selectedStatus = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...ChequeStatus.values.map((status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        label: _getStatusLabel(status),
                        isSelected: _selectedStatus == status,
                        onTap: () {
                          setState(() {
                            _selectedStatus =
                                _selectedStatus == status ? null : status;
                          });
                        },
                      ),
                    )),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChequesList(ChequeType type) {
    final allCheques = ref.watch(chequesProvider);
    final filteredCheques = allCheques.where((cheque) {
      final matchesSearch = _searchQuery.isEmpty ||
          cheque.chequeNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cheque.party.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          cheque.bankName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = cheque.type == type;
      final matchesStatus =
          _selectedStatus == null || cheque.status == _selectedStatus;
      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    if (filteredCheques.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCheques.length,
      itemBuilder: (context, index) {
        final cheque = filteredCheques[index];
        return _buildChequeCard(cheque);
      },
    );
  }

  Widget _buildEmptyState(ChequeType type) {
    final typeLabel = type == ChequeType.received ? 'received' : 'issued';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No $typeLabel cheques found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first $typeLabel cheque using the + button',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChequeCard(ChequeData cheque) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _getStatusColor(cheque.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          cheque.type == ChequeType.received
                              ? Icons.call_received
                              : Icons.call_made,
                          color: _getStatusColor(cheque.status),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cheque #${cheque.chequeNo}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              cheque.party.name,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currencyFormat.format(cheque.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(cheque.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusLabel(cheque.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Details Row
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.calendar_today,
                    'Cheque Date',
                    _dateFormat.format(cheque.chequeDate),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.event,
                    'Due Date',
                    _dateFormat.format(cheque.dueDate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.account_balance,
                    'Bank',
                    cheque.bankName,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.location_on,
                    'Branch',
                    cheque.branchName,
                  ),
                ),
              ],
            ),
            if (cheque.remarks != null && cheque.remarks!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailItem(
                Icons.note,
                'Remarks',
                cheque.remarks!,
              ),
            ],
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showChequeFormDialog(cheque: cheque),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showStatusUpdateDialog(cheque),
                  child: const Text('Update Status'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _deleteCheque(cheque),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(ChequeStatus status) {
    switch (status) {
      case ChequeStatus.pending:
        return Colors.orange;
      case ChequeStatus.deposited:
        return Colors.blue;
      case ChequeStatus.cleared:
        return Colors.green;
      case ChequeStatus.bounced:
        return Colors.red;
      case ChequeStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusLabel(ChequeStatus status) {
    switch (status) {
      case ChequeStatus.pending:
        return 'Pending';
      case ChequeStatus.deposited:
        return 'Deposited';
      case ChequeStatus.cleared:
        return 'Cleared';
      case ChequeStatus.bounced:
        return 'Bounced';
      case ChequeStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _showChequeFormDialog({ChequeData? cheque}) {
    showDialog(
      context: context,
      builder: (context) => ChequeFormDialog(
        cheque: cheque,
        onSave: (newCheque) {
          if (cheque != null) {
            // Update existing cheque
            ref.read(chequesProvider.notifier).updateCheque(newCheque);
          } else {
            // Add new cheque
            ref.read(chequesProvider.notifier).addCheque(newCheque.copyWith(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                ));
          }
        },
      ),
    );
  }

  void _showStatusUpdateDialog(ChequeData cheque) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Cheque Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cheque #${cheque.chequeNo}'),
            const SizedBox(height: 16),
            Text('Current Status: ${_getStatusLabel(cheque.status)}'),
            const SizedBox(height: 16),
            const Text('Select New Status:'),
            const SizedBox(height: 8),
            ...ChequeStatus.values
                .where((status) => status != cheque.status)
                .map((status) => ListTile(
                      title: Text(_getStatusLabel(status)),
                      onTap: () {
                        ref.read(chequesProvider.notifier).updateCheque(
                              cheque.copyWith(status: status),
                            );
                        Navigator.pop(context);
                      },
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _deleteCheque(ChequeData cheque) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cheque'),
        content:
            Text('Are you sure you want to delete cheque #${cheque.chequeNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(chequesProvider.notifier).deleteCheque(cheque.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cheque deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Extension for copyWith functionality
extension ChequeDataExtension on ChequeData {
  ChequeData copyWith({
    String? id,
    String? chequeNo,
    DateTime? chequeDate,
    DateTime? dueDate,
    double? amount,
    Party? party,
    String? bankName,
    String? branchName,
    ChequeType? type,
    ChequeStatus? status,
    String? remarks,
    DateTime? createdAt,
  }) {
    return ChequeData(
      id: id ?? this.id,
      chequeNo: chequeNo ?? this.chequeNo,
      chequeDate: chequeDate ?? this.chequeDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      party: party ?? this.party,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      type: type ?? this.type,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Cheque Form Dialog
class ChequeFormDialog extends ConsumerStatefulWidget {
  final ChequeData? cheque;
  final Function(ChequeData) onSave;

  const ChequeFormDialog({
    super.key,
    this.cheque,
    required this.onSave,
  });

  @override
  ConsumerState<ChequeFormDialog> createState() => _ChequeFormDialogState();
}

class _ChequeFormDialogState extends ConsumerState<ChequeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _chequeNoController = TextEditingController();
  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime _chequeDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  Party? _selectedParty;
  ChequeType _selectedType = ChequeType.received;
  ChequeStatus _selectedStatus = ChequeStatus.pending;

  @override
  void initState() {
    super.initState();
    if (widget.cheque != null) {
      final cheque = widget.cheque!;
      _chequeNoController.text = cheque.chequeNo;
      _amountController.text = cheque.amount.toString();
      _bankNameController.text = cheque.bankName;
      _branchNameController.text = cheque.branchName;
      _remarksController.text = cheque.remarks ?? '';
      _chequeDate = cheque.chequeDate;
      _dueDate = cheque.dueDate;
      _selectedParty = cheque.party;
      _selectedType = cheque.type;
      _selectedStatus = cheque.status;
    }
  }

  @override
  void dispose() {
    _chequeNoController.dispose();
    _amountController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cheque != null ? 'Edit Cheque' : 'Add New Cheque',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Cheque Number
                      TextFormField(
                        controller: _chequeNoController,
                        decoration: const InputDecoration(
                          labelText: 'Cheque Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cheque number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: 'PKR ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Party Selection
                      InkWell(
                        onTap: () async {
                          final party = await Navigator.push<Party>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PartySelectionScreen(
                                title: 'Select Party',
                              ),
                            ),
                          );
                          if (party != null) {
                            setState(() {
                              _selectedParty = party;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedParty?.name ?? 'Select Party',
                                  style: TextStyle(
                                    color: _selectedParty != null
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cheque Type
                      DropdownButtonFormField<ChequeType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Cheque Type',
                          border: OutlineInputBorder(),
                        ),
                        items: ChequeType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type == ChequeType.received
                                  ? 'Received'
                                  : 'Issued',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cheque Status
                      DropdownButtonFormField<ChequeStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ChequeStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusLabel(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dates Row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _chequeDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    _chequeDate = date;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cheque Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(_chequeDate),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dueDate,
                                  firstDate: _chequeDate,
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dueDate = date;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Due Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(_dueDate),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bank Details Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _bankNameController,
                              decoration: const InputDecoration(
                                labelText: 'Bank Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter bank name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _branchNameController,
                              decoration: const InputDecoration(
                                labelText: 'Branch Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter branch name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Remarks
                      TextFormField(
                        controller: _remarksController,
                        decoration: const InputDecoration(
                          labelText: 'Remarks (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveCheque,
                    child: Text(widget.cheque != null ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(ChequeStatus status) {
    switch (status) {
      case ChequeStatus.pending:
        return 'Pending';
      case ChequeStatus.deposited:
        return 'Deposited';
      case ChequeStatus.cleared:
        return 'Cleared';
      case ChequeStatus.bounced:
        return 'Bounced';
      case ChequeStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _saveCheque() {
    if (_formKey.currentState!.validate() && _selectedParty != null) {
      final chequeData = ChequeData(
        id: widget.cheque?.id,
        chequeNo: _chequeNoController.text,
        chequeDate: _chequeDate,
        dueDate: _dueDate,
        amount: double.parse(_amountController.text),
        party: _selectedParty!,
        bankName: _bankNameController.text,
        branchName: _branchNameController.text,
        type: _selectedType,
        status: _selectedStatus,
        remarks:
            _remarksController.text.isEmpty ? null : _remarksController.text,
        createdAt: widget.cheque?.createdAt ?? DateTime.now(),
      );

      widget.onSave(chequeData);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.cheque != null
                ? 'Cheque updated successfully'
                : 'Cheque added successfully',
          ),
        ),
      );
    } else if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party')),
      );
    }
  }
}
