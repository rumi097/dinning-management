import 'package:flutter/material.dart';
import '../models/revenue_overview.dart';
import '../services/meal_manager_service.dart';

/// Full‑screen revenue overview with Daily / Weekly / Monthly tabs
/// and a month picker for selecting previous months.
class RevenueOverviewPage extends StatefulWidget {
  const RevenueOverviewPage({super.key});

  @override
  State<RevenueOverviewPage> createState() => _RevenueOverviewPageState();
}

class _RevenueOverviewPageState extends State<RevenueOverviewPage>
    with SingleTickerProviderStateMixin {
  final _service = MealManagerService();

  late TabController _tabController;
  final _periods = const ['daily', 'weekly', 'monthly'];
  final _periodLabels = const ['Daily', 'Weekly', 'Monthly'];

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  RevenueOverview? _overview;
  bool _loading = true;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _load();
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final overview = await _service.getRevenueOverview(
      period: _periods[_tabController.index],
      year: _selectedYear,
      month: _selectedMonth,
    );
    if (mounted) {
      setState(() {
        _overview = overview;
        _loading = false;
      });
    }
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    int tempYear = _selectedYear;
    int tempMonth = _selectedMonth;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text('Select Month'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: tempYear > now.year - 5
                            ? () => setModalState(() => tempYear--)
                            : null,
                      ),
                      Text(
                        '$tempYear',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: tempYear < now.year
                            ? () => setModalState(() => tempYear++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Month grid
                  SizedBox(
                    width: 280,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(12, (i) {
                        final m = i + 1;
                        final isFuture = tempYear == now.year && m > now.month;
                        final isSelected =
                            tempYear == _selectedYear && m == tempMonth;
                        return ChoiceChip(
                          label: Text(_months[i].substring(0, 3)),
                          selected: m == tempMonth,
                          selectedColor: isSelected
                              ? Theme.of(ctx).colorScheme.primaryContainer
                              : null,
                          onSelected: isFuture
                              ? null
                              : (sel) {
                                  if (sel) setModalState(() => tempMonth = m);
                                },
                        );
                      }),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(
                      ctx, {'year': tempYear, 'month': tempMonth}),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedYear = result['year']!;
        _selectedMonth = result['month']!;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Overview'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _periodLabels.map((l) => Tab(text: l)).toList(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _pickMonth,
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(
              '${_months[_selectedMonth - 1].substring(0, 3)} $_selectedYear',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final overview = _overview;
    if (overview == null) {
      return const Center(child: Text('No data available'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Summary Cards ──
          _buildSummaryCards(theme, overview),
          const SizedBox(height: 20),

          // ── Breakdown Header ──
          Row(
            children: [
              Icon(Icons.bar_chart, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Daily Breakdown',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${overview.dailyBreakdown.length} days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Daily breakdown list ──
          if (overview.dailyBreakdown.isEmpty)
            _emptyState(theme)
          else
            ...overview.dailyBreakdown.map((d) => _dayCard(theme, d)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme, RevenueOverview overview) {
    return Column(
      children: [
        // Total Revenue
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade600,
                Colors.green.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Total Revenue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '৳${overview.totalRevenue.toStringAsFixed(0)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _miniStat(
                      '${overview.totalMealsSold}', 'Meals Sold', Colors.white),
                  const SizedBox(width: 24),
                  _miniStat('${overview.totalLunchSold}', 'Lunch',
                      Colors.white70),
                  const SizedBox(width: 24),
                  _miniStat('${overview.totalDinnerSold}', 'Dinner',
                      Colors.white70),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Lunch / Dinner split
        Row(
          children: [
            Expanded(
              child: _revenueCard(
                theme,
                title: 'Lunch',
                revenue: overview.totalLunchRevenue,
                sold: overview.totalLunchSold,
                icon: Icons.wb_sunny_outlined,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _revenueCard(
                theme,
                title: 'Dinner',
                revenue: overview.totalDinnerRevenue,
                sold: overview.totalDinnerSold,
                icon: Icons.nightlight_outlined,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 16)),
        Text(label,
            style: TextStyle(color: color.withAlpha(180), fontSize: 11)),
      ],
    );
  }

  Widget _revenueCard(
    ThemeData theme, {
    required String title,
    required double revenue,
    required int sold,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '৳${revenue.toStringAsFixed(0)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$sold meals',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCard(ThemeData theme, DailyRevenue day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Date column
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                day.displayDate.isNotEmpty
                    ? day.displayDate.split(' ').first
                    : day.date.substring(8),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Meal details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.displayDate.isNotEmpty ? day.displayDate : day.date,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined,
                          size: 13, color: Colors.blue.shade400),
                      const SizedBox(width: 3),
                      Text('${day.lunchSold}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.blue.shade400)),
                      const SizedBox(width: 10),
                      Icon(Icons.nightlight_outlined,
                          size: 13, color: Colors.orange.shade400),
                      const SizedBox(width: 3),
                      Text('${day.dinnerSold}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.orange.shade400)),
                    ],
                  ),
                ],
              ),
            ),

            // Revenue
            Text(
              '৳${day.totalRevenue.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'No revenue data for this period',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
