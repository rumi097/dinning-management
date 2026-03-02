import 'package:flutter/material.dart';
import '../models/credit_refund.dart';
import '../models/meal_config.dart';
import '../services/meal_manager_service.dart';
import '../widgets/refund_meal_card.dart';

/// Page for managing credit refunds when dining is cancelled for specific days.
///
/// Displays a list of cancelled meal days with pending refunds,
/// allows the manager to select individual or bulk refunds, and
/// shows a history tab of completed refunds.
class CreditRefundPage extends StatefulWidget {
  const CreditRefundPage({super.key});

  @override
  State<CreditRefundPage> createState() => _CreditRefundPageState();
}

class _CreditRefundPageState extends State<CreditRefundPage>
    with SingleTickerProviderStateMixin {
  final _service = MealManagerService();

  late TabController _tabController;

  // State
  bool _loading = true;
  List<RefundableMeal> _pendingMeals = [];
  List<RefundableMeal> _historyMeals = [];
  RefundSummary? _summary;
  final Set<String> _selectedIds = {};
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.getRefundableMeals(),
        _service.getRefundHistory(),
        _service.getRefundSummary(),
      ]);
      if (mounted) {
        setState(() {
          _pendingMeals = results[0] as List<RefundableMeal>;
          _historyMeals = results[1] as List<RefundableMeal>;
          _summary = results[2] as RefundSummary;
          _selectedIds.clear();
        });
      }
    } catch (_) {
      // handle error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _pendingMeals.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(_pendingMeals.map((m) => m.id));
      }
    });
  }

  Future<void> _processSingleRefund(RefundableMeal meal) async {
    final confirmed = await _showRefundConfirmDialog(
      context,
      title: 'Confirm Refund',
      message:
          'Refund ৳${meal.totalRefundAmount.toStringAsFixed(0)} to ${meal.tokensSold} students for '
          '${meal.mealType == MealType.lunch ? "Lunch" : "Dinner"} on ${_formatDate(meal.date)}?',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _processing = true);
    try {
      final success = await _service.processRefund(meal.id);
      if (!mounted) return;
      if (success) {
        _showSnackBar(
          'Refund processed successfully for ${meal.tokensSold} students!',
          isSuccess: true,
        );
        await _loadData();
      } else {
        _showSnackBar('Failed to process refund. Please try again.');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _processBulkRefund() async {
    if (_selectedIds.isEmpty) return;

    final selectedMeals =
        _pendingMeals.where((m) => _selectedIds.contains(m.id)).toList();
    final totalAmount =
        selectedMeals.fold(0.0, (sum, m) => sum + m.totalRefundAmount);
    final totalStudents =
        selectedMeals.fold(0, (sum, m) => sum + m.tokensSold);

    final confirmed = await _showRefundConfirmDialog(
      context,
      title: 'Confirm Bulk Refund',
      message:
          'Process ${_selectedIds.length} refund(s) totalling ৳${totalAmount.toStringAsFixed(0)} '
          'for $totalStudents students?',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _processing = true);
    try {
      final success =
          await _service.processBulkRefund(_selectedIds.toList());
      if (!mounted) return;
      if (success) {
        _showSnackBar(
          'Bulk refund processed! ৳${totalAmount.toStringAsFixed(0)} refunded to $totalStudents students.',
          isSuccess: true,
        );
        await _loadData();
      } else {
        _showSnackBar('Bulk refund failed. Please try again.');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showStudentList(RefundableMeal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _StudentListSheet(meal: meal),
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<bool?> _showRefundConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.currency_exchange,
                  color: Colors.red, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Confirm Refund'),
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
        title: const Text('Credit Refund'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pending_actions, size: 18),
                  const SizedBox(width: 6),
                  const Text('Pending'),
                  if (_pendingMeals.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _pendingMeals.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 18),
                  SizedBox(width: 6),
                  Text('History'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(theme),
                _buildHistoryTab(theme),
              ],
            ),
      // Floating action bar for bulk refund
      bottomNavigationBar: _selectedIds.isNotEmpty
          ? _buildBulkActionBar(theme)
          : null,
    );
  }

  // ── Pending tab ──
  Widget _buildPendingTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _pendingMeals.isEmpty
          ? _buildEmptyState(
              icon: Icons.check_circle_outline,
              title: 'No Pending Refunds',
              subtitle: 'All cancelled meal refunds have been processed.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Summary cards ──
                if (_summary != null) ...[
                  _buildSummarySection(theme),
                  const SizedBox(height: 16),
                ],

                // ── Select all header ──
                Row(
                  children: [
                    Text(
                      'Cancelled Meals',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _selectAll,
                      icon: Icon(
                        _selectedIds.length == _pendingMeals.length
                            ? Icons.deselect
                            : Icons.select_all,
                        size: 18,
                      ),
                      label: Text(
                        _selectedIds.length == _pendingMeals.length
                            ? 'Deselect All'
                            : 'Select All',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Meal cards ──
                ..._pendingMeals.map(
                  (meal) => RefundMealCard(
                    meal: meal,
                    isSelected: _selectedIds.contains(meal.id),
                    onToggleSelect: () => _toggleSelection(meal.id),
                    onViewStudents: () => _showStudentList(meal),
                    onRefund: () => _processSingleRefund(meal),
                  ),
                ),
              ],
            ),
    );
  }

  // ── History tab ──
  Widget _buildHistoryTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _historyMeals.isEmpty
          ? _buildEmptyState(
              icon: Icons.history,
              title: 'No Refund History',
              subtitle: 'Processed refunds will appear here.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._historyMeals.map(
                  (meal) => RefundMealCard(
                    meal: meal,
                    onViewStudents: () => _showStudentList(meal),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Summary cards ──
  Widget _buildSummarySection(ThemeData theme) {
    final summary = _summary!;
    return Column(
      children: [
        // Alert banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade50,
                Colors.orange.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withAlpha(40)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${summary.pendingCount} cancelled meal(s) need refunds',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '৳${summary.totalAmountPending.toStringAsFixed(0)} total pending amount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Stats row
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  label: 'Pending',
                  value: summary.pendingCount.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatCard(
                  label: 'Completed',
                  value: summary.completedCount.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatCard(
                  label: 'Refunded',
                  value: '৳${_compactNumber(summary.totalAmountRefunded)}',
                  icon: Icons.currency_exchange,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom bulk action bar ──
  Widget _buildBulkActionBar(ThemeData theme) {
    final selectedMeals =
        _pendingMeals.where((m) => _selectedIds.contains(m.id)).toList();
    final totalAmount =
        selectedMeals.fold(0.0, (sum, m) => sum + m.totalRefundAmount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedIds.length} selected',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Total: ৳${totalAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _processing ? null : _processBulkRefund,
              icon: _processing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.currency_exchange, size: 18),
              label: Text(_processing ? 'Processing...' : 'Refund All'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ──
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  String _compactNumber(double n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toStringAsFixed(0);
  }
}

// ─── Mini stat card used in the summary section ───

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet showing the list of students for a refundable meal ───

class _StudentListSheet extends StatelessWidget {
  final RefundableMeal meal;

  const _StudentListSheet({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLunch = meal.mealType == MealType.lunch;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isLunch ? Colors.orange : Colors.indigo)
                          .withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people,
                      color: isLunch ? Colors.orange : Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${isLunch ? "Lunch" : "Dinner"} · ${_formatDate(meal.date)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${meal.tokensSold} students · ৳${meal.totalRefundAmount.toStringAsFixed(0)} total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Student list
            Expanded(
              child: meal.students.isEmpty
                  ? Center(
                      child: Text(
                        'Student details will load from backend',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: meal.students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final student = meal.students[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme
                                .colorScheme.surfaceContainerHighest
                                .withAlpha(80),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: theme.colorScheme.primary
                                    .withAlpha(25),
                                child: Text(
                                  student.studentName.isNotEmpty
                                      ? student.studentName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.studentName,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Roll: ${student.studentRoll}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '৳${student.amountPaid.toStringAsFixed(0)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return date;
    }
  }
}
