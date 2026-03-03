/// Represents a wallet top-up / credit transaction for a student.
class CreditTransaction {
  final String id;
  final String studentId;
  final String studentName;
  final double amount;
  final DateTime timestamp;

  const CreditTransaction({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.timestamp,
  });

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'].toString(),
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get formattedTime {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
