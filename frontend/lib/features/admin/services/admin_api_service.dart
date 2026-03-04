import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';

/// API service for all admin operations.
class AdminApiService {
  final ApiClient _client;

  AdminApiService({required ApiClient client}) : _client = client;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  dynamic _unwrap(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  // ---------------------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------------------

  /// Admin login — returns the raw auth-response map (token, email, role, …)
  /// This does NOT use the interceptor token — it's an unauthenticated call.
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    final res = await dio.post('/admin/login', data: {
      'email': email,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // STATS
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getStats() async {
    final res = await _client.get('/admin/stats');
    return _unwrap(res) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // USERS
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> getAllUsers() async {
    final res = await _client.get('/admin/users');
    final data = _unwrap(res);
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> addUser({
    required String email,
    required String role,
    required int hallId,
  }) async {
    final res = await _client.post('/admin/add-user', data: {
      'email': email,
      'role': role,
      'hallId': hallId,
    });
    return _unwrap(res) as Map<String, dynamic>;
  }

  Future<void> deleteUser(String email) async {
    await _client.delete('/admin/user', queryParameters: {'email': email});
  }

  // ---------------------------------------------------------------------------
  // HALLS
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> getAllHalls() async {
    final res = await _client.get('/admin/halls');
    final data = _unwrap(res);
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> addHall(String name) async {
    final res = await _client.post('/admin/add-hall', data: {'name': name});
    return _unwrap(res) as Map<String, dynamic>;
  }

  Future<void> deleteHall(int hallId) async {
    await _client.delete('/admin/hall/$hallId');
  }
}
