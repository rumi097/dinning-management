import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final transactions = [
      TransactionData(
        status: 'Purchased',
        tokenType: 'Lunch Token',
        date: '01 Mar 2026',
        hall: 'Dining Hall A',
        time: '12:30 PM',
        amount: -50,
        tag: 'Purchased',
      ),
      TransactionData(
        status: 'Sold',
        tokenType: 'Dinner Token',
        date: '28 Feb 2026',
        hall: 'Dining Hall B',
        time: '7:30 PM',
        amount: 50,
        tag: 'Sold',
      ),
      TransactionData(
        status: 'Purchased',
        tokenType: 'Dinner Token',
        date: '27 Feb 2026',
        hall: 'Dining Hall C',
        time: '7:30 PM',
        amount: -60,
        tag: 'Purchased',
      ),
      TransactionData(
        status: 'Sold',
        tokenType: 'Lunch Token',
        date: '26 Feb 2026',
        hall: 'Dining Hall A',
        time: '12:30 PM',
        amount: 50,
        tag: 'Sold',
      ),
      TransactionData(
        status: 'Purchased',
        tokenType: 'Lunch Token',
        date: '25 Feb 2026',
        hall: 'Dining Hall B',
        time: '12:30 PM',
        amount: -50,
        tag: 'Purchased',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return TransactionTile(data: transactions[index]);
        },
      ),
    );
  }
}