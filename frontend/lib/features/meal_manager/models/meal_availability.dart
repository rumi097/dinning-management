/// Represents meal availability for a specific date.
///
/// The Meal Manager uses this to mark whether meals are
/// available on a given date, and individually toggle
/// lunch and dinner availability.
class MealAvailability {
  final String date; // YYYY-MM-DD
  final bool isMealAvailable; // master toggle
  final bool isLunchAvailable;
  final bool isDinnerAvailable;

  const MealAvailability({
    required this.date,
    this.isMealAvailable = true,
    this.isLunchAvailable = true,
    this.isDinnerAvailable = true,
  });

  factory MealAvailability.fromJson(Map<String, dynamic> json) {
    return MealAvailability(
      date: json['date'] as String,
      isMealAvailable: json['isMealAvailable'] as bool? ?? true,
      isLunchAvailable: json['isLunchAvailable'] as bool? ?? true,
      isDinnerAvailable: json['isDinnerAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'isMealAvailable': isMealAvailable,
      'isLunchAvailable': isLunchAvailable,
      'isDinnerAvailable': isDinnerAvailable,
    };
  }

  MealAvailability copyWith({
    String? date,
    bool? isMealAvailable,
    bool? isLunchAvailable,
    bool? isDinnerAvailable,
  }) {
    return MealAvailability(
      date: date ?? this.date,
      isMealAvailable: isMealAvailable ?? this.isMealAvailable,
      isLunchAvailable: isLunchAvailable ?? this.isLunchAvailable,
      isDinnerAvailable: isDinnerAvailable ?? this.isDinnerAvailable,
    );
  }
}
