import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/student_api_service.dart';
import '../widgets/token_card.dart';
import 'purchase_screen.dart';

class DashboardScreen extends StatefulWidget {
  final StudentApiService apiService;

  const DashboardScreen({super.key, required this.apiService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  WalletModel? _wallet;
  List<TokenModel> _tokens = [];
  List<MenuModel> _todayMenu = [];

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

    // TODO: Uncomment when backend is ready
    // try {
    //   final results = await Future.wait([
    //     widget.apiService.getWalletBalance(),
    //     widget.apiService.getMyTokens(),
    //     widget.apiService.getTodayMenu(),
    //   ]);
    //   if (!mounted) return;
    //   setState(() {
    //     _wallet = results[0] as WalletModel;
    //     _tokens = results[1] as List<TokenModel>;
    //     _todayMenu = results[2] as List<MenuModel>;
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   if (!mounted) return;
    //   setState(() {
    //     _errorMessage = 'Failed to load dashboard. Pull to retry.';
    //     _isLoading = false;
    //   });
    // }

    // --- Dummy data (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _wallet = const WalletModel(balance: 250.0);
      _tokens = const [
        TokenModel(
          id: 'TKN-001',
          tokenType: 'Lunch',
          date: '2025-01-15',
          hall: 'Shahid Minar Hall',
          time: '12:30 PM - 2:00 PM',
          status: 'Valid',
          price: 50,
          isValid: true,
        ),
        TokenModel(
          id: 'TKN-002',
          tokenType: 'Dinner',
          date: '2025-01-15',
          hall: 'Bangabandhu Hall',
          time: '7:30 PM - 9:00 PM',
          status: 'Used',
          price: 50,
          isValid: false,
        ),
      ];
      _todayMenu = const [
        MenuModel(
          mealType: 'Lunch',
          time: '12:30 PM - 2:00 PM',
          items: ['Rice', 'Chicken Curry', 'Dal', 'Salad', 'Pudding'],
        ),
        MenuModel(
          mealType: 'Dinner',
          time: '7:30 PM - 9:00 PM',
          items: ['Rice', 'Fish Curry', 'Vegetable', 'Chatni', 'Sweet'],
        ),
      ];
      _isLoading = false;
    });
  }

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
                  _wallet?.formattedBalance ?? '৳...',
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
                        // --- Purchased Tokens Section ---
                        Text(
                          'Purchased Tokens',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_tokens.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'No tokens purchased yet',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
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

                        const SizedBox(height: 24),

                        // --- Today's Menu Preview Section (Side by Side) ---
                        Text(
                          "Today's Menu Preview",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_todayMenu.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'No menu available today',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              // Lunch and Dinner side by side
                              Row(
                                children: [
                                  ..._todayMenu.asMap().entries.map((entry) {
                                    final menu = entry.value;
                                    final isLunch = menu.mealType == 'Lunch';
                                    return Expanded(
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Meal type and time
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: (isLunch ? Colors.orange : Colors.deepPurple)
                                                      .withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  isLunch ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
                                                  color: isLunch ? Colors.orange : Colors.deepPurple,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                menu.mealType,
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                menu.time,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              // Menu items
                                              Wrap(
                                                spacing: 4,
                                                runSpacing: 4,
                                                children: menu.items.take(2).map((item) => Chip(
                                                  label: Text(item, style: const TextStyle(fontSize: 11)),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity: VisualDensity.compact,
                                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                                  side: BorderSide.none,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                )).toList(),
                                              ),
                                              if (menu.items.length > 2)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    '+${menu.items.length - 2} more',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: theme.colorScheme.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Buy Token button
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PurchaseScreen(apiService: widget.apiService),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.shopping_cart_outlined),
                                  label: const Text('Buy Token'),
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
                      ],
                    ),
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