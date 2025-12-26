import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import '../logic/payment_providers.dart';

class PaymentInListScreen extends ConsumerStatefulWidget {
  const PaymentInListScreen({super.key});

  @override
  ConsumerState<PaymentInListScreen> createState() =>
      _PaymentInListScreenState();
}

class _PaymentInListScreenState extends ConsumerState<PaymentInListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final paymentsAsync = ref.watch(paymentInsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment In'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                company?.name ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search receipts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                try {
                  if (mounted) {
                    setState(() => _searchQuery = value.toLowerCase());
                  }
                } catch (e) {
                  print('Error updating payment search: $e');
                }
              },
            ),
          ),
          Expanded(
            child: paymentsAsync.when(
              data: (payments) {
                final filtered = payments.where((p) {
                  if (_searchQuery.isEmpty) return true;
                  return p.receiptNo.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No payment receipts found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final payment = filtered[index];
                    return _buildPaymentCard(payment);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/payments/in/form');
          if (result == true && mounted) {
            ref.invalidate(paymentInsProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Payment In'),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentIn payment) {
    final isarService = ref.read(isarServiceProvider);
    final paymentDao = ref.read(paymentDaoProvider);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([
        isarService.isar.partys.get(payment.partyId),
        paymentDao.getPaymentInLines(payment.id),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        final customer = snapshot.data?[0] as Party?;
        final lines = snapshot.data?[1] as List<PaymentInLine>? ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          child: InkWell(
            onTap: () async {
              final result =
                  await context.push('/payments/in/form?id=${payment.id}');
              if (result == true && mounted) {
                ref.invalidate(paymentInsProvider);
              }
            },
            borderRadius: BorderRadius.circular(12),
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
                              payment.receiptNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customer?.name ?? 'Unknown Customer',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs ${payment.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${payment.receiptDate.day}/${payment.receiptDate.month}/${payment.receiptDate.year}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (lines.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    ...lines
                        .map((line) => FutureBuilder(
                              future: paymentDao
                                  .getPaymentAccountById(line.paymentAccountId),
                              builder: (context,
                                  AsyncSnapshot<PaymentAccount?>
                                      accountSnapshot) {
                                final account = accountSnapshot.data;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        account?.icon ?? '💰',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          account?.accountName ?? 'Unknown',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Text(
                                        'Rs ${line.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ))
                        .toList(),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () async {
                          final result = await context
                              .push('/payments/in/form?id=${payment.id}');
                          if (result == true && mounted) {
                            ref.invalidate(paymentInsProvider);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.red),
                        onPressed: () => _deletePayment(payment.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePayment(int paymentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content:
            const Text('Are you sure you want to delete this payment receipt?'),
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

    if (confirm == true) {
      try {
        final paymentDao = ref.read(paymentDaoProvider);
        await paymentDao.deletePaymentIn(paymentId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(paymentInsProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting payment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
