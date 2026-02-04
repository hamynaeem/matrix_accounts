import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling biometric authentication and app lock functionality
class BiometricService {
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyAppLocked = 'app_locked';
  static const String _keyLockTime = 'lock_time';
  static const String _keyAutoLockDuration = 'auto_lock_duration';

  final LocalAuthentication _localAuth;
  final SharedPreferences _prefs;

  BiometricService(this._localAuth, this._prefs);

  /// Check if biometric authentication is available on the device
  Future<bool> get isDeviceSupported => _localAuth.isDeviceSupported();

  /// Check if biometrics are available (device supports and user has enrolled)
  Future<bool> get canCheckBiometrics => _localAuth.canCheckBiometrics;

  /// Get available biometric types
  Future<List<BiometricType>> get availableBiometrics =>
      _localAuth.getAvailableBiometrics();

  /// Check if biometric authentication is enabled in app settings
  bool get isBiometricEnabled => _prefs.getBool(_keyBiometricEnabled) ?? false;

  /// Check if the app is currently locked
  bool get isAppLocked => _prefs.getBool(_keyAppLocked) ?? false;

  /// Get auto-lock duration in minutes (0 = disabled, -1 = immediate)
  int get autoLockDuration => _prefs.getInt(_keyAutoLockDuration) ?? 5;

  /// Enable or disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      if (enabled) {
        // Test biometric authentication before enabling
        final isAuthenticated = await authenticateUser(
          reason: 'Enable biometric authentication for app security',
        );
        if (!isAuthenticated) return false;
      }

      return await _prefs.setBool(_keyBiometricEnabled, enabled);
    } catch (e) {
      return false;
    }
  }

  /// Set auto-lock duration in minutes
  Future<bool> setAutoLockDuration(int minutes) async {
    return await _prefs.setInt(_keyAutoLockDuration, minutes);
  }

  /// Lock the application
  Future<bool> lockApp() async {
    final success = await _prefs.setBool(_keyAppLocked, true);
    if (success) {
      await _prefs.setInt(_keyLockTime, DateTime.now().millisecondsSinceEpoch);
    }
    return success;
  }

  /// Unlock the application
  Future<bool> unlockApp() async {
    final success = await _prefs.setBool(_keyAppLocked, false);
    if (success) {
      await _prefs.remove(_keyLockTime);
    }
    return success;
  }

  /// Check if app should auto-lock based on background time
  bool shouldAutoLock() {
    if (autoLockDuration <= 0 || !isBiometricEnabled) return false;

    final lockTime = _prefs.getInt(_keyLockTime);
    if (lockTime == null) return false;

    final lastActiveTime = DateTime.fromMillisecondsSinceEpoch(lockTime);
    final now = DateTime.now();
    final timeDifference = now.difference(lastActiveTime);

    return timeDifference.inMinutes >= autoLockDuration;
  }

  /// Authenticate user with biometrics
  Future<bool> authenticateUser({
    String? reason,
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
  }) async {
    try {
      if (!await canCheckBiometrics) return false;

      final availableBiometrics = await this.availableBiometrics;
      if (availableBiometrics.isEmpty) return false;

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason ?? 'Authenticate to access the application',
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      print('BiometricService authentication error: $e');
      return false;
    } catch (e) {
      print('BiometricService error: $e');
      return false;
    }
  }

  /// Get biometric capability description for UI
  Future<String> getBiometricCapabilityDescription() async {
    try {
      final isSupported = await isDeviceSupported;
      if (!isSupported) {
        return 'Biometric authentication is not supported on this device';
      }

      final canCheck = await canCheckBiometrics;
      if (!canCheck) return 'No biometric authentication methods are available';

      final availableBiometrics = await this.availableBiometrics;
      if (availableBiometrics.isEmpty) {
        return 'Please set up fingerprint, face recognition, or other biometric authentication in your device settings';
      }

      final List<String> types = [];
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        types.add('Fingerprint');
      }
      if (availableBiometrics.contains(BiometricType.face)) {
        types.add('Face Recognition');
      }
      if (availableBiometrics.contains(BiometricType.iris)) {
        types.add('Iris Scanner');
      }
      if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak)) {
        types.add('Device Authentication');
      }

      if (types.isNotEmpty) {
        return 'Available: ${types.join(', ')}';
      }

      return 'Biometric authentication is available';
    } catch (e) {
      return 'Unable to check biometric capabilities';
    }
  }

  /// Update last activity time (call when app becomes active)
  Future<void> updateLastActiveTime() async {
    await _prefs.setInt(_keyLockTime, DateTime.now().millisecondsSinceEpoch);
  }
}
