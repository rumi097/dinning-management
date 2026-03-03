/// Represents a meal configuration for a specific date and meal type.
class MealConfig {
  final int? id;
  final String date; // YYYY-MM-DD
  final MealType mealType;
  final double price;
  final String menu;
  final String? purchaseDeadline; // HH:mm format
  final DateTime? createdAt;

  const MealConfig({
    this.id,
    required this.date,
    required this.mealType,
    required this.price,
    required this.menu,
    this.purchaseDeadline,
    this.createdAt,
  });

  factory MealConfig.fromJson(Map<String, dynamic> json) {
    return MealConfig(
      id: json['id'] as int?,
      date: json['date'] as String,
      mealType: MealType.fromString(json['mealType'] as String),
      price: (json['price'] as num).toDouble(),
      menu: json['menu'] as String,
      purchaseDeadline: json['purchaseDeadline'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'mealType': mealType.name,
      'price': price,
      'menu': menu,
      if (purchaseDeadline != null) 'purchaseDeadline': purchaseDeadline,
    };
  }

  MealConfig copyWith({
    int? id,
    String? date,
    MealType? mealType,
    double? price,
    String? menu,
    String? purchaseDeadline,
  }) {
    return MealConfig(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      price: price ?? this.price,
      menu: menu ?? this.menu,
      purchaseDeadline: purchaseDeadline ?? this.purchaseDeadline,
      createdAt: createdAt,
    );
  }
}

enum MealType {
  lunch,
  dinner;

  static MealType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      default:
        return MealType.lunch;
    }
  }

  String get displayName {
    switch (this) {
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}
