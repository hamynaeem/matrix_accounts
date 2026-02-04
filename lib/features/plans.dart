// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/providers.dart';
import '../core/widgets/navigation_drawer_helper.dart';

// Plan Types
enum PlanType {
  daily,
  financial,
  reports,
  buySell,
  subscription,
}

// Plan model
class PlanFeature {
  final String name;
  final bool included;
  final String? details;

  const PlanFeature({
    required this.name,
    required this.included,
    this.details,
  });
}

class Plan {
  final String id;
  final String name;
  final String description;
  final PlanType type;
  final double price;
  final bool isActive;
  final List<PlanFeature> features;
  final Color color;
  final DateTime createdAt;
  final DateTime? dueDate;
  final Map<String, dynamic>? metadata;

  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    this.isActive = true,
    required this.features,
    required this.color,
    required this.createdAt,
    this.dueDate,
    this.metadata,
  });

  Plan copyWith({
    String? id,
    String? name,
    String? description,
    PlanType? type,
    double? price,
    bool? isActive,
    List<PlanFeature>? features,
    Color? color,
    DateTime? createdAt,
    DateTime? dueDate,
    Map<String, dynamic>? metadata,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      features: features ?? this.features,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Sample plans data
final plansProvider = StateNotifierProvider<PlansNotifier, List<Plan>>((ref) {
  return PlansNotifier();
});

class PlansNotifier extends StateNotifier<List<Plan>> {
  PlansNotifier() : super(_getInitialPlans());

  static List<Plan> _getInitialPlans() {
    final now = DateTime.now();
    return [
      Plan(
        id: 'daily_1',
        name: 'Morning Routine',
        description: 'Track daily morning financial activities',
        type: PlanType.daily,
        price: 0.00,
        color: Colors.orange,
        createdAt: now,
        dueDate: now.add(const Duration(days: 1)),
        features: [
          const PlanFeature(name: 'Check account balances', included: true),
          const PlanFeature(name: 'Review daily expenses', included: true),
          const PlanFeature(name: 'Plan daily budget', included: true),
        ],
      ),
      Plan(
        id: 'financial_1',
        name: 'Monthly Budget Plan',
        description: 'Comprehensive monthly financial planning',
        type: PlanType.financial,
        price: 199.99,
        color: Colors.green,
        createdAt: now,
        features: [
          const PlanFeature(name: 'Income tracking', included: true),
          const PlanFeature(name: 'Expense categorization', included: true),
          const PlanFeature(name: 'Investment planning', included: true),
          const PlanFeature(name: 'Savings goals', included: true),
        ],
      ),
      Plan(
        id: 'reports_1',
        name: 'Weekly Reports',
        description: 'Generate comprehensive financial reports',
        type: PlanType.reports,
        price: 49.99,
        color: Colors.blue,
        createdAt: now,
        features: [
          const PlanFeature(name: 'Profit & Loss reports', included: true),
          const PlanFeature(name: 'Cash flow analysis', included: true),
          const PlanFeature(name: 'Expense breakdown', included: true),
        ],
      ),
      Plan(
        id: 'buysell_1',
        name: 'Stock Trading Plan',
        description: 'Track buy and sell transactions',
        type: PlanType.buySell,
        price: 299.99,
        color: Colors.purple,
        createdAt: now,
        features: [
          const PlanFeature(name: 'Buy order tracking', included: true),
          const PlanFeature(name: 'Sell order tracking', included: true),
          const PlanFeature(name: 'Portfolio analysis', included: true),
          const PlanFeature(name: 'Profit/Loss calculation', included: true),
        ],
      ),
    ];
  }

  void addPlan(Plan plan) {
    state = [...state, plan];
  }

  void updatePlan(String id, Plan updatedPlan) {
    state = [
      for (final plan in state)
        if (plan.id == id) updatedPlan else plan,
    ];
  }

  void deletePlan(String id) {
    state = state.where((plan) => plan.id != id).toList();
  }

  void togglePlanStatus(String id) {
    state = [
      for (final plan in state)
        if (plan.id == id) plan.copyWith(isActive: !plan.isActive) else plan,
    ];
  }
}

// Selected plan type filter
final selectedPlanTypeProvider = StateProvider<PlanType?>((ref) => null);

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(currentCompanyProvider);
    final plans = ref.watch(plansProvider);
    final selectedPlanType = ref.watch(selectedPlanTypeProvider);

    // Filter plans by type
    final filteredPlans = selectedPlanType == null
        ? plans
        : plans.where((plan) => plan.type == selectedPlanType).toList();

    return Scaffold(
      drawer: NavigationDrawerHelper.buildNavigationDrawer(
        context,
        ref: ref,
        selectedItem: 'plans',
      ),
      appBar: AppBar(
        title: Text(company?.name ?? 'Plan Management'),
        elevation: 0,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlanDialog(context, ref),
            tooltip: 'Add New Plan',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
            tooltip: 'Filter Plans',
          ),
        ],
      ),
      body: Column(
        children: [
          // Plan Type Filter Bar
          _buildPlanTypeFilter(context, ref, selectedPlanType),

          // Plans Overview Stats
          _buildOverviewStats(context, plans),

          // Plans List
          Expanded(
            child: filteredPlans.isEmpty
                ? _buildEmptyState(context)
                : _buildPlansList(context, ref, filteredPlans),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlanDialog(context, ref),
        backgroundColor: Colors.indigo.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPlanTypeFilter(
      BuildContext context, WidgetRef ref, PlanType? selectedType) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(context, ref, null, 'All', selectedType),
          const SizedBox(width: 8),
          _buildFilterChip(context, ref, PlanType.daily, 'Daily', selectedType),
          const SizedBox(width: 8),
          _buildFilterChip(
              context, ref, PlanType.financial, 'Financial', selectedType),
          const SizedBox(width: 8),
          _buildFilterChip(
              context, ref, PlanType.reports, 'Reports', selectedType),
          const SizedBox(width: 8),
          _buildFilterChip(
              context, ref, PlanType.buySell, 'Buy/Sell', selectedType),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref, PlanType? type,
      String label, PlanType? selectedType) {
    final isSelected = selectedType == type;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        ref.read(selectedPlanTypeProvider.notifier).state =
            selected ? type : null;
      },
      selectedColor: Colors.indigo.shade100,
      checkmarkColor: Colors.indigo.shade700,
    );
  }

  Widget _buildOverviewStats(BuildContext context, List<Plan> plans) {
    final activePlans = plans.where((plan) => plan.isActive).length;
    final totalValue = plans
        .where((plan) => plan.isActive)
        .fold(0.0, (sum, plan) => sum + plan.price);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total Plans', plans.length.toString(), Icons.list),
            _buildStatItem(
                'Active Plans', activePlans.toString(), Icons.check_circle),
            _buildStatItem('Total Value',
                'Rs. ${totalValue.toStringAsFixed(2)}', Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No plans found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first plan to get started',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => {},
            icon: const Icon(Icons.add),
            label: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(
      BuildContext context, WidgetRef ref, List<Plan> plans) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _buildPlanCard(context, ref, plan);
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, Plan plan) {
    final isOverdue =
        plan.dueDate != null && plan.dueDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: plan.isActive
              ? plan.color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPlanDetailsDialog(context, ref, plan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: plan.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPlanTypeIcon(plan.type),
                      color: plan.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: plan.isActive ? null : Colors.grey,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: plan.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: plan.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              child: Text(
                                plan.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: plan.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          plan.description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rs. ${plan.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: plan.color,
                            ),
                      ),
                      Text(
                        _getPlanTypeName(plan.type),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (plan.dueDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isOverdue ? 'Overdue' : 'Due Date',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isOverdue ? Colors.red : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${plan.dueDate!.day}/${plan.dueDate!.month}/${plan.dueDate!.year}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isOverdue ? Colors.red : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${plan.features.where((f) => f.included).length} features',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Created: ${plan.createdAt.day}/${plan.createdAt.month}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          plan.isActive ? Icons.pause : Icons.play_arrow,
                          size: 20,
                        ),
                        onPressed: () {
                          ref
                              .read(plansProvider.notifier)
                              .togglePlanStatus(plan.id);
                        },
                        tooltip: plan.isActive ? 'Deactivate' : 'Activate',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () =>
                            _showEditPlanDialog(context, ref, plan),
                        tooltip: 'Edit Plan',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.red),
                        onPressed: () =>
                            _showDeleteConfirmDialog(context, ref, plan),
                        tooltip: 'Delete Plan',
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

  IconData _getPlanTypeIcon(PlanType type) {
    switch (type) {
      case PlanType.daily:
        return Icons.today;
      case PlanType.financial:
        return Icons.account_balance;
      case PlanType.reports:
        return Icons.analytics;
      case PlanType.buySell:
        return Icons.trending_up;
      case PlanType.subscription:
        return Icons.card_membership;
    }
  }

  String _getPlanTypeName(PlanType type) {
    switch (type) {
      case PlanType.daily:
        return 'Daily Plan';
      case PlanType.financial:
        return 'Financial Plan';
      case PlanType.reports:
        return 'Reports Plan';
      case PlanType.buySell:
        return 'Buy/Sell Plan';
      case PlanType.subscription:
        return 'Subscription Plan';
    }
  }

  void _showAddPlanDialog(BuildContext context, WidgetRef ref) {
    _showPlanFormDialog(context, ref, null);
  }

  void _showEditPlanDialog(BuildContext context, WidgetRef ref, Plan plan) {
    _showPlanFormDialog(context, ref, plan);
  }

  void _showPlanFormDialog(BuildContext context, WidgetRef ref, Plan? plan) {
    final nameController = TextEditingController(text: plan?.name ?? '');
    final descriptionController =
        TextEditingController(text: plan?.description ?? '');
    final priceController =
        TextEditingController(text: plan?.price.toString() ?? '');

    PlanType selectedType = plan?.type ?? PlanType.daily;
    DateTime? selectedDueDate = plan?.dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(plan == null ? 'Add New Plan' : 'Edit Plan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PlanType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Plan Type',
                        border: OutlineInputBorder(),
                      ),
                      items: PlanType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(_getPlanTypeIcon(type), size: 20),
                              const SizedBox(width: 8),
                              Text(_getPlanTypeName(type)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value ?? PlanType.daily;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (Rs.)',
                        border: OutlineInputBorder(),
                        prefixText: 'Rs. ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(selectedDueDate == null
                          ? 'Select Due Date (Optional)'
                          : 'Due Date: ${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}'),
                      leading: const Icon(Icons.calendar_today),
                      trailing: selectedDueDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedDueDate = null;
                                });
                              },
                            )
                          : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDueDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a plan name')),
                      );
                      return;
                    }

                    final price = double.tryParse(priceController.text) ?? 0.0;
                    final now = DateTime.now();

                    final newPlan = Plan(
                      id: plan?.id ?? 'plan_${now.millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      type: selectedType,
                      price: price,
                      color: _getColorForPlanType(selectedType),
                      createdAt: plan?.createdAt ?? now,
                      dueDate: selectedDueDate,
                      features: _getDefaultFeaturesForType(selectedType),
                      isActive: plan?.isActive ?? true,
                    );

                    if (plan == null) {
                      ref.read(plansProvider.notifier).addPlan(newPlan);
                    } else {
                      ref
                          .read(plansProvider.notifier)
                          .updatePlan(plan.id, newPlan);
                    }

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(plan == null
                            ? 'Plan created successfully'
                            : 'Plan updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text(plan == null ? 'Create' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getColorForPlanType(PlanType type) {
    switch (type) {
      case PlanType.daily:
        return Colors.orange;
      case PlanType.financial:
        return Colors.green;
      case PlanType.reports:
        return Colors.blue;
      case PlanType.buySell:
        return Colors.purple;
      case PlanType.subscription:
        return Colors.indigo;
    }
  }

  List<PlanFeature> _getDefaultFeaturesForType(PlanType type) {
    switch (type) {
      case PlanType.daily:
        return [
          const PlanFeature(name: 'Daily task tracking', included: true),
          const PlanFeature(name: 'Progress monitoring', included: true),
        ];
      case PlanType.financial:
        return [
          const PlanFeature(name: 'Budget planning', included: true),
          const PlanFeature(name: 'Expense tracking', included: true),
          const PlanFeature(name: 'Investment planning', included: true),
        ];
      case PlanType.reports:
        return [
          const PlanFeature(name: 'Generate reports', included: true),
          const PlanFeature(name: 'Data analysis', included: true),
        ];
      case PlanType.buySell:
        return [
          const PlanFeature(name: 'Transaction tracking', included: true),
          const PlanFeature(name: 'Profit/Loss calculation', included: true),
        ];
      case PlanType.subscription:
        return [
          const PlanFeature(name: 'Premium features', included: true),
        ];
    }
  }

  void _showDeleteConfirmDialog(
      BuildContext context, WidgetRef ref, Plan plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete "${plan.name}"?'),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(plansProvider.notifier).deletePlan(plan.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showPlanDetailsDialog(BuildContext context, WidgetRef ref, Plan plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(_getPlanTypeIcon(plan.type), color: plan.color),
              const SizedBox(width: 8),
              Expanded(child: Text(plan.name)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Type', _getPlanTypeName(plan.type)),
                _buildDetailRow(
                    'Price', 'Rs. ${plan.price.toStringAsFixed(2)}'),
                _buildDetailRow(
                    'Status', plan.isActive ? 'Active' : 'Inactive'),
                _buildDetailRow('Created',
                    '${plan.createdAt.day}/${plan.createdAt.month}/${plan.createdAt.year}'),
                if (plan.dueDate != null)
                  _buildDetailRow('Due Date',
                      '${plan.dueDate!.day}/${plan.dueDate!.month}/${plan.dueDate!.year}'),
                const SizedBox(height: 16),
                Text(
                  'Features:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...plan.features
                    .map((feature) => _buildFeatureRow(context, feature)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditPlanDialog(context, ref, plan);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Plans'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Plans'),
                leading: Radio<PlanType?>(
                  value: null,
                  groupValue: ref.read(selectedPlanTypeProvider),
                  onChanged: (value) {
                    ref.read(selectedPlanTypeProvider.notifier).state = value;
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ...PlanType.values.map((type) {
                return ListTile(
                  title: Text(_getPlanTypeName(type)),
                  leading: Radio<PlanType?>(
                    value: type,
                    groupValue: ref.read(selectedPlanTypeProvider),
                    onChanged: (value) {
                      ref.read(selectedPlanTypeProvider.notifier).state = value;
                      Navigator.of(context).pop();
                    },
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureRow(BuildContext context, PlanFeature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            feature.included ? Icons.check_circle : Icons.cancel,
            color: feature.included ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: feature.included ? null : Colors.grey,
                    decoration:
                        feature.included ? null : TextDecoration.lineThrough,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
