/// Status options for a dining token.
enum TokenStatus {
  validToday('Valid Today'),
  validTomorrow('Valid Tomorrow'),
  expired('Expired'),
  used('Used');

  final String label;
  const TokenStatus(this.label);

  static TokenStatus fromString(String value) {
    switch (value.toLowerCase().replaceAll('_', '')) {
      case 'validtoday':
        return TokenStatus.validToday;
      case 'validtomorrow':
        return TokenStatus.validTomorrow;
      case 'expired':
        return TokenStatus.expired;
      case 'used':
        return TokenStatus.used;
      default:
        return TokenStatus.expired;
    }
  }
}

/// Status for tokens in the marketplace context.
enum MyTokenStatus {
  available('AVAILABLE'),
  listed('LISTED'),
  used('USED');

  final String value;
  const MyTokenStatus(this.value);

  static MyTokenStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'AVAILABLE':
        return MyTokenStatus.available;
      case 'LISTED':
        return MyTokenStatus.listed;
      case 'USED':
        return MyTokenStatus.used;
      default:
        return MyTokenStatus.available;
    }
  }
}

/// Represents a purchased dining token (used in Dashboard and QR screen).
class TokenModel {
  final String id;
  final String tokenType; // 'Lunch' | 'Dinner'
  final String date;
  final String hall;
  final String time;
  final String status;
  final int price;
  final bool isValid;

  const TokenModel({
    required this.id,
    required this.tokenType,
    required this.date,
    required this.hall,
    required this.time,
    required this.status,
    required this.price,
    this.isValid = false,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        id: json['id'] as String,
        tokenType: json['tokenType'] as String,
        date: json['date'] as String,
        hall: json['hall'] as String,
        time: json['time'] as String,
        status: json['status'] as String,
        price: json['price'] as int,
        isValid: json['status'] == 'valid_today' || json['status'] == 'Valid Today',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tokenType': tokenType,
        'date': date,
        'hall': hall,
        'time': time,
        'status': status,
        'price': price,
      };

  /// Parsed status enum.
  TokenStatus get tokenStatus => TokenStatus.fromString(status);

  TokenModel copyWith({
    String? id,
    String? tokenType,
    String? date,
    String? hall,
    String? time,
    String? status,
    int? price,
    bool? isValid,
  }) =>
      TokenModel(
        id: id ?? this.id,
        tokenType: tokenType ?? this.tokenType,
        date: date ?? this.date,
        hall: hall ?? this.hall,
        time: time ?? this.time,
        status: status ?? this.status,
        price: price ?? this.price,
        isValid: isValid ?? this.isValid,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TokenModel(id: $id, type: $tokenType, date: $date, status: $status)';
}

/// Token info for the QR screen (extends base token with QR display fields).
class TokenInfo {
  final String tokenId;
  final String tokenType;
  final String date;
  final String hall;
  final String time;
  final String status;
  final bool isValid;

  const TokenInfo({
    required this.tokenId,
    required this.tokenType,
    required this.date,
    required this.hall,
    required this.time,
    required this.status,
    required this.isValid,
  });

  factory TokenInfo.fromJson(Map<String, dynamic> json) => TokenInfo(
        tokenId: json['tokenId'] as String,
        tokenType: json['tokenType'] as String,
        date: json['date'] as String,
        hall: json['hall'] as String,
        time: json['time'] as String,
        status: json['status'] as String,
        isValid: json['isValid'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'tokenId': tokenId,
        'tokenType': tokenType,
        'date': date,
        'hall': hall,
        'time': time,
        'status': status,
        'isValid': isValid,
      };

  /// Create from a [TokenModel].
  factory TokenInfo.fromTokenModel(TokenModel token) => TokenInfo(
        tokenId: token.id,
        tokenType: token.tokenType,
        date: token.date,
        hall: token.hall,
        time: token.time,
        status: token.status,
        isValid: token.isValid,
      );

  TokenInfo copyWith({
    String? tokenId,
    String? tokenType,
    String? date,
    String? hall,
    String? time,
    String? status,
    bool? isValid,
  }) =>
      TokenInfo(
        tokenId: tokenId ?? this.tokenId,
        tokenType: tokenType ?? this.tokenType,
        date: date ?? this.date,
        hall: hall ?? this.hall,
        time: time ?? this.time,
        status: status ?? this.status,
        isValid: isValid ?? this.isValid,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenInfo &&
          runtimeType == other.runtimeType &&
          tokenId == other.tokenId;

  @override
  int get hashCode => tokenId.hashCode;

  @override
  String toString() =>
      'TokenInfo(tokenId: $tokenId, type: $tokenType, status: $status)';
}

/// A token the student owns, displayed in the Marketplace "My Tokens" tab.
class MyToken {
  final String tokenId;
  final String mealType; // 'Lunch' | 'Dinner'
  final String date;
  final int price;
  final String status; // 'AVAILABLE' | 'LISTED' | 'USED'

  const MyToken({
    required this.tokenId,
    required this.mealType,
    required this.date,
    required this.price,
    required this.status,
  });

  factory MyToken.fromJson(Map<String, dynamic> json) => MyToken(
        tokenId: json['tokenId'] as String,
        mealType: json['mealType'] as String,
        date: json['date'] as String,
        price: json['price'] as int,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'tokenId': tokenId,
        'mealType': mealType,
        'date': date,
        'price': price,
        'status': status,
      };

  /// Parsed status enum.
  MyTokenStatus get tokenStatus => MyTokenStatus.fromString(status);

  /// Whether this token can be listed for sale.
  bool get canSell => status == 'AVAILABLE';

  MyToken copyWith({
    String? tokenId,
    String? mealType,
    String? date,
    int? price,
    String? status,
  }) =>
      MyToken(
        tokenId: tokenId ?? this.tokenId,
        mealType: mealType ?? this.mealType,
        date: date ?? this.date,
        price: price ?? this.price,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyToken &&
          runtimeType == other.runtimeType &&
          tokenId == other.tokenId;

  @override
  int get hashCode => tokenId.hashCode;

  @override
  String toString() =>
      'MyToken(tokenId: $tokenId, mealType: $mealType, status: $status)';
}

/// Represents an available token for purchase (Purchase screen).
class AvailableToken {
  final String tokenType; // 'Lunch' | 'Dinner'
  final int price;
  final String time;
  final List<String> menu;

  const AvailableToken({
    required this.tokenType,
    required this.price,
    required this.time,
    required this.menu,
  });

  factory AvailableToken.fromJson(Map<String, dynamic> json) => AvailableToken(
        tokenType: json['tokenType'] as String,
        price: json['price'] as int,
        time: json['time'] as String,
        menu: List<String>.from(json['menu'] as List),
      );

  Map<String, dynamic> toJson() => {
        'tokenType': tokenType,
        'price': price,
        'time': time,
        'menu': menu,
      };

  @override
  String toString() =>
      'AvailableToken(type: $tokenType, price: $price)';
}

/// Request to purchase a token.
class PurchaseTokenRequest {
  final String tokenType; // 'lunch' | 'dinner'
  final String date;

  const PurchaseTokenRequest({required this.tokenType, required this.date});

  Map<String, dynamic> toJson() => {
        'tokenType': tokenType,
        'date': date,
      };

  @override
  String toString() =>
      'PurchaseTokenRequest(type: $tokenType, date: $date)';
}
