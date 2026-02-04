import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() =>
      _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  bool _isDarkMode = false;
  String _selectedTheme = 'Blue';
  String _selectedFontSize = 'Medium';
  bool _systemTheme = true;

  final List<Map<String, dynamic>> _themeColors = [
    {'name': 'Blue', 'color': Colors.blue, 'secondary': Colors.blue.shade100},
    {
      'name': 'Green',
      'color': Colors.green,
      'secondary': Colors.green.shade100
    },
    {
      'name': 'Purple',
      'color': Colors.purple,
      'secondary': Colors.purple.shade100
    },
    {
      'name': 'Orange',
      'color': Colors.orange,
      'secondary': Colors.orange.shade100
    },
    {'name': 'Red', 'color': Colors.red, 'secondary': Colors.red.shade100},
    {'name': 'Teal', 'color': Colors.teal, 'secondary': Colors.teal.shade100},
  ];

  final List<String> _fontSizes = ['Small', 'Medium', 'Large', 'Extra Large'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Appearance'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Preview Card
            _buildThemePreviewCard(context),
            const SizedBox(height: 24),

            // Dark Mode Settings
            _buildSectionHeader(context, 'Display Mode', Icons.brightness_6),
            const SizedBox(height: 16),
            _buildDarkModeSettings(context),
            const SizedBox(height: 24),

            // Color Theme Settings
            _buildSectionHeader(context, 'Color Theme', Icons.palette),
            const SizedBox(height: 16),
            _buildColorThemeSettings(context),
            const SizedBox(height: 24),

            // Font Settings
            _buildSectionHeader(context, 'Text & Font', Icons.text_fields),
            const SizedBox(height: 16),
            _buildFontSettings(context),
            const SizedBox(height: 24),

            // Layout Settings
            _buildSectionHeader(context, 'Layout Options', Icons.view_quilt),
            const SizedBox(height: 16),
            _buildLayoutSettings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreviewCard(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = _themeColors
        .firstWhere((t) => t['name'] == _selectedTheme)['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            selectedColor.withOpacity(0.1),
            selectedColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selectedColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette,
                  color: selectedColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Preview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selectedColor,
                      ),
                    ),
                    Text(
                      '$_selectedTheme • ${_isDarkMode ? 'Dark' : 'Light'} Mode',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: selectedColor,
                  child: const Icon(Icons.business, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Invoice',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'PKR 12,500.00',
                        style: TextStyle(
                          color: selectedColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Paid',
                      style: TextStyle(color: Colors.green, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Use System Theme'),
            subtitle: const Text('Follow device dark/light mode setting'),
            value: _systemTheme,
            onChanged: (value) => setState(() => _systemTheme = value),
            secondary: const Icon(Icons.phone_android),
            contentPadding: EdgeInsets.zero,
          ),
          if (!_systemTheme) ...[
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
              secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorThemeSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Color Scheme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _themeColors.length,
            itemBuilder: (context, index) {
              final themeColor = _themeColors[index];
              final isSelected = _selectedTheme == themeColor['name'];

              return InkWell(
                onTap: () =>
                    setState(() => _selectedTheme = themeColor['name']),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? themeColor['color']
                          : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              themeColor['color'],
                              themeColor['secondary'],
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        themeColor['name'],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isSelected ? themeColor['color'] : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFontSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Font Size',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _fontSizes.map((size) {
              final isSelected = _selectedFontSize == size;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedFontSize = size),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: size,
                          groupValue: _selectedFontSize,
                          onChanged: (value) =>
                              setState(() => _selectedFontSize = value!),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          size,
                          style: TextStyle(
                            fontSize: _getFontSize(size),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Sample Text',
                          style: TextStyle(
                            fontSize: _getFontSize(size),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Compact Layout'),
            subtitle: const Text('Reduce spacing between elements'),
            value: false,
            onChanged: (value) {
              // TODO: Implement compact layout
            },
            secondary: const Icon(Icons.compress),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Show Animations'),
            subtitle: const Text('Enable smooth transitions'),
            value: true,
            onChanged: (value) {
              // TODO: Implement animation toggle
            },
            secondary: const Icon(Icons.animation),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('High Contrast'),
            subtitle: const Text('Improve visibility for accessibility'),
            value: false,
            onChanged: (value) {
              // TODO: Implement high contrast mode
            },
            secondary: const Icon(Icons.contrast),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  double _getFontSize(String size) {
    switch (size) {
      case 'Small':
        return 12.0;
      case 'Medium':
        return 14.0;
      case 'Large':
        return 16.0;
      case 'Extra Large':
        return 18.0;
      default:
        return 14.0;
    }
  }

  void _saveSettings() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
