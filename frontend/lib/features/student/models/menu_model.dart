import 'package:flutter/material.dart';

/// Represents a menu for a meal (Lunch/Dinner).
class MenuModel {
  final String mealType; // 'Lunch' | 'Dinner'
  final String time;
  final List<String> items;
  final String? date;

  const MenuModel({
    required this.mealType,
    required this.time,
    required this.items,
    this.date,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        mealType: json['mealType'] as String,
        time: json['time'] as String,
        items: List<String>.from(json['items'] as List),
        date: json['date'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'mealType': mealType,
        'time': time,
        'items': items,
        if (date != null) 'date': date,
      };

  MenuModel copyWith({
    String? mealType,
    String? time,
    List<String>? items,
    String? date,
  }) =>
      MenuModel(
        mealType: mealType ?? this.mealType,
        time: time ?? this.time,
        items: items ?? this.items,
        date: date ?? this.date,
      );

  @override
  String toString() =>
      'MenuModel(mealType: $mealType, time: $time, items: ${items.length})';
}

/// A meal option displayed on the Purchase screen with UI-specific fields.
class MealOption {
  final String mealType; // 'Lunch' | 'Dinner'
  final int price;
  final String time;
  final List<String> menu;
  final IconData icon;
  final Color accentColor;

  const MealOption({
    required this.mealType,
    required this.price,
    required this.time,
    required this.menu,
    required this.icon,
    required this.accentColor,
  });

  factory MealOption.fromJson(Map<String, dynamic> json) => MealOption(
        mealType: json['mealType'] as String,
        price: json['price'] as int,
        time: json['time'] as String,
        menu: List<String>.from(json['menu'] as List),
        icon: json['mealType'] == 'Lunch'
            ? Icons.wb_sunny_outlined
            : Icons.nightlight_outlined,
        accentColor:
            json['mealType'] == 'Lunch' ? Colors.orange : Colors.deepPurple,
      );

  /// Create from a [MenuModel] with a price.
  factory MealOption.fromMenuModel(MenuModel menu, {required int price}) =>
      MealOption(
        mealType: menu.mealType,
        price: price,
        time: menu.time,
        menu: menu.items,
        icon: menu.mealType == 'Lunch'
            ? Icons.wb_sunny_outlined
            : Icons.nightlight_outlined,
        accentColor:
            menu.mealType == 'Lunch' ? Colors.orange : Colors.deepPurple,
      );

  @override
  String toString() =>
      'MealOption(mealType: $mealType, price: $price, items: ${menu.length})';
}
