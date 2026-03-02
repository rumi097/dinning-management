/// Represents a QR session for token validation at the dining counter.
class QrSessionModel {
  final String sessionId;
  final String tokenId;
  final String studentId;
  final String status; // 'PENDING' | 'SCANNED' | 'VALIDATED' | 'EXPIRED'
  final DateTime createdAt;
  final DateTime? scannedAt;
  final DateTime expiresAt;

  const QrSessionModel({
    required this.sessionId,
    required this.tokenId,
    required this.studentId,
    required this.status,
    required this.createdAt,
    this.scannedAt,
    required this.expiresAt,
  });

  factory QrSessionModel.fromJson(Map<String, dynamic> json) => QrSessionModel(
        sessionId: json['sessionId'] as String,
        tokenId: json['tokenId'] as String,
        studentId: json['studentId'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        scannedAt: json['scannedAt'] != null
            ? DateTime.parse(json['scannedAt'] as String)
            : null,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'tokenId': tokenId,
        'studentId': studentId,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        if (scannedAt != null) 'scannedAt': scannedAt!.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  /// Whether this QR session is still valid/active.
  bool get isActive =>
      status == 'PENDING' && DateTime.now().isBefore(expiresAt);

  /// Whether this QR session has been successfully validated.
  bool get isValidated => status == 'VALIDATED';

  /// Whether this QR session has expired.
  bool get isExpired =>
      status == 'EXPIRED' || DateTime.now().isAfter(expiresAt);

  /// Remaining time before expiry.
  Duration get remainingTime {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Remaining time formatted as "mm:ss".
  String get remainingTimeFormatted {
    final diff = remainingTime;
    final m = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrSessionModel &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId;

  @override
  int get hashCode => sessionId.hashCode;

  @override
  String toString() =>
      'QrSessionModel(sessionId: $sessionId, tokenId: $tokenId, status: $status)';
}
