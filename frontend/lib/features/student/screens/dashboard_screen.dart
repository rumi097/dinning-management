import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/student_api_service.dart';
import '../widgets/token_card.dart';

class DashboardScreen extends StatefulWidget {
  final StudentApiService apiService;
  final VoidCallback? onLogout;

  const DashboardScreen({super.key, required this.apiService, this.onLogout});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPurchasing = false;

  WalletModel? _wallet;
  List<TokenModel> _tokens = [];
  List<MealOption> _availableMeals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        widget.apiService.getWalletBalance(),
        widget.apiService.getMyTokens(),
        widget.apiService.getAvailableMeals(),
      ]);
      if (!mounted) return;
      setState(() {
        _wallet = results[0] as WalletModel;
        _tokens = results[1] as List<TokenModel>;
        _availableMeals = results[2] as List<MealOption>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load dashboard. Pull to retry.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePurchase(MealOption meal) async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);

    try {
      final mealId = int.parse(meal.time);
      await widget.apiService.purchaseToken(mealId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${meal.mealType} token purchased successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData(); // refresh everything
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Purchase failed';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMsg = data['message']?.toString() ?? errorMsg;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _confirmPurchase(MealOption meal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Purchase'),
        content: Text('Buy ${meal.mealType} token for ৳${meal.price}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isPurchasing
                ? null
                : () {
                    Navigator.pop(context);
                    _handlePurchase(meal);
                  },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (widget.onLogout != null)
            IconButton(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Wallet Balance Card ---
                        _buildWalletCard(theme),

                        const SizedBox(height: 20),

                        // --- Available Meals / Buy Token Section ---
                        Text(
                          'Available Meals',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_availableMeals.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.restaurant_menu,
                                        size: 40,
                                        color: theme.colorScheme.onSurfaceVariant
                                            .withOpacity(0.5)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No meals available for purchase',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ..._availableMeals
                              .map((meal) => _buildMealCard(theme, meal)),

                        const SizedBox(height: 24),

                        // --- My Tokens Section ---
                        Text(
                          'My Tokens',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_tokens.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.confirmation_number_outlined,
                                        size: 40,
                                        color: theme.colorScheme.onSurfaceVariant
                                            .withOpacity(0.5)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No tokens purchased yet',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ..._tokens.map((token) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TokenCard(
                                  tokenType: '${token.tokenType} Token',
                                  date: token.date,
                                  hall: token.hall,
                                  time: token.time,
                                  status: token.status,
                                  isValid: token.isValid,
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWalletCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.account_balance_wallet,
                  color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _wallet?.formattedBalance ?? '৳0.00',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(ThemeData theme, MealOption meal) {
    final isLunch = meal.mealType == 'Lunch';
    final color = isLunch ? Colors.orange : Colors.deepPurple;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: meal type + price
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLunch ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    meal.mealType,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            const SizedBox(height: 12),

            // Menu items
            if (meal.menu.isNotEmpty) ...[
              Text(
                'Menu',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: meal.menu
                    .map((item) => Chip(
                          label: Text(item, style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Buy button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isPurchasing ? null : () => _confirmPurchase(meal),
                icon: _isPurchasing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.shopping_cart_outlined),
                label: Text('Buy ${meal.mealType} Token'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildError(ThemeData theme) {
    return Center(
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
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}