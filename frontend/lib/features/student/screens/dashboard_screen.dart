import 'package:flutter/material.dart';
import '../widgets/token_card.dart';
import '../widgets/menu_card.dart';
import 'purchase_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 18, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 6),
                Text(
                  '৳250',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Purchased Tokens Section ---
            Text(
              'Purchased Tokens',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const TokenCard(
              tokenType: 'Lunch Token',
              date: '01 Mar 2026',
              hall: 'Dining Hall A',
              time: '12:30 PM - 2:00 PM',
              status: 'Valid Today',
              isValid: true,
            ),
            const SizedBox(height: 10),
            const TokenCard(
              tokenType: 'Dinner Token',
              date: '02 Mar 2026',
              hall: 'Dining Hall B',
              time: '7:30 PM - 9:00 PM',
              status: 'Valid Tomorrow',
              isValid: false,
            ),

            const SizedBox(height: 24),

            // --- Today's Menu Preview Section ---
            Text(
              "Today's Menu Preview",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            MenuCard(
              mealType: 'Lunch',
              time: '12:30 PM - 2:00 PM',
              menuItems: const [
                'Rice',
                'Dal',
                'Roti',
                'Mixed Veg Curry',
                'Curd',
              ],
              onViewFullMenu: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Full menu coming soon!')),
                );
              },
              onBuyToken: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PurchaseScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}