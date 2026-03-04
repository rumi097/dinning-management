import 'package:flutter/material.dart';
import 'package:frontend/features/dining_manager/models/meal_stats.dart';

/// Dialog that shows scan result — verified (checkmark) or invalid (cross).
class ScanResultDialog extends StatelessWidget {
  final QrValidationResult result;
  final VoidCallback? onMarkUsed;

  const ScanResultDialog({
    super.key,
    required this.result,
    this.onMarkUsed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = result.valid;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isValid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                ),
                child: Icon(
                  isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 72,
                  color: isValid ? Colors.green : Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              isValid ? 'Token Valid!' : 'Invalid Token',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isValid ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),

            const SizedBox(height: 8),

            // Message
            Text(
              result.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            // Token details (if available)
            if (result.ownerName != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'Student',
                      value: result.ownerName!,
                    ),
                    if (result.mealType != null) ...[
                      const Divider(height: 16),
                      _DetailRow(
                        icon: result.mealType == 'LUNCH'
                            ? Icons.wb_sunny_outlined
                            : Icons.nights_stay_outlined,
                        label: 'Meal',
                        value: result.mealType!,
                      ),
                    ],
                    if (result.mealDate != null) ...[
                      const Divider(height: 16),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: result.mealDate!,
                      ),
                    ],
                    if (result.status != null) ...[
                      const Divider(height: 16),
                      _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Status',
                        value: result.status!,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Buttons
            if (isValid && onMarkUsed != null) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    onMarkUsed!();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Served'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isValid ? 'Cancel' : 'Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
