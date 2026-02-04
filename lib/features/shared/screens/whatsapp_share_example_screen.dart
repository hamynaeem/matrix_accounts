// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/providers/whatsapp_provider.dart';
// import '../../../core/widgets/whatsapp_share_widgets.dart';

// /// Example screen showing how to use WhatsApp sharing functionality
// class WhatsAppShareExampleScreen extends ConsumerWidget {
//   const WhatsAppShareExampleScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final whatsappService = ref.read(whatsappServiceProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('WhatsApp Sharing Examples'),
//         backgroundColor: const Color(0xFF25D366),
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Basic text sharing
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Basic Text Sharing',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     WhatsAppShareButton(
//                       text:
//                           'Hello from Matrix Accounts! 📊\n\nThis is a sample message shared from our accounting app.',
//                       buttonText: 'Share Message',
//                       icon: Icons.message,
//                       onSuccess: () {
//                         _showSuccessMessage(
//                             context, 'Message shared successfully!');
//                       },
//                       onError: () {
//                         _showErrorMessage(context, 'Failed to share message');
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Share to specific contact
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Share to Specific Contact',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     WhatsAppShareButton(
//                       text:
//                           'Hi! I\'d like to share some account details with you.',
//                       phoneNumber: '+1234567890', // Replace with actual number
//                       buttonText: 'Share to Contact',
//                       icon: Icons.person,
//                       onSuccess: () {
//                         _showSuccessMessage(
//                             context, 'Shared to contact successfully!');
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Share business card
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Share Business Information',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         final success = await whatsappService.shareBusinessCard(
//                           contactName: 'Matrix Accounts',
//                           phoneNumber: '+1-234-567-8900',
//                           email: 'info@matrixaccounts.com',
//                           organization: 'Matrix Accounts Solutions',
//                         );

//                         if (success) {
//                           _showSuccessMessage(context, 'Business card shared!');
//                         } else {
//                           _showErrorMessage(
//                               context, 'Failed to share business card');
//                         }
//                       },
//                       icon: const Icon(Icons.business_center),
//                       label: const Text('Share Business Card'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF25D366),
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Share invoice information
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Share Invoice Details',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         final success = await whatsappService.shareInvoice(
//                           invoiceNumber: 'INV-2026-001',
//                           amount: 1250.50,
//                           currency: '\$',
//                           customerName: 'ABC Company Ltd.',
//                           additionalDetails:
//                               'Payment due within 30 days\nThank you for your business!',
//                         );

//                         if (success) {
//                           _showSuccessMessage(
//                               context, 'Invoice details shared!');
//                         } else {
//                           _showErrorMessage(context, 'Failed to share invoice');
//                         }
//                       },
//                       icon: const Icon(Icons.receipt),
//                       label: const Text('Share Sample Invoice'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF25D366),
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const Spacer(),

//             // WhatsApp availability check
//             Consumer(
//               builder: (context, ref, child) {
//                 final whatsappAvailability =
//                     ref.watch(whatsappAvailabilityProvider);

//                 return whatsappAvailability.when(
//                   data: (isAvailable) => Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: isAvailable
//                           ? Colors.green.shade100
//                           : Colors.orange.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           isAvailable ? Icons.check_circle : Icons.info,
//                           color: isAvailable ? Colors.green : Colors.orange,
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             isAvailable
//                                 ? 'WhatsApp is available on this device'
//                                 : 'WhatsApp may not be available. Sharing will use system share dialog.',
//                             style: TextStyle(
//                               color: isAvailable
//                                   ? Colors.green.shade800
//                                   : Colors.orange.shade800,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   loading: () => const LinearProgressIndicator(),
//                   error: (error, stackTrace) => Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Error checking WhatsApp availability: $error',
//                       style: TextStyle(color: Colors.red.shade800),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: WhatsAppShareFAB(
//         text: 'Quick share from Matrix Accounts! 🚀',
//         onSuccess: () {
//           _showSuccessMessage(context, 'Quick share successful!');
//         },
//         onError: () {
//           _showErrorMessage(context, 'Quick share failed');
//         },
//       ),
//     );
//   }

//   void _showSuccessMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showErrorMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
// }
