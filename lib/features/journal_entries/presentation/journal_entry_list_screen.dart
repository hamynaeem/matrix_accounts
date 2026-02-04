import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/account_models.dart';

class JournalEntryListScreen extends ConsumerStatefulWidget {
  const JournalEntryListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JournalEntryListScreen> createState() =>
      _JournalEntryListScreenState();
}

class _JournalEntryListScreenState
    extends ConsumerState<JournalEntryListScreen> {
  // List<JournalEntryGroup> _entries = [];
  List<Map<String, dynamic>> _entries = []; // Temporary placeholder
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntries();
    });
  }

  Future<void> _loadEntries() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // final accountDao = ref.read(accountDaoProvider);
      // final entries = await accountDao.getJournalEntries(company.id);

      setState(() {
        // _entries = entries;
        _entries = []; // Placeholder until feature is implemented
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading entries: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEntry(Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal Entry'),
        content: Text(
            'Are you sure you want to delete journal entry ${entry['referenceNo']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // final accountDao = ref.read(accountDaoProvider);
      // await accountDao.deleteJournalEntry(entry.referenceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Journal entry deleted successfully'),
              backgroundColor: Colors.green),
        );

        _loadEntries();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error deleting entry: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEntryDetails(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Journal Entry Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteEntry(entry);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Header Info
                _buildInfoRow('Reference No:', entry['referenceNo'] ?? 'N/A'),
                _buildInfoRow(
                    'Date:',
                    DateFormat('dd MMM yyyy')
                        .format(entry['date'] ?? DateTime.now())),
                _buildInfoRow('Description:', entry['description'] ?? 'N/A'),
                const SizedBox(height: 16),

                // Lines
                const Text(
                  'Transaction Lines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: (entry['lines'] as List?)?.length ?? 0,
                    itemBuilder: (context, index) {
                      final line = (entry['lines'] as List)[index];
                      return FutureBuilder<Account?>(
                        future:
                            null, // Disabled: getAccount method doesn't exist
                        builder: (context, snapshot) {
                          final account = snapshot.data;
                          final accountName =
                              account?.name ?? 'Unknown Account';
                          final accountCode = account?.code ?? '';

                          return Card(
                            child: ListTile(
                              title: Text('$accountCode - $accountName'),
                              subtitle: Text(line.description ?? ''),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (line.debit > 0)
                                    Text(
                                      'DR ₹${line.debit.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  if (line.credit > 0)
                                    Text(
                                      'CR ₹${line.credit.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Totals
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Debits'),
                          Text(
                            '₹${(entry['totalDebits'] as num? ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Total Credits'),
                          Text(
                            '₹${(entry['totalCredits'] as num? ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEntries,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/journal-entries/form');
          _loadEntries();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No journal entries yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap + to create your first entry',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => _showEntryDetails(entry),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: const Icon(Icons.receipt_long,
                              color: Colors.blue),
                        ),
                        title: Text(
                          entry['referenceNo'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry['description'] ?? 'N/A'),
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(entry['date'] ?? DateTime.now()),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${(entry['totalDebits'] as num? ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '${(entry['lines'] as List?)?.length ?? 0} lines',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    );
                  },
                ),
    );
  }
}
