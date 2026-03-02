import 'package:flutter/material.dart';
import '../services/meal_manager_service.dart';
import '../widgets/meal_count_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_tile.dart';
import 'add_credit_page.dart';
import 'credit_refund_page.dart';
import 'set_price_page.dart';
import 'set_menu_page.dart';
import 'meal_availability_page.dart';
import 'history_page.dart';

/// The main dashboard for the Meal Manager role.
///
/// Shows today's meal stats, revenue, and quick actions
/// to navigate to management tools.
class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final _service = MealManagerService();

  DashboardData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getDashboardData();
      if (mounted) setState(() => _data = data);
    } catch (_) {
      // handle error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Navigation helpers ──

  void _goTo(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = [
      _buildDashboardBody(theme),
      const HistoryPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dining Management',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _currentIndex == 0 ? 'Meal Manager Dashboard' : 'History',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _data;
    if (data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text('Failed to load dashboard'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Today's Date ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(60),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.today,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  _formattedDate(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Section: Today's Meal Counts ──
          _sectionHeader(theme, "Today's Meal Counts"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MealCountCard(
                  mealType: 'Lunch',
                  totalCount: data.lunchCount,
                  color: Colors.blue,
                  icon: Icons.wb_sunny_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MealCountCard(
                  mealType: 'Dinner',
                  totalCount: data.dinnerCount,
                  color: Colors.orange,
                  icon: Icons.nightlight_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Section: Revenue Overview ──
          _sectionHeader(theme, 'Revenue Overview'),
          const SizedBox(height: 8),
          StatCard(
            title: 'Total Revenue',
            value: '৳${data.totalRevenue.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet,
            color: Colors.green,
            subtitle:
                'Lunch ৳${data.lunchRevenue.toStringAsFixed(0)} · Dinner ৳${data.dinnerRevenue.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Students',
                    value: data.totalStudents.toString(),
                    icon: Icons.people_outline,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: "Today's Top‑ups",
                    value: data.todayTopUps.toString(),
                    icon: Icons.add_card,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Section: Quick Actions ──
          _sectionHeader(theme, 'Management Tools'),
          const SizedBox(height: 8),

          QuickActionTile(
            label: 'Add Student Credit',
            description: 'Top up wallet for a student',
            icon: Icons.credit_card,
            color: Colors.green,
            onTap: () => _goTo(const AddCreditPage()),
          ),
          const SizedBox(height: 8),

          QuickActionTile(
            label: 'Set Meal Prices',
            description: 'Configure lunch & dinner prices',
            icon: Icons.attach_money,
            color: Colors.purple,
            onTap: () => _goTo(const SetPricePage()),
          ),
          const SizedBox(height: 8),

          QuickActionTile(
            label: 'Set Menu',
            description: "Tomorrow's lunch & dinner menu",
            icon: Icons.restaurant_menu,
            color: Colors.orange,
            onTap: () => _goTo(const SetMenuPage()),
          ),
          const SizedBox(height: 8),

          QuickActionTile(
            label: 'Meal Availability',
            description: 'Toggle meals on/off by date',
            icon: Icons.event_available,
            color: Colors.teal,
            onTap: () => _goTo(const MealAvailabilityPage()),
          ),
          const SizedBox(height: 8),

          QuickActionTile(
            label: 'Credit Refund',
            description: 'Refund credits for cancelled meals',
            icon: Icons.currency_exchange,
            color: Colors.red,
            onTap: () => _goTo(const CreditRefundPage()),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formattedDate() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
      'Saturday', 'Sunday',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
