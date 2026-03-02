/// Represents the student's wallet balance and details.
class WalletModel {
  final double balance;
  final String? currency;

  const WalletModel({
    required this.balance,
    this.currency = '৳',
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        balance: (json['balance'] as num).toDouble(),
        currency: json['currency'] as String? ?? '৳',
      );

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'currency': currency,
      };

  /// Formatted balance string (e.g., "৳250").
  String get formattedBalance => '$currency${balance.toStringAsFixed(balance.truncateToDouble() == balance ? 0 : 2)}';

  WalletModel copyWith({double? balance, String? currency}) => WalletModel(
        balance: balance ?? this.balance,
        currency: currency ?? this.currency,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletModel &&
          runtimeType == other.runtimeType &&
          balance == other.balance;

  @override
  int get hashCode => balance.hashCode;

  @override
  String toString() => 'WalletModel(balance: $balance)';
}

/// Represents a wallet top-up request.
class WalletTopUpRequest {
  final double amount;
  final String? paymentMethod;

  const WalletTopUpRequest({
    required this.amount,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      };

  @override
  String toString() => 'WalletTopUpRequest(amount: $amount, method: $paymentMethod)';
}

/// Represents a wallet transaction entry.
class WalletTransaction {
  final String id;
  final double amount;
  final String type; // 'CREDIT' | 'DEBIT' | 'TOPUP' | 'REFUND'
  final String description;
  final String date;
  final double balanceAfter;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.balanceAfter,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] as String,
        description: json['description'] as String,
        date: json['date'] as String,
        balanceAfter: (json['balanceAfter'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'description': description,
        'date': date,
        'balanceAfter': balanceAfter,
      };

  bool get isCredit => type == 'CREDIT' || type == 'TOPUP' || type == 'REFUND';

  @override
  String toString() =>
      'WalletTransaction(id: $id, amount: $amount, type: $type)';
}
