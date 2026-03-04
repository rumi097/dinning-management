import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/services/service_locator.dart';
import 'package:frontend/features/dining_manager/models/meal_stats.dart';
import 'package:frontend/features/dining_manager/screens/qr_scanner_screen.dart';
import 'package:frontend/features/dining_manager/services/dining_manager_service.dart';
import 'package:frontend/features/dining_manager/widgets/meal_stats_card.dart';
import 'package:frontend/features/dining_manager/widgets/scan_result_dialog.dart';

/// Main screen for the Dining Manager role.
/// Shows today's meal stats and a large scan button.
class DiningManagerHome extends StatefulWidget {
  const DiningManagerHome({super.key});

  @override
  State<DiningManagerHome> createState() => _DiningManagerHomeState();
}

class _DiningManagerHomeState extends State<DiningManagerHome> {
  late final DiningManagerService _service;
  List<MealStats> _stats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = DiningManagerService(apiClient: ServiceLocator.apiClient);
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _service.getTodayMealStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error = ApiClient.getErrorMessage(e);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openScanner() async {
    // Open camera scanner
    final qrData = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (qrData == null || !mounted) return;

    // Validate the scanned QR
    try {
      final result = await _service.validateQr(qrData);

      if (!mounted) return;

      // Show result dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ScanResultDialog(
          result: result,
          onMarkUsed: result.valid && result.tokenId != null
              ? () => _markUsed(result.tokenId!)
              : null,
        ),
      );
    } on DioException catch (e) {
      if (mounted) {
        _showErrorSnackbar(ApiClient.getErrorMessage(e));
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to validate QR: $e');
      }
    }
  }

  Future<void> _markUsed(int tokenId) async {
    try {
      await _service.markTokenUsed(tokenId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token marked as served!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Refresh stats
        _loadStats();
      }
    } on DioException catch (e) {
      if (mounted) {
        _showErrorSnackbar(ApiClient.getErrorMessage(e));
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to mark token: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    await ServiceLocator.tokenStorage.clearAll();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dining Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _buildContent(theme),
      ),
      floatingActionButton: _buildScanButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade300),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 40,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                'Today\'s Meal Service',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getTotalSummary(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Meal stats cards
        if (_stats.isEmpty)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.no_meals_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No meals configured for today',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._stats.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MealStatsCard(stats: s),
            ),
          ),
      ],
    );
  }

  String _getTotalSummary() {
    if (_stats.isEmpty) return 'No meals today';
    final totalRemaining =
        _stats.fold<int>(0, (sum, s) => sum + s.remainingTokens);
    final totalServed = _stats.fold<int>(0, (sum, s) => sum + s.usedTokens);
    return '$totalServed served · $totalRemaining remaining';
  }

  Widget _buildScanButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FloatingActionButton.extended(
          onPressed: _openScanner,
          icon: const Icon(Icons.qr_code_scanner, size: 28),
          label: const Text(
            'Scan QR Code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
