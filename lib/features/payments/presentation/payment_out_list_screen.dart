import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/party_model.dart';
import '../../../data/models/payment_models.dart';
import '../logic/payment_providers.dart';

class PaymentOutListScreen extends ConsumerStatefulWidget {
  const PaymentOutListScreen({super.key});

  @override
  ConsumerState<PaymentOutListScreen> createState() =>
      _PaymentOutListScreenState();
}

class _PaymentOutListScreenState extends ConsumerState<PaymentOutListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    final paymentsAsync = ref.watch(paymentOutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Out'),
        backgroundColor: Colors.red.shade700,
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
                hintText: 'Search vouchers...',
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
                  print('Error updating payment out search: $e');
                }
              },
            ),
          ),
          Expanded(
            child: paymentsAsync.when(
              data: (payments) {
                final filtered = payments.where((p) {
                  if (_searchQuery.isEmpty) return true;
                  return p.voucherNo.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No payment vouchers found'),
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
          final result = await context.push('/payments/out/form');
          if (result == true && mounted) {
            ref.invalidate(paymentOutsProvider);
          }
        },
        backgroundColor: Colors.red.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Out'),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentOut payment) {
    final isarService = ref.read(isarServiceProvider);
    final paymentDao = ref.read(paymentDaoProvider);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([
        isarService.isar.partys.get(payment.partyId),
        paymentDao.getPaymentOutLines(payment.id),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        final supplier = snapshot.data?[0] as Party?;
        final lines = snapshot.data?[1] as List<PaymentOutLine>? ?? [];

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
                  await context.push('/payments/out/form?id=${payment.id}');
              if (result == true && mounted) {
                ref.invalidate(paymentOutsProvider);
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
                              payment.voucherNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              supplier?.name ?? 'Unknown Supplier',
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
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${payment.voucherDate.day}/${payment.voucherDate.month}/${payment.voucherDate.year}',
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        account?.icon ?? '💰',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              account?.accountName ?? 'Unknown',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (line.referenceNo != null &&
                                                line.referenceNo!.isNotEmpty)
                                              Text(
                                                'Ref: ${line.referenceNo}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                          ],
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
                  if (payment.description != null &&
                      payment.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      payment.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
