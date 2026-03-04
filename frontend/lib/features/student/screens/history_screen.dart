import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/student_api_service.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  final StudentApiService apiService;
  final VoidCallback? onLogout;

  const HistoryScreen({super.key, required this.apiService, this.onLogout});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<TransactionData> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactions = await widget.apiService.getTransactionHistory();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load transactions. Pull to retry.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          if (widget.onLogout != null)
            IconButton(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError(theme)
              : _transactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet',
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          return TransactionTile(data: _transactions[index]);
                        },
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
              onPressed: _loadTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}