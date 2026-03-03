import 'meal_config.dart';

/// Represents a cancelled meal day that has tokens purchased by students,
/// eligible for credit refund.
class RefundableMeal {
  final String id;
  final String date; // YYYY-MM-DD
  final MealType mealType;
  final int tokensSold;
  final double pricePerToken;
  final double totalRefundAmount;
  final List<StudentToken> students;
  final RefundStatus status;
  final DateTime? refundedAt;

  const RefundableMeal({
    required this.id,
    required this.date,
    required this.mealType,
    required this.tokensSold,
    required this.pricePerToken,
    required this.totalRefundAmount,
    required this.students,
    this.status = RefundStatus.pending,
    this.refundedAt,
  });

  factory RefundableMeal.fromJson(Map<String, dynamic> json) {
    return RefundableMeal(
      id: json['id'].toString(),
      date: json['date'] as String,
      mealType: MealType.fromString(json['mealType'] as String),
      tokensSold: json['tokensSold'] as int,
      pricePerToken: (json['pricePerToken'] as num).toDouble(),
      totalRefundAmount: (json['totalRefundAmount'] as num).toDouble(),
      students: (json['students'] as List<dynamic>?)
              ?.map((s) => StudentToken.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      status: RefundStatus.fromString(json['status'] as String? ?? 'pending'),
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'] as String)
          : null,
    );
  }

  bool get isPending => status == RefundStatus.pending;
  bool get isRefunded => status == RefundStatus.completed;
}

/// A student who purchased a token for a cancelled meal.
class StudentToken {
  final String studentId;
  final String studentName;
  final String studentRoll;
  final double amountPaid;
  final bool refundProcessed;

  const StudentToken({
    required this.studentId,
    required this.studentName,
    required this.studentRoll,
    required this.amountPaid,
    this.refundProcessed = false,
  });

  factory StudentToken.fromJson(Map<String, dynamic> json) {
    return StudentToken(
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      studentRoll: json['studentRoll'] as String,
      amountPaid: (json['amountPaid'] as num).toDouble(),
      refundProcessed: json['refundProcessed'] as bool? ?? false,
    );
  }
}

/// Summary statistics for the refund feature.
class RefundSummary {
  final int pendingCount;
  final int completedCount;
  final double totalAmountPending;
  final double totalAmountRefunded;

  const RefundSummary({
    required this.pendingCount,
    required this.completedCount,
    required this.totalAmountPending,
    required this.totalAmountRefunded,
  });

  factory RefundSummary.fromJson(Map<String, dynamic> json) {
    return RefundSummary(
      pendingCount: json['pendingCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
      totalAmountPending: (json['totalAmountPending'] as num?)?.toDouble() ?? 0,
      totalAmountRefunded:
          (json['totalAmountRefunded'] as num?)?.toDouble() ?? 0,
    );
  }
}

enum RefundStatus {
  pending,
  completed;

  static RefundStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return RefundStatus.completed;
      default:
        return RefundStatus.pending;
    }
  }
}
