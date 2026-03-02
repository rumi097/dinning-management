import 'package:flutter/material.dart';

class TokenCard extends StatelessWidget {
  final String tokenType;
  final String date;
  final String hall;
  final String time;
  final String status;
  final bool isValid;

  const TokenCard({
    super.key,
    required this.tokenType,
    required this.date,
    required this.hall,
    required this.time,
    required this.status,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Leading icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isValid ? Colors.green : Colors.orange).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isValid ? Icons.fastfood : Icons.dinner_dining,
                color: isValid ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tokenType,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$date  •  $hall',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isValid ? Colors.green : Colors.orange).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isValid ? Icons.check_circle : Icons.schedule,
                    size: 16,
                    color: isValid ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isValid ? Colors.green.shade700 : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}