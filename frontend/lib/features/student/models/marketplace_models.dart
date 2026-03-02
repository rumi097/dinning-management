import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MARKETPLACE POST (Browse Tab)
// ─────────────────────────────────────────────────────────────────────────────

/// A sell-post listed in the marketplace (Browse tab).
class MarketplacePost {
  final String postId;
  final String sellerName;
  final String mealType; // 'Lunch' | 'Dinner'
  final String hallName;
  final String mealTime;
  final int mealPrice;
  final Color avatarColor;
  // Seller profile details
  final String studentId;
  final String mobile;
  final String roomNo;

  const MarketplacePost({
    required this.postId,
    required this.sellerName,
    required this.mealType,
    required this.hallName,
    required this.mealTime,
    required this.mealPrice,
    required this.avatarColor,
    required this.studentId,
    required this.mobile,
    required this.roomNo,
  });

  factory MarketplacePost.fromJson(Map<String, dynamic> json) =>
      MarketplacePost(
        postId: json['postId'] as String,
        sellerName: json['sellerName'] as String,
        mealType: json['mealType'] as String,
        hallName: json['hallName'] as String,
        mealTime: json['mealTime'] as String,
        mealPrice: json['mealPrice'] as int,
        avatarColor: _colorFromString(json['avatarColor'] as String?),
        studentId: json['studentId'] as String,
        mobile: json['mobile'] as String,
        roomNo: json['roomNo'] as String,
      );

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'sellerName': sellerName,
        'mealType': mealType,
        'hallName': hallName,
        'mealTime': mealTime,
        'mealPrice': mealPrice,
        'studentId': studentId,
        'mobile': mobile,
        'roomNo': roomNo,
      };

  /// Get seller initial for avatar.
  String get sellerInitial =>
      sellerName.isNotEmpty ? sellerName[0].toUpperCase() : '?';

  /// Whether this is a lunch post.
  bool get isLunch => mealType == 'Lunch';

  MarketplacePost copyWith({
    String? postId,
    String? sellerName,
    String? mealType,
    String? hallName,
    String? mealTime,
    int? mealPrice,
    Color? avatarColor,
    String? studentId,
    String? mobile,
    String? roomNo,
  }) =>
      MarketplacePost(
        postId: postId ?? this.postId,
        sellerName: sellerName ?? this.sellerName,
        mealType: mealType ?? this.mealType,
        hallName: hallName ?? this.hallName,
        mealTime: mealTime ?? this.mealTime,
        mealPrice: mealPrice ?? this.mealPrice,
        avatarColor: avatarColor ?? this.avatarColor,
        studentId: studentId ?? this.studentId,
        mobile: mobile ?? this.mobile,
        roomNo: roomNo ?? this.roomNo,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplacePost &&
          runtimeType == other.runtimeType &&
          postId == other.postId;

  @override
  int get hashCode => postId.hashCode;

  @override
  String toString() =>
      'MarketplacePost(postId: $postId, seller: $sellerName, mealType: $mealType)';
}

// ─────────────────────────────────────────────────────────────────────────────
// LISTING STATUS
// ─────────────────────────────────────────────────────────────────────────────

/// Status options for a marketplace listing.
enum ListingStatus {
  open('OPEN'),
  pending('PENDING'),
  completed('COMPLETED');

  final String value;
  const ListingStatus(this.value);

  static ListingStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OPEN':
        return ListingStatus.open;
      case 'PENDING':
        return ListingStatus.pending;
      case 'COMPLETED':
        return ListingStatus.completed;
      default:
        return ListingStatus.open;
    }
  }
}

/// Status options for a marketplace purchase.
enum PurchaseStatus {
  pending('PENDING'),
  confirmed('CONFIRMED'),
  cancelled('CANCELLED');

  final String value;
  const PurchaseStatus(this.value);

  static PurchaseStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return PurchaseStatus.pending;
      case 'CONFIRMED':
        return PurchaseStatus.confirmed;
      case 'CANCELLED':
        return PurchaseStatus.cancelled;
      default:
        return PurchaseStatus.pending;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MY LISTING (Activity → My Listings)
// ─────────────────────────────────────────────────────────────────────────────

/// A listing the student created (Activity → My Listings tab).
class MyListing {
  final String listingId;
  final String mealType; // 'Lunch' | 'Dinner'
  final String buyerName;
  final int price;
  final String status; // 'OPEN' | 'PENDING' | 'COMPLETED'
  final DateTime? pendingSince;

  const MyListing({
    required this.listingId,
    required this.mealType,
    required this.buyerName,
    required this.price,
    required this.status,
    this.pendingSince,
  });

  factory MyListing.fromJson(Map<String, dynamic> json) => MyListing(
        listingId: json['listingId'] as String,
        mealType: json['mealType'] as String,
        buyerName: json['buyerName'] as String? ?? '',
        price: json['price'] as int,
        status: json['status'] as String,
        pendingSince: json['pendingSince'] != null
            ? DateTime.parse(json['pendingSince'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'listingId': listingId,
        'mealType': mealType,
        'buyerName': buyerName,
        'price': price,
        'status': status,
        if (pendingSince != null)
          'pendingSince': pendingSince!.toIso8601String(),
      };

  /// Parsed status enum.
  ListingStatus get listingStatus => ListingStatus.fromString(status);

  /// Whether the listing has a buyer assigned.
  bool get hasBuyer => buyerName.isNotEmpty;

  /// Whether this listing is awaiting seller confirmation.
  bool get isPending => status == 'PENDING';

  /// Whether this listing is still open for buyers.
  bool get isOpen => status == 'OPEN';

  /// Whether this listing has been completed.
  bool get isCompleted => status == 'COMPLETED';

  MyListing copyWith({
    String? listingId,
    String? mealType,
    String? buyerName,
    int? price,
    String? status,
    DateTime? pendingSince,
  }) =>
      MyListing(
        listingId: listingId ?? this.listingId,
        mealType: mealType ?? this.mealType,
        buyerName: buyerName ?? this.buyerName,
        price: price ?? this.price,
        status: status ?? this.status,
        pendingSince: pendingSince ?? this.pendingSince,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyListing &&
          runtimeType == other.runtimeType &&
          listingId == other.listingId;

  @override
  int get hashCode => listingId.hashCode;

  @override
  String toString() =>
      'MyListing(listingId: $listingId, mealType: $mealType, status: $status)';
}

// ─────────────────────────────────────────────────────────────────────────────
// MY PURCHASE (Activity → My Purchases)
// ─────────────────────────────────────────────────────────────────────────────

/// A purchase the student made from the marketplace (Activity → My Purchases).
class MyPurchase {
  final String purchaseId;
  final String sellerName;
  final String mealType; // 'Lunch' | 'Dinner'
  final int price;
  final String status; // 'PENDING' | 'CONFIRMED' | 'CANCELLED'
  final DateTime? pendingSince;

  const MyPurchase({
    required this.purchaseId,
    required this.sellerName,
    required this.mealType,
    required this.price,
    required this.status,
    this.pendingSince,
  });

  factory MyPurchase.fromJson(Map<String, dynamic> json) => MyPurchase(
        purchaseId: json['purchaseId'] as String,
        sellerName: json['sellerName'] as String,
        mealType: json['mealType'] as String,
        price: json['price'] as int,
        status: json['status'] as String,
        pendingSince: json['pendingSince'] != null
            ? DateTime.parse(json['pendingSince'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'purchaseId': purchaseId,
        'sellerName': sellerName,
        'mealType': mealType,
        'price': price,
        'status': status,
        if (pendingSince != null)
          'pendingSince': pendingSince!.toIso8601String(),
      };

  /// Parsed status enum.
  PurchaseStatus get purchaseStatus => PurchaseStatus.fromString(status);

  /// Seller initial for avatar display.
  String get sellerInitial =>
      sellerName.isNotEmpty ? sellerName[0].toUpperCase() : '?';

  /// Whether this purchase is awaiting confirmation.
  bool get isPending => status == 'PENDING';

  /// Whether this purchase has been confirmed.
  bool get isConfirmed => status == 'CONFIRMED';

  /// Whether this purchase has been cancelled.
  bool get isCancelled => status == 'CANCELLED';

  MyPurchase copyWith({
    String? purchaseId,
    String? sellerName,
    String? mealType,
    int? price,
    String? status,
    DateTime? pendingSince,
  }) =>
      MyPurchase(
        purchaseId: purchaseId ?? this.purchaseId,
        sellerName: sellerName ?? this.sellerName,
        mealType: mealType ?? this.mealType,
        price: price ?? this.price,
        status: status ?? this.status,
        pendingSince: pendingSince ?? this.pendingSince,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyPurchase &&
          runtimeType == other.runtimeType &&
          purchaseId == other.purchaseId;

  @override
  int get hashCode => purchaseId.hashCode;

  @override
  String toString() =>
      'MyPurchase(purchaseId: $purchaseId, seller: $sellerName, status: $status)';
}

// ─────────────────────────────────────────────────────────────────────────────
// MARKETPLACE REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

/// Request to create a sell listing in the marketplace.
class CreateSellRequest {
  final String tokenId;
  final int price;

  const CreateSellRequest({required this.tokenId, required this.price});

  Map<String, dynamic> toJson() => {
        'tokenId': tokenId,
        'price': price,
      };

  @override
  String toString() =>
      'CreateSellRequest(tokenId: $tokenId, price: $price)';
}

/// Request to buy a token from the marketplace.
class BuyFromMarketplaceRequest {
  final String listingId;
  final String paymentMethod; // 'cash' or 'credit'

  const BuyFromMarketplaceRequest({
    required this.listingId,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'listingId': listingId,
        'paymentMethod': paymentMethod,
      };

  @override
  String toString() =>
      'BuyFromMarketplaceRequest(listingId: $listingId, paymentMethod: $paymentMethod)';
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Convert a color string to a Color (fallback to blue).
Color _colorFromString(String? colorName) {
  switch (colorName?.toLowerCase()) {
    case 'blue':
      return Colors.blue;
    case 'purple':
      return Colors.purple;
    case 'teal':
      return Colors.teal;
    case 'orange':
      return Colors.orange;
    case 'indigo':
      return Colors.indigo;
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'pink':
      return Colors.pink;
    case 'cyan':
      return Colors.cyan;
    case 'amber':
      return Colors.amber;
    default:
      return Colors.blue;
  }
}
