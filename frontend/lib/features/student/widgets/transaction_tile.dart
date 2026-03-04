import 'package:flutter/material.dart';
import '../models/models.dart';

class TransactionTile extends StatelessWidget {
  final TransactionData data;

  const TransactionTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = data.amount > 0;
    final isZero = data.amount == 0;
    final amountColor = isZero
        ? Colors.grey
        : isCredit
            ? Colors.green
            : Colors.red;

    Color tagColor;
    switch (data.tag) {
      case 'Top-up':
        tagColor = Colors.green;
        break;
      case 'Sold':
        tagColor = Colors.teal;
        break;
      case 'Bought':
        tagColor = Colors.orange;
        break;
      case 'Used':
        tagColor = Colors.grey;
        break;
      case 'Refund':
        tagColor = Colors.purple;
        break;
      default:
        tagColor = Colors.blue;
    }

    // Build subtitle parts, skipping empty values
    final subtitleParts = <String>[];
    if (data.date.isNotEmpty) subtitleParts.add(data.date);
    if (data.hall.isNotEmpty) subtitleParts.add(data.hall);
    if (data.time.isNotEmpty) subtitleParts.add(data.time);
    final subtitle = subtitleParts.isNotEmpty ? subtitleParts.join('  •  ') : '';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Leading icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: amountColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.tokenType,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data.tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tagColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (data.paymentMethod == 'cash' ? Colors.orange : Colors.blue)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.paymentMethod == 'cash' ? 'Cash' : 'Credit',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: data.paymentMethod == 'cash'
                            ? Colors.orange.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Amount
            if (!isZero)
              Text(
                '${isCredit ? '+' : '-'} ৳${data.amount.abs().toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}