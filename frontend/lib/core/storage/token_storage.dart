import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'user_role';

  late SharedPreferences? _prefs;

  /// Initialize the SharedPreferences
  /// On web, this will fail gracefully (SharedPreferences not supported)
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // SharedPreferences not available on web or in some environments
      // App will handle this gracefully - isLoggedIn() will return false
      debugPrint('TokenStorage init failed: $e');
    }
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    if (_prefs == null) return; // Skip on web/unsupported platforms
    await _prefs!.setString(_tokenKey, token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    if (_prefs == null) return null; // Return null on web/unsupported platforms
    return _prefs!.getString(_tokenKey);
  }

  /// Save user email
  Future<void> saveEmail(String email) async {
    if (_prefs == null) return;
    await _prefs!.setString(_emailKey, email);
  }

  /// Get user email
  Future<String?> getEmail() async {
    if (_prefs == null) return null;
    return _prefs!.getString(_emailKey);
  }

  /// Save user ID
  Future<void> saveUserId(int userId) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_userIdKey, userId);
  }

  /// Get user ID
  Future<int?> getUserId() async {
    if (_prefs == null) return null;
    return _prefs!.getInt(_userIdKey);
  }

  /// Save user role
  Future<void> saveRole(String role) async {
    if (_prefs == null) return;
    await _prefs!.setString(_roleKey, role);
  }

  /// Get user role
  Future<String?> getRole() async {
    if (_prefs == null) return null;
    return _prefs!.getString(_roleKey);
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    if (_prefs == null) return;
    await _prefs!.clear();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
