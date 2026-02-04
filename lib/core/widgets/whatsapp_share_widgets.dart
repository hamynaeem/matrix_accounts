// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/whatsapp_provider.dart';

// /// A reusable widget for WhatsApp sharing functionality
// class WhatsAppShareButton extends ConsumerWidget {
//   final String text;
//   final String? phoneNumber;
//   final String? buttonText;
//   final IconData? icon;
//   final Color? color;
//   final VoidCallback? onSuccess;
//   final VoidCallback? onError;

//   const WhatsAppShareButton({
//     super.key,
//     required this.text,
//     this.phoneNumber,
//     this.buttonText,
//     this.icon,
//     this.color,
//     this.onSuccess,
//     this.onError,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final whatsappService = ref.read(whatsappServiceProvider);

//     return ElevatedButton.icon(
//       onPressed: () async {
//         try {
//           bool success;
//           if (phoneNumber != null && phoneNumber!.isNotEmpty) {
//             success = await whatsappService.shareToContact(text, phoneNumber!);
//           } else {
//             success = await whatsappService.shareText(text);
//           }

//           if (success) {
//             onSuccess?.call();
//           } else {
//             onError?.call();
//             if (context.mounted) {
//               _showErrorMessage(context, 'Failed to share to WhatsApp');
//             }
//           }
//         } catch (e) {
//           onError?.call();
//           if (context.mounted) {
//             _showErrorMessage(context, 'Error sharing to WhatsApp: $e');
//           }
//         }
//       },
//       icon: Icon(icon ?? Icons.share),
//       label: Text(buttonText ?? 'Share to WhatsApp'),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color ?? const Color(0xFF25D366), // WhatsApp green
//         foregroundColor: Colors.white,
//       ),
//     );
//   }

//   void _showErrorMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }

// /// A widget for sharing files to WhatsApp
// class WhatsAppFileShareButton extends ConsumerWidget {
//   final String filePath;
//   final String? text;
//   final String? buttonText;
//   final IconData? icon;
//   final Color? color;
//   final VoidCallback? onSuccess;
//   final VoidCallback? onError;

//   const WhatsAppFileShareButton({
//     super.key,
//     required this.filePath,
//     this.text,
//     this.buttonText,
//     this.icon,
//     this.color,
//     this.onSuccess,
//     this.onError,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final whatsappService = ref.read(whatsappServiceProvider);

//     return ElevatedButton.icon(
//       onPressed: () async {
//         try {
//           final success = await whatsappService.shareFile(filePath, text: text);

//           if (success) {
//             onSuccess?.call();
//           } else {
//             onError?.call();
//             if (context.mounted) {
//               _showErrorMessage(context, 'Failed to share file to WhatsApp');
//             }
//           }
//         } catch (e) {
//           onError?.call();
//           if (context.mounted) {
//             _showErrorMessage(context, 'Error sharing file to WhatsApp: $e');
//           }
//         }
//       },
//       icon: Icon(icon ?? Icons.attach_file),
//       label: Text(buttonText ?? 'Share File to WhatsApp'),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color ?? const Color(0xFF25D366), // WhatsApp green
//         foregroundColor: Colors.white,
//       ),
//     );
//   }

//   void _showErrorMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }

// /// A floating action button for WhatsApp sharing
// class WhatsAppShareFAB extends ConsumerWidget {
//   final String text;
//   final String? phoneNumber;
//   final VoidCallback? onSuccess;
//   final VoidCallback? onError;

//   const WhatsAppShareFAB({
//     super.key,
//     required this.text,
//     this.phoneNumber,
//     this.onSuccess,
//     this.onError,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final whatsappService = ref.read(whatsappServiceProvider);

//     return FloatingActionButton(
//       onPressed: () async {
//         try {
//           bool success;
//           if (phoneNumber != null && phoneNumber!.isNotEmpty) {
//             success = await whatsappService.shareToContact(text, phoneNumber!);
//           } else {
//             success = await whatsappService.shareText(text);
//           }

//           if (success) {
//             onSuccess?.call();
//           } else {
//             onError?.call();
//           }
//         } catch (e) {
//           onError?.call();
//         }
//       },
//       backgroundColor: const Color(0xFF25D366), // WhatsApp green
//       child: const Icon(Icons.share, color: Colors.white),
//     );
//   }
// }
