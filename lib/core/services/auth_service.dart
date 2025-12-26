import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';

/// Service for managing user authentication state persistence
class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keySelectedCompanyId = 'selected_company_id';
  static const String _keySelectedCompanyName = 'selected_company_name';

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  /// Check if a user is currently logged in
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  /// Get the stored user ID
  int? get userId {
    final id = _prefs.getInt(_keyUserId);
    return id == 0 ? null : id;
  }

  /// Get the stored user email
  String? get userEmail => _prefs.getString(_keyUserEmail);

  /// Get the stored user full name
  String? get userFullName => _prefs.getString(_keyUserFullName);

  /// Get the stored company ID
  int? get selectedCompanyId {
    final id = _prefs.getInt(_keySelectedCompanyId);
    return id == 0 ? null : id;
  }

  /// Get the stored company name
  String? get selectedCompanyName => _prefs.getString(_keySelectedCompanyName);

  /// Check if a company has been selected
  bool get hasSelectedCompany => selectedCompanyId != null;

  /// Save user login state
  Future<bool> saveLoginState({
    required int userId,
    required String email,
    required String fullName,
  }) async {
    try {
      await _prefs.setBool(_keyIsLoggedIn, true);
      await _prefs.setInt(_keyUserId, userId);
      await _prefs.setString(_keyUserEmail, email);
      await _prefs.setString(_keyUserFullName, fullName);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all user login state
  Future<bool> logout() async {
    try {
      await _prefs.remove(_keyIsLoggedIn);
      await _prefs.remove(_keyUserId);
      await _prefs.remove(_keyUserEmail);
      await _prefs.remove(_keyUserFullName);
      await _prefs.remove(_keySelectedCompanyId);
      await _prefs.remove(_keySelectedCompanyName);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save selected company
  Future<bool> saveSelectedCompany({
    required int companyId,
    required String companyName,
  }) async {
    try {
      await _prefs.setInt(_keySelectedCompanyId, companyId);
      await _prefs.setString(_keySelectedCompanyName, companyName);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear selected company
  Future<bool> clearSelectedCompany() async {
    try {
      await _prefs.remove(_keySelectedCompanyId);
      await _prefs.remove(_keySelectedCompanyName);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get a User object from persisted state (if logged in)
  User? getPersistedUser() {
    if (!isLoggedIn) return null;

    final id = userId;
    final email = userEmail;
    final fullName = userFullName;

    if (id == null || email == null || fullName == null) {
      return null;
    }

    return User()
      ..id = id
      ..email = email
      ..fullName = fullName
      ..passwordHash = ''
      ..isActive = true;
  }
}
