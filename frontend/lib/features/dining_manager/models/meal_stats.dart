/// Model for today's meal statistics from the backend.
class MealStats {
  final int mealId;
  final String mealType;
  final String mealDate;
  final String? menu;
  final int totalTokens;
  final int usedTokens;
  final int remainingTokens;

  MealStats({
    required this.mealId,
    required this.mealType,
    required this.mealDate,
    this.menu,
    required this.totalTokens,
    required this.usedTokens,
    required this.remainingTokens,
  });

  factory MealStats.fromJson(Map<String, dynamic> json) {
    return MealStats(
      mealId: json['mealId'] as int,
      mealType: json['mealType'] as String,
      mealDate: json['mealDate'] as String,
      menu: json['menu'] as String?,
      totalTokens: json['totalTokens'] as int,
      usedTokens: json['usedTokens'] as int,
      remainingTokens: json['remainingTokens'] as int,
    );
  }
}

/// Model for QR validation response from the backend.
class QrValidationResult {
  final bool valid;
  final int? tokenId;
  final String? ownerName;
  final String? mealType;
  final String? mealDate;
  final String? status;
  final String message;

  QrValidationResult({
    required this.valid,
    this.tokenId,
    this.ownerName,
    this.mealType,
    this.mealDate,
    this.status,
    required this.message,
  });

  factory QrValidationResult.fromJson(Map<String, dynamic> json) {
    return QrValidationResult(
      valid: json['valid'] as bool,
      tokenId: json['tokenId'] as int?,
      ownerName: json['ownerName'] as String?,
      mealType: json['mealType'] as String?,
      mealDate: json['mealDate'] as String?,
      status: json['status'] as String?,
      message: json['message'] as String,
    );
  }
}
