import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/credit_refund.dart';
import '../models/meal_availability.dart';
import '../models/meal_config.dart';
import '../models/meal_history.dart';
import '../models/credit_transaction.dart';

/// Service layer for all Meal Manager API calls.
///
/// Currently returns mock data. Replace the method bodies with real HTTP
/// calls (e.g. using http or dio package) once the backend is ready.
///
/// Base URL: /api/v1
class MealManagerService {
  // TODO: Replace with your actual base URL
  static const String _baseUrl = 'http://localhost:8080/api/v1';

  // ---------------------------------------------------------------------------
  // Wallet / Top‑up
  // ---------------------------------------------------------------------------

  /// POST /wallet/topup
  Future<bool> topUpWallet({
    required String studentId,
    required double amount,
  }) async {
    // TODO: Replace with real API call
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/wallet/topup'),
    //   headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    //   body: jsonEncode({'studentId': studentId, 'amount': amount}),
    // );
    // return response.statusCode == 200;
    await Future.delayed(const Duration(milliseconds: 800));
    debugPrint('TopUp: studentId=$studentId, amount=$amount');
    return true;
  }

  /// GET /wallet/student/{studentId}
  Future<double> getStudentBalance(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock balance
    return 250.00;
  }

  /// GET /wallet/history?date=YYYY-MM-DD
  Future<List<CreditTransaction>> getWalletHistory(String date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockCreditTransactions;
  }

  // ---------------------------------------------------------------------------
  // Meal Configuration
  // ---------------------------------------------------------------------------

  /// POST /meals/config — Create meal config for tomorrow
  Future<bool> createMealConfig(MealConfig config) async {
    await Future.delayed(const Duration(milliseconds: 800));
    debugPrint('CreateMealConfig: ${jsonEncode(config.toJson())}');
    return true;
  }

  /// PUT /meals/config/{id} — Update existing meal config
  Future<bool> updateMealConfig(int id, MealConfig config) async {
    await Future.delayed(const Duration(milliseconds: 800));
    debugPrint('UpdateMealConfig[$id]: ${jsonEncode(config.toJson())}');
    return true;
  }

  /// GET /meals/config/tomorrow
  Future<List<MealConfig>> getTomorrowConfig() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dateStr =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    return [
      MealConfig(
        id: 1,
        date: dateStr,
        mealType: MealType.lunch,
        price: 55.0,
        menu: 'Rice, Dal, Fish Curry, Salad',
        purchaseDeadline: '22:00',
      ),
      MealConfig(
        id: 2,
        date: dateStr,
        mealType: MealType.dinner,
        price: 65.0,
        menu: 'Rice, Chicken Curry, Vegetables, Dessert',
        purchaseDeadline: '15:00',
      ),
    ];
  }

  /// GET /meals/config/{date}
  Future<List<MealConfig>> getMealConfigByDate(String date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      MealConfig(
        id: 1,
        date: date,
        mealType: MealType.lunch,
        price: 55.0,
        menu: 'Rice, Dal, Fish Curry, Salad',
        purchaseDeadline: '22:00',
      ),
      MealConfig(
        id: 2,
        date: date,
        mealType: MealType.dinner,
        price: 65.0,
        menu: 'Rice, Chicken Curry, Vegetables, Dessert',
        purchaseDeadline: '15:00',
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Meal Availability
  // ---------------------------------------------------------------------------

  /// GET /meals/availability/{date}
  Future<MealAvailability> getMealAvailability(String date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: return default availability
    return MealAvailability(
      date: date,
      isMealAvailable: true,
      isLunchAvailable: true,
      isDinnerAvailable: true,
    );
  }

  /// PUT /meals/availability/{date}
  Future<bool> updateMealAvailability(MealAvailability availability) async {
    await Future.delayed(const Duration(milliseconds: 800));
    debugPrint(
        'UpdateMealAvailability: ${jsonEncode(availability.toJson())}');
    return true;
  }

  // ---------------------------------------------------------------------------
  // Reports / Dashboard Stats
  // ---------------------------------------------------------------------------

  /// GET /reports/sales?date=YYYY-MM-DD
  Future<Map<String, int>> getSalesReport(String date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'lunchSold': 142, 'dinnerSold': 98};
  }

  /// GET /reports/revenue?date=YYYY-MM-DD
  Future<Map<String, double>> getRevenueReport(String date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'lunchRevenue': 7810.0, 'dinnerRevenue': 6370.0};
  }

  /// GET /reports/wallet-topups?date=YYYY-MM-DD
  Future<List<CreditTransaction>> getWalletTopups(String date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockCreditTransactions;
  }

  // ---------------------------------------------------------------------------
  // Today's Dashboard Data (aggregated)
  // ---------------------------------------------------------------------------

  Future<DashboardData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return DashboardData(
      lunchCount: 142,
      dinnerCount: 98,
      lunchRevenue: 7810.0,
      dinnerRevenue: 6370.0,
      totalStudents: 380,
      todayTopUps: 12,
      isLunchAvailable: true,
      isDinnerAvailable: true,
    );
  }

  // ---------------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------------

  Future<List<DailyMealHistory>> getMealHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockMealHistory;
  }

  Future<List<DailyCreditHistory>> getCreditHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockCreditHistory;
  }

  // ---------------------------------------------------------------------------
  // Credit Refund
  // ---------------------------------------------------------------------------

  /// GET /refunds/pending — Fetch cancelled meals eligible for refund
  Future<List<RefundableMeal>> getRefundableMeals() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockRefundableMeals;
  }

  /// GET /refunds/summary — Get refund summary stats
  Future<RefundSummary> getRefundSummary() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const RefundSummary(
      pendingCount: 3,
      completedCount: 5,
      totalAmountPending: 15950.0,
      totalAmountRefunded: 28400.0,
    );
  }

  /// POST /refunds/process — Process refund for a single cancelled meal
  Future<bool> processRefund(String mealId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    debugPrint('ProcessRefund: mealId=$mealId');
    return true;
  }

  /// POST /refunds/process-bulk — Process refund for multiple cancelled meals
  Future<bool> processBulkRefund(List<String> mealIds) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    debugPrint('ProcessBulkRefund: mealIds=$mealIds');
    return true;
  }

  /// GET /refunds/history — Fetch already-processed refunds
  Future<List<RefundableMeal>> getRefundHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockRefundHistory;
  }

  // ---------------------------------------------------------------------------
  // Mock Data
  // ---------------------------------------------------------------------------

  static final List<CreditTransaction> _mockCreditTransactions = [
    CreditTransaction(
      id: '1',
      studentId: 'S2021001',
      studentName: 'Rahim Uddin',
      amount: 500.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CreditTransaction(
      id: '2',
      studentId: 'S2021045',
      studentName: 'Fatima Akter',
      amount: 750.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CreditTransaction(
      id: '3',
      studentId: 'S2021112',
      studentName: 'Karim Hasan',
      amount: 1000.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final List<DailyMealHistory> _mockMealHistory = [
    const DailyMealHistory(
      date: 'March 1, 2026',
      lunchCount: 142,
      dinnerCount: 98,
      lunchPrice: 55.0,
      dinnerPrice: 65.0,
    ),
    const DailyMealHistory(
      date: 'February 28, 2026',
      lunchCount: 156,
      dinnerCount: 112,
      lunchPrice: 55.0,
      dinnerPrice: 65.0,
    ),
    const DailyMealHistory(
      date: 'February 27, 2026',
      lunchCount: 138,
      dinnerCount: 95,
      lunchPrice: 55.0,
      dinnerPrice: 65.0,
    ),
    const DailyMealHistory(
      date: 'February 26, 2026',
      lunchCount: 145,
      dinnerCount: 103,
      lunchPrice: 55.0,
      dinnerPrice: 65.0,
    ),
    const DailyMealHistory(
      date: 'February 25, 2026',
      lunchCount: 151,
      dinnerCount: 107,
      lunchPrice: 55.0,
      dinnerPrice: 65.0,
    ),
  ];

  static final List<DailyCreditHistory> _mockCreditHistory = [
    DailyCreditHistory(
      date: 'March 1, 2026',
      transactions: const [
        CreditTransactionSummary(
            id: '1',
            studentId: 'S2021001',
            studentName: 'Rahim Uddin',
            amount: 500.0,
            time: '10:30 AM'),
        CreditTransactionSummary(
            id: '2',
            studentId: 'S2021045',
            studentName: 'Fatima Akter',
            amount: 750.0,
            time: '11:15 AM'),
        CreditTransactionSummary(
            id: '3',
            studentId: 'S2021112',
            studentName: 'Karim Hasan',
            amount: 1000.0,
            time: '02:45 PM'),
      ],
    ),
    DailyCreditHistory(
      date: 'February 28, 2026',
      transactions: const [
        CreditTransactionSummary(
            id: '4',
            studentId: 'S2021078',
            studentName: 'Nusrat Jahan',
            amount: 600.0,
            time: '09:20 AM'),
        CreditTransactionSummary(
            id: '5',
            studentId: 'S2021023',
            studentName: 'Tanvir Ahmed',
            amount: 800.0,
            time: '01:30 PM'),
        CreditTransactionSummary(
            id: '6',
            studentId: 'S2021056',
            studentName: 'Sumaiya Islam',
            amount: 550.0,
            time: '03:15 PM'),
        CreditTransactionSummary(
            id: '7',
            studentId: 'S2021089',
            studentName: 'Imran Khan',
            amount: 900.0,
            time: '04:00 PM'),
      ],
    ),
    DailyCreditHistory(
      date: 'February 27, 2026',
      transactions: const [
        CreditTransactionSummary(
            id: '8',
            studentId: 'S2021034',
            studentName: 'Ayesha Siddiqua',
            amount: 700.0,
            time: '10:00 AM'),
        CreditTransactionSummary(
            id: '9',
            studentId: 'S2021067',
            studentName: 'Mehedi Hasan',
            amount: 650.0,
            time: '12:30 PM'),
      ],
    ),
  ];
  // ── Refundable meals mock data ──

  static final List<RefundableMeal> _mockRefundableMeals = [
    RefundableMeal(
      id: 'R001',
      date: '2026-03-05',
      mealType: MealType.lunch,
      tokensSold: 87,
      pricePerToken: 55.0,
      totalRefundAmount: 4785.0,
      students: const [
        StudentToken(
          studentId: 'S2021001',
          studentName: 'Rahim Uddin',
          studentRoll: '2021-001',
          amountPaid: 55.0,
        ),
        StudentToken(
          studentId: 'S2021045',
          studentName: 'Fatima Akter',
          studentRoll: '2021-045',
          amountPaid: 55.0,
        ),
        StudentToken(
          studentId: 'S2021112',
          studentName: 'Karim Hasan',
          studentRoll: '2021-112',
          amountPaid: 55.0,
        ),
      ],
      status: RefundStatus.pending,
    ),
    RefundableMeal(
      id: 'R002',
      date: '2026-03-05',
      mealType: MealType.dinner,
      tokensSold: 62,
      pricePerToken: 65.0,
      totalRefundAmount: 4030.0,
      students: const [
        StudentToken(
          studentId: 'S2021078',
          studentName: 'Nusrat Jahan',
          studentRoll: '2021-078',
          amountPaid: 65.0,
        ),
        StudentToken(
          studentId: 'S2021023',
          studentName: 'Tanvir Ahmed',
          studentRoll: '2021-023',
          amountPaid: 65.0,
        ),
      ],
      status: RefundStatus.pending,
    ),
    RefundableMeal(
      id: 'R003',
      date: '2026-03-08',
      mealType: MealType.lunch,
      tokensSold: 109,
      pricePerToken: 55.0,
      totalRefundAmount: 5995.0,
      students: const [
        StudentToken(
          studentId: 'S2021034',
          studentName: 'Ayesha Siddiqua',
          studentRoll: '2021-034',
          amountPaid: 55.0,
        ),
      ],
      status: RefundStatus.pending,
    ),
  ];

  static final List<RefundableMeal> _mockRefundHistory = [
    RefundableMeal(
      id: 'R100',
      date: '2026-02-20',
      mealType: MealType.lunch,
      tokensSold: 95,
      pricePerToken: 55.0,
      totalRefundAmount: 5225.0,
      students: const [],
      status: RefundStatus.completed,
      refundedAt: null,
    ),
    RefundableMeal(
      id: 'R101',
      date: '2026-02-20',
      mealType: MealType.dinner,
      tokensSold: 78,
      pricePerToken: 65.0,
      totalRefundAmount: 5070.0,
      students: const [],
      status: RefundStatus.completed,
      refundedAt: null,
    ),
  ];
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
}