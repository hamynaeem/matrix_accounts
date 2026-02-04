import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/whatsapp_service.dart';

/// Provider for WhatsApp service
final whatsappServiceProvider = Provider<WhatsAppService>((ref) {
  return WhatsAppService();
});

/// Provider to check if WhatsApp is available on the device
final whatsappAvailabilityProvider = FutureProvider<bool>((ref) async {
  final whatsappService = ref.read(whatsappServiceProvider);
  return await whatsappService.isWhatsAppInstalled();
});
