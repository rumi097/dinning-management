import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'user_role';

  late SharedPreferences _prefs;

  /// Initialize the SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  /// Save user email
  Future<void> saveEmail(String email) async {
    await _prefs.setString(_emailKey, email);
  }

  /// Get user email
  Future<String?> getEmail() async {
    return _prefs.getString(_emailKey);
  }

  /// Save user ID
  Future<void> saveUserId(int userId) async {
    await _prefs.setInt(_userIdKey, userId);
  }

  /// Get user ID
  Future<int?> getUserId() async {
    return _prefs.getInt(_userIdKey);
  }

  /// Save user role
  Future<void> saveRole(String role) async {
    await _prefs.setString(_roleKey, role);
  }

  /// Get user role
  Future<String?> getRole() async {
    return _prefs.getString(_roleKey);
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
