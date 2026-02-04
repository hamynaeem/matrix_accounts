class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://127.0.0.1:8000';
  
  // Sync Configuration
  static const Duration syncInterval = Duration(minutes: 5);
  static const bool autoSync = false;
  
  // App Configuration
  static const String appName = 'Matrix Accounts';
  static const String appVersion = '1.0.0';
}
