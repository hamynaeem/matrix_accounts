// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQ> _faqs = [
    FAQ(
      category: 'Getting Started',
      question: 'How do I create a new company?',
      answer:
          'To create a new company:\n1. Go to Masters > Companies\n2. Click the + button\n3. Fill in company details\n4. Save the company',
    ),
    FAQ(
      category: 'Getting Started',
      question: 'How do I add products to inventory?',
      answer:
          'To add products:\n1. Go to Masters > Products\n2. Click Add Product\n3. Enter product details like name, price, stock\n4. Save the product',
    ),
    FAQ(
      category: 'Sales',
      question: 'How do I create a sales invoice?',
      answer:
          'To create a sales invoice:\n1. Go to Sales section\n2. Click New Invoice\n3. Select customer\n4. Add products and quantities\n5. Review and save',
    ),
    FAQ(
      category: 'Sales',
      question: 'Can I edit or delete a sales invoice?',
      answer:
          'Yes, you can edit invoices that haven\'t been finalized. Go to Sales list, tap on the invoice, and use the edit button.',
    ),
    FAQ(
      category: 'Purchases',
      question: 'How do I record a purchase?',
      answer:
          'To record purchases:\n1. Go to Purchases section\n2. Click New Purchase\n3. Select supplier\n4. Add items and costs\n5. Save the purchase',
    ),
    FAQ(
      category: 'Payments',
      question: 'How do I record payments received?',
      answer:
          'To record payment in:\n1. Go to Payments > Payment In\n2. Click Add Payment\n3. Select customer and amount\n4. Choose payment method\n5. Save',
    ),
    FAQ(
      category: 'Reports',
      question: 'How do I generate reports?',
      answer:
          'To generate reports:\n1. Go to Reports section\n2. Select the type of report\n3. Choose date range if needed\n4. View or export the report',
    ),
    FAQ(
      category: 'Reports',
      question: 'Can I export reports to PDF?',
      answer:
          'Yes, most reports can be exported to PDF format. Look for the export button in the report screen.',
    ),
    FAQ(
      category: 'Troubleshooting',
      question: 'The app is running slowly. What can I do?',
      answer:
          'Try these steps:\n1. Close and restart the app\n2. Clear cache from Settings\n3. Ensure you have sufficient storage\n4. Update to the latest version',
    ),
    FAQ(
      category: 'Troubleshooting',
      question: 'I can\'t see my data after updating',
      answer:
          'Your data should be preserved during updates. If you can\'t see it:\n1. Restart the app\n2. Check if you\'re in the correct company\n3. Contact support if the issue persists',
    ),
  ];

  final List<UserGuide> _userGuides = [
    UserGuide(
      title: 'Setting Up Your First Company',
      description: 'Learn how to configure your business information',
      steps: [
        'Open the app and complete the initial setup',
        'Go to Masters > Companies',
        'Click the + button to add a new company',
        'Fill in your business details like name, address, GST number',
        'Set up your financial year and accounting preferences',
        'Save your company profile',
      ],
    ),
    UserGuide(
      title: 'Managing Inventory',
      description: 'How to add and manage your products',
      steps: [
        'Navigate to Masters > Products',
        'Click Add Product to create new items',
        'Enter product name, category, and pricing',
        'Set opening stock quantities',
        'Configure units of measurement',
        'Save and organize your inventory',
      ],
    ),
    UserGuide(
      title: 'Creating Sales Invoices',
      description: 'Step-by-step guide to sales processing',
      steps: [
        'Go to the Sales section',
        'Click New Invoice',
        'Select or add customer details',
        'Add products from your inventory',
        'Set quantities and verify pricing',
        'Apply taxes and discounts if applicable',
        'Review and save the invoice',
        'Print or share with customer',
      ],
    ),
    UserGuide(
      title: 'Financial Reporting',
      description: 'Understanding your business reports',
      steps: [
        'Access the Reports section',
        'Choose from various report types',
        'Set appropriate date ranges',
        'Review profit & loss statements',
        'Check balance sheet for financial position',
        'Analyze cash flow patterns',
        'Export reports for external use',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<FAQ> get filteredFAQs {
    if (_searchQuery.isEmpty) return _faqs;
    return _faqs
        .where((faq) =>
            faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            faq.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            faq.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.quiz), text: 'FAQ'),
            Tab(icon: Icon(Icons.book), text: 'Guides'),
            Tab(icon: Icon(Icons.support), text: 'Contact'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildGuidesTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    final Map<String, List<FAQ>> categorizedFAQs = {};
    for (final faq in filteredFAQs) {
      categorizedFAQs.putIfAbsent(faq.category, () => []).add(faq);
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search FAQs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // FAQ List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: categorizedFAQs.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  ...entry.value.map((faq) => _buildFAQItem(faq)),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userGuides.length,
      itemBuilder: (context, index) {
        final guide = _userGuides[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  guide.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ...guide.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Contact Cards
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.email,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Email Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('support@matrix-solutions.com'),
                  const SizedBox(height: 8),
                  Text(
                    'We typically respond within 24 hours',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening email app...')),
                      );
                    },
                    child: const Text('Send Email'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Phone Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('+91 12345-67890'),
                  const SizedBox(height: 8),
                  Text(
                    'Available Mon-Fri, 9 AM - 6 PM IST',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Dialing phone number...')),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Call Now'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.chat,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Live Chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get instant help from our support team',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting live chat...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text('Start Chat'),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Additional Resources
          Text(
            'Additional Resources',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildResourceButton(
                'User Manual',
                Icons.menu_book,
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening user manual...')),
                ),
              ),
              _buildResourceButton(
                'Video Tutorials',
                Icons.play_circle,
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening video tutorials...')),
                ),
              ),
              _buildResourceButton(
                'Community',
                Icons.group,
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening community forum...')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class FAQ {
  final String category;
  final String question;
  final String answer;

  FAQ({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class UserGuide {
  final String title;
  final String description;
  final List<String> steps;

  UserGuide({
    required this.title,
    required this.description,
    required this.steps,
  });
}
