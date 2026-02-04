import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/providers.dart';
import '../../data/models/company_model.dart';
import '../../features/companies/services/company_service.dart';

class CompanySelectorScreen extends ConsumerStatefulWidget {
  const CompanySelectorScreen({super.key});

  @override
  ConsumerState<CompanySelectorScreen> createState() =>
      _CompanySelectorScreenState();
}

class _CompanySelectorScreenState extends ConsumerState<CompanySelectorScreen> {
  @override
  Widget build(BuildContext context) {
    final isar = ref.watch(isarServiceProvider).isar;
    final service = CompanyService(isar);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Select Company'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/masters/companies'),
            tooltip: 'Manage Companies',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/masters/companies/form');
          if (result == true && mounted) {
            setState(() {}); // Refresh list
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Company'),
      ),
      body: FutureBuilder<List<Company>>(
        future: service.getActiveCompanies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final companies = snapshot.data ?? [];

          if (companies.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: companies.length,
            itemBuilder: (_, i) {
              final company = companies[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCompanyCard(context, ref, company),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCompanyCard(
    BuildContext context,
    WidgetRef ref,
    Company company,
  ) {
    return GestureDetector(
      onTap: () async {
        // Persist company selection
        ref.read(currentCompanyProvider.notifier).state = company;
        ref.read(selectedCompanyIdProvider.notifier).state = company.id;

        // Save to shared preferences
        final authService = ref.read(authServiceProvider);
        await authService.saveSelectedCompany(
          companyId: company.id,
          companyName: company.name,
        );

        if (context.mounted) {
          context.go('/dashboard');
        }
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
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    company.name.isNotEmpty ? company.name[0] : 'C',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Currency: ${company.primaryCurrency}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Companies Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first company',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
