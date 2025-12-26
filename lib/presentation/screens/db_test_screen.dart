import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatabaseTestScreen extends ConsumerWidget {
  const DatabaseTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isar DB Test')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature not yet available')),
                );
              },
              child: const Text('Insert Company'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text("Companies in DB"),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: Text('Feature not yet available'),
                    ),
                  ),
                );
              },
              child: const Text('View Companies'),
            ),
          ],
        ),
      ),
    );
  }
}
