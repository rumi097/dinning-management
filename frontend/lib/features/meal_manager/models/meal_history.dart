/// Aggregated meal history for a single day.
class DailyMealHistory {
  final String date;
  final int lunchCount;
  final int dinnerCount;
  final double lunchPrice;
  final double dinnerPrice;

  const DailyMealHistory({
    required this.date,
    required this.lunchCount,
    required this.dinnerCount,
    required this.lunchPrice,
    required this.dinnerPrice,
  });

  int get totalMeals => lunchCount + dinnerCount;
  double get totalRevenue => (lunchCount * lunchPrice) + (dinnerCount * dinnerPrice);

  factory DailyMealHistory.fromJson(Map<String, dynamic> json) {
    return DailyMealHistory(
      date: json['date'] as String,
      lunchCount: json['lunchCount'] as int,
      dinnerCount: json['dinnerCount'] as int,
      lunchPrice: (json['lunchPrice'] as num).toDouble(),
      dinnerPrice: (json['dinnerPrice'] as num).toDouble(),
    );
  }
}

/// Aggregated credit history for a single day.
class DailyCreditHistory {
  final String date;
  final List<CreditTransactionSummary> transactions;

  const DailyCreditHistory({
    required this.date,
    required this.transactions,
  });

  factory DailyCreditHistory.fromJson(Map<String, dynamic> json) {
    return DailyCreditHistory(
      date: json['date'] as String,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) =>
                  CreditTransactionSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  double get totalAmount =>
      transactions.fold(0.0, (sum, t) => sum + t.amount);

  int get transactionCount => transactions.length;
}

class CreditTransactionSummary {
  final String id;
  final String studentId;
  final String studentName;
  final double amount;
  final String time;

  const CreditTransactionSummary({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.time,
  });

  factory CreditTransactionSummary.fromJson(Map<String, dynamic> json) {
    return CreditTransactionSummary(
      id: json['id'].toString(),
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      amount: (json['amount'] as num).toDouble(),
      time: json['time'] as String,
    );
  }
}
