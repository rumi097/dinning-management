import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/dining_manager/models/meal_stats.dart';

/// API service for Dining Manager operations.
class DiningManagerService {
  final ApiClient _apiClient;

  DiningManagerService({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Get today's meal stats (total/used/remaining) for the manager's hall.
  Future<List<MealStats>> getTodayMealStats() async {
    try {
      final response = await _apiClient.get('/tokens/meal-stats');
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => MealStats.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Validate a QR code string scanned from a student's token.
  Future<QrValidationResult> validateQr(String qrData) async {
    try {
      final response = await _apiClient.post(
        '/tokens/validate-qr',
        data: {'qrData': qrData},
      );
      final data = response.data as Map<String, dynamic>;
      return QrValidationResult.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Mark a token as USED after successful validation.
  Future<void> markTokenUsed(int tokenId) async {
    try {
      await _apiClient.post('/tokens/$tokenId/mark-used');
    } on DioException {
      rethrow;
    }
  }
}
