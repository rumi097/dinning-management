import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/services/service_locator.dart';
import '../models/credit_refund.dart';
import '../models/meal_availability.dart';
import '../models/meal_config.dart';
import '../models/meal_history.dart';
import '../models/credit_transaction.dart';

/// Service layer for all Meal Manager API calls.
///
/// Uses [ApiClient] (Dio) with automatic Bearer token injection.
/// All responses are wrapped in ApiResponse: { success, message, data }.
class MealManagerService {
  final ApiClient _apiClient;

  MealManagerService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ServiceLocator.apiClient;

  // ---------------------------------------------------------------------------
  // Wallet / Top‑up
  // ---------------------------------------------------------------------------

  /// POST /wallet/topup
  /// Returns true on success. Backend returns ApiResponse<StudentBalanceResponse>.
  Future<bool> topUpWallet({
    required String studentId,
    required double amount,
  }) async {
    try {
      final response = await _apiClient.post(
        '/wallet/topup',
        data: {
          'studentId': studentId,
          'amount': amount,
        },
      );
      final body = response.data as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      debugPrint('TopUpWallet error: $e');
      return false;
    }
  }

  /// GET /wallet/student/{studentId}
  /// Returns the student's current wallet balance.
  Future<double> getStudentBalance(String studentId) async {
    try {
      final response = await _apiClient.get('/wallet/student/$studentId');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        return (data['balance'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      debugPrint('GetStudentBalance error: $e');
      return 0.0;
    }
  }

  /// GET /wallet/history?date=YYYY-MM-DD
  /// Returns list of credit transactions for the given date.
  Future<List<CreditTransaction>> getWalletHistory(String date) async {
    try {
      final response = await _apiClient.get(
        '/wallet/history',
        queryParameters: {'date': date},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) =>
                CreditTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('GetWalletHistory error: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Meal Configuration
  // ---------------------------------------------------------------------------

  /// POST /meals/config — Create meal config for tomorrow.
  /// Backend expects SetMenuRequest: { mealType, menu, price, purchaseStartTime, purchaseEndTime }
  Future<bool> createMealConfig(MealConfig config) async {
    try {
      final response = await _apiClient.post(
        '/meals/config',
        data: _buildSetMenuRequest(config),
      );
      final body = response.data as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      debugPrint('CreateMealConfig error: $e');
      return false;
    }
  }

  /// PUT /meals/config/{id} — Update existing meal config.
  Future<bool> updateMealConfig(int id, MealConfig config) async {
    try {
      final response = await _apiClient.put(
        '/meals/config/$id',
        data: _buildSetMenuRequest(config),
      );
      final body = response.data as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      debugPrint('UpdateMealConfig error: $e');
      return false;
    }
  }

  /// GET /meals/config/tomorrow
  Future<List<MealConfig>> getTomorrowConfig() async {
    try {
      final response = await _apiClient.get('/meals/config/tomorrow');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) => MealConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('GetTomorrowConfig error: $e');
      return [];
    }
  }

  /// GET /meals/config/{date}
  Future<List<MealConfig>> getMealConfigByDate(String date) async {
    try {
      final response = await _apiClient.get('/meals/config/$date');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) => MealConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('GetMealConfigByDate error: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Meal Availability
  // ---------------------------------------------------------------------------

  /// GET /meals/availability/{date}
  Future<MealAvailability> getMealAvailability(String date) async {
    try {
      final response = await _apiClient.get('/meals/availability/$date');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        return MealAvailability.fromJson(body['data'] as Map<String, dynamic>);
      }
      return MealAvailability(date: date);
    } catch (e) {
      debugPrint('GetMealAvailability error: $e');
      return MealAvailability(date: date);
    }
  }

  /// PUT /meals/availability/{date}
  /// Backend expects MealAvailabilityRequest: { date, isLunchAvailable, isDinnerAvailable }
  Future<bool> updateMealAvailability(MealAvailability availability) async {
    try {
      final response = await _apiClient.put(
        '/meals/availability/${availability.date}',
        data: {
          'date': availability.date,
          'isLunchAvailable': availability.isLunchAvailable,
          'isDinnerAvailable': availability.isDinnerAvailable,
        },
      );
      final body = response.data as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      debugPrint('UpdateMealAvailability error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Reports / Dashboard Stats
  // ---------------------------------------------------------------------------

  /// GET /reports/sales?date=YYYY-MM-DD
  /// Backend returns SalesReportResponse with a list of MealSalesDetail.
  /// We extract lunch/dinner sold counts from the meals list.
  Future<Map<String, int>> getSalesReport(String date) async {
    try {
      final response = await _apiClient.get(
        '/reports/sales',
        queryParameters: {'date': date},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        final meals = data['meals'] as List<dynamic>? ?? [];
        int lunchSold = 0;
        int dinnerSold = 0;
        for (final meal in meals) {
          final m = meal as Map<String, dynamic>;
          final type = (m['mealType'] as String?)?.toUpperCase() ?? '';
          final sold = (m['tokensSold'] as num?)?.toInt() ?? 0;
          if (type == 'LUNCH') {
            lunchSold = sold;
          } else if (type == 'DINNER') {
            dinnerSold = sold;
          }
        }
        return {'lunchSold': lunchSold, 'dinnerSold': dinnerSold};
      }
      return {'lunchSold': 0, 'dinnerSold': 0};
    } catch (e) {
      debugPrint('GetSalesReport error: $e');
      return {'lunchSold': 0, 'dinnerSold': 0};
    }
  }

  /// GET /reports/sales?date=YYYY-MM-DD
  /// Extracts revenue per meal type from the SalesReportResponse.
  Future<Map<String, double>> getRevenueReport(String date) async {
    try {
      final response = await _apiClient.get(
        '/reports/sales',
        queryParameters: {'date': date},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        final meals = data['meals'] as List<dynamic>? ?? [];
        double lunchRevenue = 0.0;
        double dinnerRevenue = 0.0;
        for (final meal in meals) {
          final m = meal as Map<String, dynamic>;
          final type = (m['mealType'] as String?)?.toUpperCase() ?? '';
          final revenue = (m['revenue'] as num?)?.toDouble() ?? 0.0;
          if (type == 'LUNCH') {
            lunchRevenue = revenue;
          } else if (type == 'DINNER') {
            dinnerRevenue = revenue;
          }
        }
        return {
          'lunchRevenue': lunchRevenue,
          'dinnerRevenue': dinnerRevenue,
        };
      }
      return {'lunchRevenue': 0.0, 'dinnerRevenue': 0.0};
    } catch (e) {
      debugPrint('GetRevenueReport error: $e');
      return {'lunchRevenue': 0.0, 'dinnerRevenue': 0.0};
    }
  }

  /// GET /reports/wallet-topups?date=YYYY-MM-DD
  /// Backend returns WalletTopupReportResponse; we map topups to CreditTransaction.
  Future<List<CreditTransaction>> getWalletTopups(String date) async {
    try {
      final response = await _apiClient.get(
        '/reports/wallet-topups',
        queryParameters: {'date': date},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        final topups = data['topups'] as List<dynamic>? ?? [];
        return topups.map((e) {
          final t = e as Map<String, dynamic>;
          return CreditTransaction(
            id: (t['transactionId'] ?? '').toString(),
            studentId: (t['receiverId'] ?? '').toString(),
            studentName: t['receiverName'] as String? ?? '',
            amount: (t['amount'] as num?)?.toDouble() ?? 0.0,
            timestamp: t['createdAt'] != null
                ? DateTime.parse(t['createdAt'] as String)
                : DateTime.now(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('GetWalletTopups error: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Today's Dashboard Data (aggregated)
  // ---------------------------------------------------------------------------

  /// GET /dashboard
  /// Backend returns ApiResponse<DashboardResponse>.
  Future<DashboardData> getDashboardData() async {
    try {
      final response = await _apiClient.get('/dashboard');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        return DashboardData.fromJson(body['data'] as Map<String, dynamic>);
      }
      return const DashboardData(
        lunchCount: 0,
        dinnerCount: 0,
        lunchRevenue: 0,
        dinnerRevenue: 0,
        totalStudents: 0,
        todayTopUps: 0,
      );
    } catch (e) {
      debugPrint('GetDashboardData error: $e');
      return const DashboardData(
        lunchCount: 0,
        dinnerCount: 0,
        lunchRevenue: 0,
        dinnerRevenue: 0,
        totalStudents: 0,
        todayTopUps: 0,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------------

  /// GET /history/meals
  Future<List<DailyMealHistory>> getMealHistory() async {
    try {
      final response = await _apiClient.get('/history/meals');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) =>
                DailyMealHistory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('GetMealHistory error: $e');
      return [];
    }
  }

  /// GET /history/credits
  Future<List<DailyCreditHistory>> getCreditHistory() async {
    try {
      final response = await _apiClient.get('/history/credits');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) =>
                DailyCreditHistory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('GetCreditHistory error: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Credit Refund
  // ---------------------------------------------------------------------------

  /// GET /refunds/pending — Fetch cancelled meals eligible for refund.
  Future<List<RefundableMeal>> getRefundableMeals() async {
    try {
      final response = await _apiClient.get('/refunds/pending');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) =>
                RefundableMeal.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('GetRefundableMeals error: $e');
      return [];
    }
  }

  /// GET /refunds/summary — Get refund summary stats.
  Future<RefundSummary> getRefundSummary() async {
    try {
      final response = await _apiClient.get('/refunds/summary');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        return RefundSummary.fromJson(body['data'] as Map<String, dynamic>);
      }
      return const RefundSummary(
        pendingCount: 0,
        completedCount: 0,
        totalAmountPending: 0,
        totalAmountRefunded: 0,
      );
    } catch (e) {
      debugPrint('GetRefundSummary error: $e');
      return const RefundSummary(
        pendingCount: 0,
        completedCount: 0,
        totalAmountPending: 0,
        totalAmountRefunded: 0,
      );
    }
  }

  /// POST /refunds/process — Process refund for a single cancelled meal.
  Future<bool> processRefund(String mealId) async {
    try {
      final response = await _apiClient.post(
        '/refunds/process',
        data: {'mealId': mealId},
      );
      final body = response.data as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      debugPrint('ProcessRefund error: $e');
      return false;
    }
  }

  /// POST /refunds/process-bulk — Process refund for multiple cancelled meals.
  Future<bool> processBulkRefund(List<String> mealIds) async {
    try {
      final response = await _apiClient.post(
        '/refunds/process-bulk',
        data: {'mealIds': mealIds},
      );
      final body = response.data as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      debugPrint('ProcessBulkRefund error: $e');
      return false;
    }
  }

  /// GET /refunds/history — Fetch already-processed refunds.
  Future<List<RefundableMeal>> getRefundHistory() async {
    try {
      final response = await _apiClient.get('/refunds/history');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) =>
                RefundableMeal.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('GetRefundHistory error: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Helper: Build SetMenuRequest body from MealConfig
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _buildSetMenuRequest(MealConfig config) {
    return {
      'mealType': config.mealType.name.toUpperCase(), // LUNCH or DINNER
      'menu': config.menu,
      'price': config.price,
      if (config.purchaseDeadline != null)
        'purchaseEndTime': '${config.date}T${config.purchaseDeadline}:00',
    };
  }
}

/// Aggregated dashboard data for today.
class DashboardData {
  final int lunchCount;
  final int dinnerCount;
  final double lunchRevenue;
  final double dinnerRevenue;
  final int totalStudents;
  final int todayTopUps;

  final bool isLunchAvailable;
  final bool isDinnerAvailable;

  const DashboardData({
    required this.lunchCount,
    required this.dinnerCount,
    required this.lunchRevenue,
    required this.dinnerRevenue,
    required this.totalStudents,
    required this.todayTopUps,
    this.isLunchAvailable = true,
    this.isDinnerAvailable = true,
  });

  int get totalMeals => lunchCount + dinnerCount;
  double get totalRevenue => lunchRevenue + dinnerRevenue;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      lunchCount: (json['lunchCount'] as num?)?.toInt() ?? 0,
      dinnerCount: (json['dinnerCount'] as num?)?.toInt() ?? 0,
      lunchRevenue: (json['lunchRevenue'] as num?)?.toDouble() ?? 0.0,
      dinnerRevenue: (json['dinnerRevenue'] as num?)?.toDouble() ?? 0.0,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      todayTopUps: (json['todayTopUps'] as num?)?.toInt() ?? 0,
      isLunchAvailable: json['isLunchAvailable'] as bool? ?? true,
      isDinnerAvailable: json['isDinnerAvailable'] as bool? ?? true,
    );
  }
}
