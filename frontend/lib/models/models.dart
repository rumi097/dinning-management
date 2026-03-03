// Shared models for marketplace test UI

class UserModel {
  final int id;
  final String name;
  final String email;
  final int hallId;
  final String hallName;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.hallId,
    required this.hallName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        hallId: json['hallId'],
        hallName: json['hallName'],
        role: json['role'],
      );

  @override
  String toString() => '$name (Hall: $hallName)';
}

class TokenModel {
  final int id;
  final int mealId;
  final String mealType;
  final String mealDate;
  final String menu;
  final double price;
  final String status;

  TokenModel({
    required this.id,
    required this.mealId,
    required this.mealType,
    required this.mealDate,
    required this.menu,
    required this.price,
    required this.status,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        id: json['id'],
        mealId: json['mealId'],
        mealType: json['mealType'],
        mealDate: json['mealDate'],
        menu: json['menu'] ?? '',
        price: (json['price'] as num).toDouble(),
        status: json['status'],
      );
}

class MarketplacePostModel {
  final int id;
  final int tokenId;
  final String mealType;
  final String mealDate;
  final String? mealMenu;
  final double mealPrice;
  final int sellerId;
  final String sellerName;
  final int? buyerId;
  final String? buyerName;
  final String status;
  final String? createdAt;
  final String? buyerRequestedAt;

  MarketplacePostModel({
    required this.id,
    required this.tokenId,
    required this.mealType,
    required this.mealDate,
    this.mealMenu,
    required this.mealPrice,
    required this.sellerId,
    required this.sellerName,
    this.buyerId,
    this.buyerName,
    required this.status,
    this.createdAt,
    this.buyerRequestedAt,
  });

  factory MarketplacePostModel.fromJson(Map<String, dynamic> json) =>
      MarketplacePostModel(
        id: json['id'],
        tokenId: json['tokenId'],
        mealType: json['mealType'],
        mealDate: json['mealDate'],
        mealMenu: json['mealMenu'],
        mealPrice: (json['mealPrice'] as num).toDouble(),
        sellerId: json['sellerId'],
        sellerName: json['sellerName'],
        buyerId: json['buyerId'],
        buyerName: json['buyerName'],
        status: json['status'],
        createdAt: json['createdAt'],
        buyerRequestedAt: json['buyerRequestedAt'],
      );
}
