import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/providers.dart';
import '../../../core/widgets/navigation_drawer_helper.dart';
import '../../../data/models/invoice_stock_models.dart';
import '../../../data/models/party_model.dart';
import '../services/sales_invoice_service.dart';

class SaleInvoiceListScreen extends ConsumerStatefulWidget {
  const SaleInvoiceListScreen({super.key});

  @override
  ConsumerState<SaleInvoiceListScreen> createState() =>
      _SaleInvoiceListScreenState();
}

class _SaleInvoiceListScreenState extends ConsumerState<SaleInvoiceListScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';
  final _currencyFormat = NumberFormat.currency(symbol: 'PKR ');
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Initialize with empty text to prevent Android input issues
    _searchController.text = '';
  }

  @override
  void dispose() {
    try {
      _searchController.dispose();
    } catch (e) {
      print('Error disposing search controller: $e');
    }
    super.dispose();
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete this invoice?\nAmount: ${_currencyFormat.format(invoice.grandTotal)}',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final isar = ref.read(isarServiceProvider).isar;
        final service = SalesInvoiceService(isar);
        await service.deleteSaleInvoice(invoice.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          try {
            setState(() {}); // Refresh list
          } catch (e) {
            print('Error refreshing after delete: $e');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting invoice: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final company = ref.watch(currentCompanyProvider);

    if (company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sale Invoices')),
        body: const Center(child: Text('Please select a company first')),
      );
    }

    final isar = ref.watch(isarServiceProvider).isar;
    final service = SalesInvoiceService(isar);

    return Scaffold(
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'sales',
      ),
      appBar: AppBar(
        title: const Text('Sale Invoices'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.push('/sales/invoice/form');
              if (result == true && mounted) {
                try {
                  setState(() {}); // Refresh list
                } catch (e) {
                  print('Error refreshing after navigation: $e');
                }
              }
            },
            tooltip: 'Add Sale Invoice',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surface,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Search invoice...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          try {
                            if (mounted && _searchController.text.isNotEmpty) {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            }
                          } catch (e) {
                            print('Error clearing search: $e');
                          }
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                try {
                  if (mounted) {
                    setState(() => _searchQuery = value);
                  }
                } catch (e) {
                  print('Error updating search query: $e');
                }
              },
              onTap: () {
                // Handle tap explicitly to prevent Android input issues
                try {
                  if (!mounted) return;
                  // Ensure the controller is properly initialized
                  if (_searchController.text.isEmpty) {
                    _searchController.selection = TextSelection.fromPosition(
                      const TextPosition(offset: 0),
                    );
                  }
                } catch (e) {
                  print('Error handling search field tap: $e');
                }
              },
            ),
          ),

          // Invoice List
          Expanded(
            child: FutureBuilder<List<Invoice>>(
              future: _searchQuery.isEmpty
                  ? service.getAllSaleInvoices(company.id)
                  : service.searchSaleInvoices(company.id, _searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading invoices',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final invoices = snapshot.data ?? [];

                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No Sale Invoices Found'
                              : 'No matching invoices',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Tap + to create your first sale invoice'
                              : 'Try a different search term',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return _buildInvoiceCard(invoice, colorScheme, service);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/sales/invoice/form');
          if (result == true && mounted) {
            try {
              setState(() {}); // Refresh list
            } catch (e) {
              print('Error refreshing after FAB navigation: $e');
            }
          }
        },
        tooltip: 'Add Sale Invoice',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInvoiceCard(
    Invoice invoice,
    ColorScheme colorScheme,
    SalesInvoiceService service,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // TODO: Navigate to invoice detail/edit screen
          final result = await context.push(
            '/sales/invoice/form?id=${invoice.id}',
          );
          if (result == true && mounted) {
            try {
              setState(() {}); // Refresh list
            } catch (e) {
              print('Error refreshing after card tap: $e');
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Invoice Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Invoice Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Invoice #${invoice.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (invoice.status != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    invoice.status!,
                                  ).withAlpha(51),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  invoice.status!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getStatusColor(invoice.status!),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<Party?>(
                          future: service.getPartyForInvoice(invoice.partyId),
                          builder: (context, snapshot) {
                            final partyName =
                                snapshot.data?.name ?? 'Loading...';
                            return Text(
                              partyName,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Date and Amount
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _dateFormat.format(invoice.invoiceDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _currencyFormat.format(invoice.grandTotal),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              // Due Date if exists
              if (invoice.dueDate != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Due: ${_dateFormat.format(invoice.dueDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: invoice.dueDate!.isBefore(DateTime.now())
                            ? Colors.red
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],

              // Action Buttons
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await context.push(
                        '/sales/invoice/form?id=${invoice.id}',
                      );
                      if (result == true && mounted) {
                        try {
                          setState(() {}); // Refresh list
                        } catch (e) {
                          print('Error refreshing after edit: $e');
                        }
                      }
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _deleteInvoice(invoice),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
