/// Configuration for WhatsApp API integration
class WhatsAppConfig {
  /// API Base URL - Replace with your actual WhatsApp API endpoint
  /// Example: https://api.whatsapp.business, https://graph.facebook.com
  static const String apiBaseUrl =
      'https://api.whatsapp.business'; // Update this with your API endpoint

  /// API Key for WhatsApp Business API
  static const String apiKey =
      'sk_5fdb92a0e35fc302d65009777e79f76fbadb78e6591bc2d5b50bbc69c72cc71a';

  /// Default country code (for Pakistani numbers)
  static const String defaultCountryCode = '+92';

  /// Enable/disable API integration (fallback to direct WhatsApp opening if false)
  static const bool enableApiIntegration = true;

  /// Timeout for API requests (in seconds)
  static const int apiTimeoutSeconds = 30;
}
