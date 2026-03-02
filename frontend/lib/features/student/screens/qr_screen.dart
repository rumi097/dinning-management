import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  String? _activeTokenId;

  final List<TokenInfo> _tokens = const [
    TokenInfo(
      tokenId: 'TKN-2026-0301-LUN-4821',
      tokenType: 'Lunch Token',
      date: '01 Mar 2026',
      hall: 'Dining Hall A',
      time: '12:30 PM - 2:00 PM',
      status: 'Valid Today',
      isValid: true,
    ),
    TokenInfo(
      tokenId: 'TKN-2026-0302-DIN-7653',
      tokenType: 'Dinner Token',
      date: '02 Mar 2026',
      hall: 'Dining Hall B',
      time: '7:30 PM - 9:00 PM',
      status: 'Valid Tomorrow',
      isValid: false,
    ),
  ];

  void _onUseNow(TokenInfo token) {
    setState(() {
      _activeTokenId = token.tokenId;
    });
  }

  void _onCloseQr() {
    setState(() {
      _activeTokenId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tokens'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- QR Code Display (shown when a token is activated) ---
            if (_activeTokenId != null) ...[
              _buildQrSection(theme),
              const SizedBox(height: 24),
            ],

            // --- Tokens Section ---
            Text(
              'Your Tokens',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._tokens.map((token) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildTokenCard(theme, token),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection(ThemeData theme) {
    final token = _tokens.firstWhere((t) => t.tokenId == _activeTokenId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_2, color: Colors.green, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token.tokenType,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Show this QR at the counter',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _onCloseQr,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: QrImageView(
                data: token.tokenId,
                version: QrVersions.auto,
                size: 200,
                gapless: true,
                errorStateBuilder: (ctx, err) {
                  return const Center(
                    child: Text('Error generating QR'),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Token ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    token.tokenId,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Token details
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _infoChip(theme, Icons.calendar_today, token.date),
                const SizedBox(width: 12),
                _infoChip(theme, Icons.location_on_outlined, token.hall),
              ],
            ),
            const SizedBox(height: 8),
            _infoChip(theme, Icons.access_time, token.time),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenCard(ThemeData theme, TokenInfo token) {
    final isActive = _activeTokenId == token.tokenId;

    return Card(
      elevation: isActive ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Leading icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (token.isValid ? Colors.green : Colors.orange)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    token.isValid ? Icons.fastfood : Icons.dinner_dining,
                    color: token.isValid ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token.tokenType,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${token.date}  •  ${token.hall}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        token.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (token.isValid ? Colors.green : Colors.orange)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        token.isValid ? Icons.check_circle : Icons.schedule,
                        size: 16,
                        color: token.isValid ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        token.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: token.isValid
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Use Now button — only for valid tokens
            if (token.isValid) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: isActive
                    ? OutlinedButton.icon(
                        onPressed: _onCloseQr,
                        icon: const Icon(Icons.close),
                        label: const Text('Hide QR Code'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: () => _onUseNow(token),
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Use Now'),
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
          ],
        ),
      ),
    );
  }
}
