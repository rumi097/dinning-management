/// Model for the revenue overview API response.
class RevenueOverview {
  final String period;
  final double totalRevenue;
  final double totalLunchRevenue;
  final double totalDinnerRevenue;
  final int totalMealsSold;
  final int totalLunchSold;
  final int totalDinnerSold;
  final List<DailyRevenue> dailyBreakdown;

  const RevenueOverview({
    this.period = 'daily',
    this.totalRevenue = 0,
    this.totalLunchRevenue = 0,
    this.totalDinnerRevenue = 0,
    this.totalMealsSold = 0,
    this.totalLunchSold = 0,
    this.totalDinnerSold = 0,
    this.dailyBreakdown = const [],
  });

  factory RevenueOverview.fromJson(Map<String, dynamic> json) {
    final breakdown = (json['dailyBreakdown'] as List<dynamic>?)
            ?.map((e) => DailyRevenue.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return RevenueOverview(
      period: json['period'] as String? ?? 'daily',
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalLunchRevenue: (json['totalLunchRevenue'] as num?)?.toDouble() ?? 0,
      totalDinnerRevenue: (json['totalDinnerRevenue'] as num?)?.toDouble() ?? 0,
      totalMealsSold: (json['totalMealsSold'] as num?)?.toInt() ?? 0,
      totalLunchSold: (json['totalLunchSold'] as num?)?.toInt() ?? 0,
      totalDinnerSold: (json['totalDinnerSold'] as num?)?.toInt() ?? 0,
      dailyBreakdown: breakdown,
    );
  }
}

class DailyRevenue {
  final String date;
  final String displayDate;
  final int lunchSold;
  final int dinnerSold;
  final double lunchRevenue;
  final double dinnerRevenue;
  final double totalRevenue;

  const DailyRevenue({
    this.date = '',
    this.displayDate = '',
    this.lunchSold = 0,
    this.dinnerSold = 0,
    this.lunchRevenue = 0,
    this.dinnerRevenue = 0,
    this.totalRevenue = 0,
  });

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: json['date'] as String? ?? '',
      displayDate: json['displayDate'] as String? ?? '',
      lunchSold: (json['lunchSold'] as num?)?.toInt() ?? 0,
      dinnerSold: (json['dinnerSold'] as num?)?.toInt() ?? 0,
      lunchRevenue: (json['lunchRevenue'] as num?)?.toDouble() ?? 0,
      dinnerRevenue: (json['dinnerRevenue'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    );
  }

  int get totalSold => lunchSold + dinnerSold;
}
