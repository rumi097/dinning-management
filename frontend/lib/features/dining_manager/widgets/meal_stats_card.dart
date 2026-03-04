import 'package:flutter/material.dart';
import 'package:frontend/features/dining_manager/models/meal_stats.dart';

/// Card widget showing meal statistics (total / used / remaining).
class MealStatsCard extends StatelessWidget {
  final MealStats stats;

  const MealStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLunch = stats.mealType == 'LUNCH';
    final color = isLunch ? Colors.orange : Colors.indigo;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLunch ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stats.mealType,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  stats.mealDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            if (stats.menu != null && stats.menu!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                stats.menu!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                _StatItem(
                  label: 'Total',
                  value: stats.totalTokens.toString(),
                  icon: Icons.confirmation_number_outlined,
                  color: theme.colorScheme.primary,
                ),
                _StatItem(
                  label: 'Served',
                  value: stats.usedTokens.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _StatItem(
                  label: 'Remaining',
                  value: stats.remainingTokens.toString(),
                  icon: Icons.pending_outlined,
                  color: Colors.deepOrange,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stats.totalTokens > 0
                    ? stats.usedTokens / stats.totalTokens
                    : 0,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  stats.remainingTokens == 0 ? Colors.green : color,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              stats.totalTokens > 0
                  ? '${((stats.usedTokens / stats.totalTokens) * 100).toStringAsFixed(0)}% served'
                  : 'No tokens sold',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
