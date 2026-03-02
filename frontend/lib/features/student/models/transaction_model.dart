/// Represents a transaction record displayed in History screen.
class TransactionData {
  final String status; // 'Purchased' | 'Sold'
  final String tokenType; // e.g., 'Lunch Token', 'Dinner Token'
  final String date;
  final String hall;
  final String time;
  final int amount; // positive = credit (sold), negative = debit (purchased)
  final String tag; // 'Purchased' | 'Sold'
  final String paymentMethod; // 'cash' | 'credit'

  const TransactionData({
    required this.status,
    required this.tokenType,
    required this.date,
    required this.hall,
    required this.time,
    required this.amount,
    required this.tag,
    this.paymentMethod = 'credit',
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) =>
      TransactionData(
        status: json['status'] as String,
        tokenType: json['tokenType'] as String,
        date: json['date'] as String,
        hall: json['hall'] as String,
        time: json['time'] as String,
        amount: json['amount'] as int,
        tag: json['tag'] as String,
        paymentMethod: json['paymentMethod'] as String? ?? 'credit',
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'tokenType': tokenType,
        'date': date,
        'hall': hall,
        'time': time,
        'amount': amount,
        'tag': tag,
        'paymentMethod': paymentMethod,
      };

  /// Whether this transaction is a credit (incoming money).
  bool get isCredit => amount > 0;

  /// Whether this transaction is a debit (outgoing money).
  bool get isDebit => amount < 0;

  /// The absolute amount value.
  int get absoluteAmount => amount.abs();

  /// Formatted amount string (e.g., "+৳50" or "-৳60").
  String get formattedAmount =>
      '${isCredit ? '+' : '-'} ৳${absoluteAmount}';

  /// Detail text combining date, hall, and time.
  String get detailText => '$date  •  $hall  •  $time';

  TransactionData copyWith({
    String? status,
    String? tokenType,
    String? date,
    String? hall,
    String? time,
    int? amount,
    String? tag,
  }) =>
      TransactionData(
        status: status ?? this.status,
        tokenType: tokenType ?? this.tokenType,
        date: date ?? this.date,
        hall: hall ?? this.hall,
        time: time ?? this.time,
        amount: amount ?? this.amount,
        tag: tag ?? this.tag,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionData &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          tokenType == other.tokenType &&
          date == other.date &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(status, tokenType, date, amount);

  @override
  String toString() =>
      'TransactionData(tokenType: $tokenType, amount: $amount, tag: $tag)';
}

/// Transaction filter/sort options for the History screen.
enum TransactionFilter {
  all('All'),
  purchased('Purchased'),
  sold('Sold');

  final String label;
  const TransactionFilter(this.label);
}

/// Sort order for transactions.
enum TransactionSort {
  newest('Newest First'),
  oldest('Oldest First'),
  amountHigh('Amount: High to Low'),
  amountLow('Amount: Low to High');

  final String label;
  const TransactionSort(this.label);
}
