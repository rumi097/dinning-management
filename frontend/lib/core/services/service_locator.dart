import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/features/auth/services/auth_service.dart';

/// Global service locator for initialization
class ServiceLocator {
  static late TokenStorage _tokenStorage;
  static late ApiClient _apiClient;
  static late AuthService _authService;

  /// Initialize all services
  static Future<void> init() async {
    // TokenStorage will initialize SharedPreferences on native platforms
    // On web, it will fail gracefully and return null for stored values
    _tokenStorage = TokenStorage();
    await _tokenStorage.init();

    _apiClient = ApiClient(tokenStorage: _tokenStorage);
    _authService = AuthService(
      apiClient: _apiClient,
      tokenStorage: _tokenStorage,
    );
  }

  /// Get initialized TokenStorage
  static TokenStorage get tokenStorage => _tokenStorage;

  /// Get initialized ApiClient
  static ApiClient get apiClient => _apiClient;

  /// Get initialized AuthService
  static AuthService get authService => _authService;
}
