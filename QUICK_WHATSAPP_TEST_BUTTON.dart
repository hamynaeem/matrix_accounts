// Add this temporary button to your main app for testing
// You can add this in main.dart or any existing screen

import 'package:flutter/material.dart';
import 'lib/features/shared/screens/whatsapp_quick_test_screen.dart';

// Function to create the WhatsApp test button
Widget buildWhatsAppTestButton(BuildContext context) {
  return FloatingActionButton.extended(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WhatsAppQuickTestScreen(),
        ), 
      );
    },
    icon: const Icon(Icons.chat, color: Colors.white),
    label: const Text('Test WhatsApp', style: TextStyle(color: Colors.white)),
    backgroundColor: Colors.green,
  );
}