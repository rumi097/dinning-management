import 'package:flutter/material.dart';
import '../models/credit_refund.dart';
import '../models/meal_config.dart';

/// Card widget displaying a single refundable (cancelled) meal day.
///
/// Shows the date, meal type, token count, refund amount, and
/// provides actions to view students or process the refund.
class RefundMealCard extends StatelessWidget {
  final RefundableMeal meal;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onViewStudents;
  final VoidCallback? onRefund;

  const RefundMealCard({
    super.key,
    required this.meal,
    this.isSelected = false,
    this.onToggleSelect,
    this.onViewStudents,
    this.onRefund,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLunch = meal.mealType == MealType.lunch;
    final mealColor = isLunch ? Colors.orange : Colors.indigo;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: meal.isRefunded
              ? Colors.green.withAlpha(60)
              : isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withAlpha(80),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      color: meal.isRefunded
          ? Colors.green.withAlpha(8)
          : isSelected
              ? theme.colorScheme.primary.withAlpha(8)
              : theme.cardColor,
      child: InkWell(
        onTap: meal.isRefunded ? null : onToggleSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Checkbox + Meal badge + Date + Status ──
              Row(
                children: [
                  // Checkbox for pending items
                  if (meal.isPending) ...[
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onToggleSelect?.call(),
                        activeColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Meal type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: mealColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: mealColor.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLunch
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          size: 14,
                          color: mealColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLunch ? 'Lunch' : 'Dinner',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: mealColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Date
                  Expanded(
                    child: Text(
                      _formatDate(meal.date),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Status chip
                  _StatusChip(status: meal.status),
                ],
              ),

              const SizedBox(height: 14),

              // ── Row 2: Stats ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withAlpha(80),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _StatItem(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Tokens',
                      value: meal.tokensSold.toString(),
                      color: Colors.blue,
                    ),
                    _divider(),
                    _StatItem(
                      icon: Icons.sell_outlined,
                      label: 'Price',
                      value: '৳${meal.pricePerToken.toStringAsFixed(0)}',
                      color: Colors.purple,
                    ),
                    _divider(),
                    _StatItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Total',
                      value: '৳${meal.totalRefundAmount.toStringAsFixed(0)}',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Row 3: Action buttons ──
              Row(
                children: [
                  // View students
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewStudents,
                      icon: const Icon(Icons.people_outline, size: 18),
                      label: Text(
                        '${meal.tokensSold} Students',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (meal.isPending) ...[
                    const SizedBox(width: 10),
                    // Refund button
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onRefund,
                        icon: const Icon(Icons.currency_exchange, size: 18),
                        label: const Text(
                          'Refund',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.withAlpha(40),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return date;
    }
  }
}

// ── Internal widgets ──

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
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

class _StatusChip extends StatelessWidget {
  final RefundStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == RefundStatus.completed;
    final color = isCompleted ? Colors.green : Colors.red;
    final label = isCompleted ? 'Refunded' : 'Pending';
    final icon = isCompleted ? Icons.check_circle : Icons.pending_actions;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

extension on Color {
  Color get shade700 {
    // Darken the color slightly for text
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }
}
