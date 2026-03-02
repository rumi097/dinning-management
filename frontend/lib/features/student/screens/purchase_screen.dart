import 'package:flutter/material.dart';
import '../models/models.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  static final List<MealOption> _meals = [
    MealOption(
      mealType: 'Lunch',
      price: 50,
      time: '12:30 PM - 2:00 PM',
      menu: ['Rice', 'Dal', 'Roti', 'Mixed Veg Curry', 'Curd'],
      icon: Icons.wb_sunny_outlined,
      accentColor: Colors.orange,
    ),
    MealOption(
      mealType: 'Dinner',
      price: 60,
      time: '7:30 PM - 9:00 PM',
      menu: ['Rice', 'Paneer Butter Masala', 'Naan', 'Salad', 'Gulab Jamun'],
      icon: Icons.nightlight_outlined,
      accentColor: Colors.deepPurple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Token'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _meals.length,
        itemBuilder: (context, index) {
          final meal = _meals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: meal.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(meal.icon, color: meal.accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.mealType,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              meal.time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '৳${meal.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Menu label
                  Text(
                    'Menu',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Menu items as chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: meal.menu
                        .map(
                          (item) => Chip(
                            label: Text(item),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 16),

                  // Buy button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Confirm Purchase'),
                            content: Text(
                                'Buy ${meal.mealType} token for ৳${meal.price}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${meal.mealType} token purchased!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text('Buy ${meal.mealType} Token'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}