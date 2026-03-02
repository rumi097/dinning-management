import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';
import '../services/student_api_service.dart';

class QrScreen extends StatefulWidget {
  final StudentApiService apiService;

  const QrScreen({super.key, required this.apiService});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  String? _activeTokenId;
  bool _isLoading = true;
  String? _errorMessage;
  List<TokenInfo> _tokens = [];

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Uncomment when backend is ready
    // try {
    //   final tokenModels = await widget.apiService.getMyTokens();
    //   if (!mounted) return;
    //   setState(() {
    //     _tokens = tokenModels
    //         .map((t) => TokenInfo.fromTokenModel(t))
    //         .toList();
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   if (!mounted) return;
    //   setState(() {
    //     _errorMessage = 'Failed to load tokens. Pull to retry.';
    //     _isLoading = false;
    //   });
    // }

    // --- Dummy data (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _tokens = const [
        TokenInfo(
          tokenId: 'TKN-001',
          tokenType: 'Lunch Token',
          date: '2025-01-15',
          hall: 'Shahid Minar Hall',
          time: '12:30 PM - 2:00 PM',
          status: 'Valid',
          isValid: true,
        ),
        TokenInfo(
          tokenId: 'TKN-002',
          tokenType: 'Dinner Token',
          date: '2025-01-15',
          hall: 'Bangabandhu Hall',
          time: '7:30 PM - 9:00 PM',
          status: 'Used',
          isValid: false,
        ),
      ];
      _isLoading = false;
    });
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError(theme)
              : RefreshIndicator(
                  onRefresh: _loadTokens,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        if (_tokens.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'No tokens available',
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
                                child: _buildTokenCard(theme, token),
                              )),
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
              onPressed: _loadTokens,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
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
