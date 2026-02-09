// import 'package:flutter/material.dart';
// import '../../../core/services/whatsapp_service.dart';

// /// A simple test widget to verify WhatsApp functionality
// /// This can be added temporarily to any screen for testing
// class WhatsAppTestWidget extends StatelessWidget {
//   const WhatsAppTestWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'WhatsApp Test Functions',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 16),

//             // Test basic WhatsApp sharing
//             ElevatedButton.icon(
//               onPressed: () async {
//                 final whatsappService = WhatsAppService();
//                 final success = await whatsappService.shareText(
//                   'Hello! This is a test message from Matrix Accounts app.\n\n'
//                   '✅ WhatsApp integration is working correctly!',
//                 );

//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(success
//                           ? '✅ WhatsApp test completed successfully!'
//                           : '❌ WhatsApp test failed'),
//                       backgroundColor: success ? Colors.green : Colors.red,
//                     ),
//                   );
//                 }
//               },
//               icon: const Icon(Icons.message),
//               label: const Text('Test General Share'),
//             ),

//             const SizedBox(height: 8),

//             // Test WhatsApp with phone number
//             ElevatedButton.icon(
//               onPressed: () async {
//                 final whatsappService = WhatsAppService();
//                 final success = await whatsappService.shareText(
//                   'Hello! This is a test message with phone number from Matrix Accounts.\n\n'
//                   '📱 Direct chat functionality is working!\n'
//                   '✅ Message should appear in your chat ready to send.',
//                   phoneNumber: '+923001234567', // Example Pakistani number
//                 );

//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(success
//                           ? '✅ WhatsApp direct chat test completed!'
//                           : '❌ WhatsApp direct chat test failed'),
//                       backgroundColor: success ? Colors.green : Colors.red,
//                     ),
//                   );
//                 }
//               },
//               icon: const Icon(Icons.phone),
//               label: const Text('Test Direct Chat'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green.shade600,
//                 foregroundColor: Colors.white,
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Test invoice sharing
//             ElevatedButton.icon(
//               onPressed: () async {
//                 final whatsappService = WhatsAppService();
//                 final success = await whatsappService.shareInvoice(
//                   invoiceNumber: 'TEST-001',
//                   amount: 1250.00,
//                   currency: 'Rs',
//                   customerName: 'Test Customer',
//                   customerPhone: '+923001234567',
//                   invoiceType: 'Test Invoice',
//                   additionalDetails:
//                       'Date: ${DateTime.now().toString().split(' ')[0]}\nTest invoice for WhatsApp functionality',
//                 );

//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(success
//                           ? '✅ Invoice sharing test completed!'
//                           : '❌ Invoice sharing test failed'),
//                       backgroundColor: success ? Colors.green : Colors.red,
//                     ),
//                   );
//                 }
//               },
//               icon: const Icon(Icons.receipt),
//               label: const Text('Test Invoice Share'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue.shade600,
//                 foregroundColor: Colors.white,
//               ),
//             ),

//             const SizedBox(height: 12),

//             Text(
//               'Note: Make sure WhatsApp is installed on your device for testing.',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Colors.grey.shade600,
//                     fontStyle: FontStyle.italic,
//                   ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
