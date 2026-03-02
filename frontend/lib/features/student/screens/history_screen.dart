import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/student_api_service.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  final StudentApiService apiService;

  const HistoryScreen({super.key, required this.apiService});

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

    // TODO: Uncomment when backend is ready
    // try {
    //   final data = await widget.apiService.getTransactions();
    //   if (!mounted) return;
    //   setState(() {
    //     _transactions = data;
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   if (!mounted) return;
    //   setState(() {
    //     _errorMessage = 'Failed to load transactions. Pull to retry.';
    //     _isLoading = false;
    //   });
    // }

    // --- Dummy data (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _transactions = const [
        TransactionData(
          status: 'Purchased',
          tokenType: 'Lunch Token',
          date: '2025-01-15',
          hall: 'Shahid Minar Hall',
          time: '12:30 PM',
          amount: -50,
          tag: 'Purchased',
          paymentMethod: 'credit',
        ),
        TransactionData(
          status: 'Purchased',
          tokenType: 'Dinner Token',
          date: '2025-01-14',
          hall: 'Bangabandhu Hall',
          time: '7:30 PM',
          amount: -50,
          tag: 'Purchased',
          paymentMethod: 'cash',
        ),
        TransactionData(
          status: 'Sold',
          tokenType: 'Lunch Token',
          date: '2025-01-13',
          hall: 'Rokeya Hall',
          time: '12:30 PM',
          amount: 55,
          tag: 'Sold',
          paymentMethod: 'cash',
        ),
        TransactionData(
          status: 'Purchased',
          tokenType: 'Dinner Token',
          date: '2025-01-12',
          hall: 'Shahid Minar Hall',
          time: '7:30 PM',
          amount: -50,
          tag: 'Purchased',
          paymentMethod: 'credit',
        ),
        TransactionData(
          status: 'Sold',
          tokenType: 'Dinner Token',
          date: '2025-01-11',
          hall: 'Bangabandhu Hall',
          time: '7:30 PM',
          amount: 60,
          tag: 'Sold',
          paymentMethod: 'cash',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
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