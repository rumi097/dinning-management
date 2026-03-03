import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/student_api_service.dart';

class PurchaseScreen extends StatefulWidget {
  final StudentApiService apiService;

  const PurchaseScreen({super.key, required this.apiService});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<MealOption> _meals = [];
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableTokens();
  }

  Future<void> _loadAvailableTokens() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Uncomment when backend is ready
    // try {
    //   final available = await widget.apiService.getAvailableTokens();
    //   if (!mounted) return;
    //   setState(() {
    //     _meals = available
    //         .map((t) => MealOption(
    //               mealType: t.tokenType,
    //               price: t.price,
    //               time: t.time,
    //               menu: t.menu,
    //               icon: t.tokenType == 'Lunch'
    //                   ? Icons.wb_sunny_outlined
    //                   : Icons.nightlight_outlined,
    //               accentColor: t.tokenType == 'Lunch'
    //                   ? Colors.orange
    //                   : Colors.deepPurple,
    //             ))
    //         .toList();
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   if (!mounted) return;
    //   setState(() {
    //     _errorMessage = 'Failed to load available tokens.';
    //     _isLoading = false;
    //   });
    // }

    // --- Dummy data (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _meals = [
        MealOption(
          mealType: 'Lunch',
          price: 50,
          time: '12:30 PM - 2:00 PM',
          menu: ['Rice', 'Chicken Curry', 'Dal', 'Salad', 'Pudding'],
          icon: Icons.wb_sunny_outlined,
          accentColor: Colors.orange,
        ),
        MealOption(
          mealType: 'Dinner',
          price: 50,
          time: '7:30 PM - 9:00 PM',
          menu: ['Rice', 'Fish Curry', 'Vegetable', 'Chatni', 'Sweet'],
          icon: Icons.nightlight_outlined,
          accentColor: Colors.deepPurple,
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _handlePurchase(MealOption meal) async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);

    // TODO: Uncomment when backend is ready
    // try {
    //   final today = DateTime.now();
    //   final dateStr =
    //       '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    //   await widget.apiService.purchaseToken(
    //     PurchaseTokenRequest(
    //       tokenType: meal.mealType.toLowerCase(),
    //       date: dateStr,
    //     ),
    //   );
    //   if (!mounted) return;
    //   Navigator.pop(context);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('${meal.mealType} token purchased!'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // } catch (e) {
    //   if (!mounted) return;
    //   Navigator.pop(context);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Purchase failed: $e'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // } finally {
    //   if (mounted) setState(() => _isPurchasing = false);
    // }

    // --- Dummy purchase (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.pop(context); // close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meal.mealType} token purchased! (dummy)'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() => _isPurchasing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Token'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(_errorMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadAvailableTokens,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _meals.isEmpty
                  ? Center(
                      child: Text(
                        'No tokens available for purchase',
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAvailableTokens,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _meals.length,
                        itemBuilder: (context, index) {
                          final meal = _meals[index];
                          return _buildMealCard(theme, meal);
                        },
                      ),
                    ),
    );
  }

  Widget _buildMealCard(ThemeData theme, MealOption meal) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          onPressed: _isPurchasing
                              ? null
                              : () => _handlePurchase(meal),
                          child: _isPurchasing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text('Confirm'),
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
  }
}