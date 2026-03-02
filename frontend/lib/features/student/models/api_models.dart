// --- Auth ---
class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String token;
  final String studentId;
  final String name;
  final String email;
  LoginResponse({required this.token, required this.studentId, required this.name, required this.email});
  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'],
    studentId: json['studentId'],
    name: json['name'],
    email: json['email'],
  );
}

// --- Wallet ---
class WalletResponse {
  final double balance;
  WalletResponse({required this.balance});
  factory WalletResponse.fromJson(Map<String, dynamic> json) => WalletResponse(
    balance: (json['balance'] as num).toDouble(),
  );
}


// --- Token ---
class TokenResponse {
  final String id;
  final String tokenType; // 'Lunch' | 'Dinner'
  final String date;
  final String hall;
  final String time;
  final String status; // 'valid_today' | 'valid_tomorrow' | 'expired' | 'used'
  final int price;

  TokenResponse({
    required this.id,
    required this.tokenType,
    required this.date,
    required this.hall,
    required this.time,
    required this.status,
    required this.price,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
    id: json['id'],
    tokenType: json['tokenType'],
    date: json['date'],
    hall: json['hall'],
    time: json['time'],
    status: json['status'],
    price: json['price'],
  );
}

class PurchaseTokenRequest {
  final String tokenType; // 'lunch' | 'dinner'
  final String date;

  PurchaseTokenRequest({required this.tokenType, required this.date});
  Map<String, dynamic> toJson() => {'tokenType': tokenType, 'date': date};
}

// --- Available Token (Purchase Screen) ---
class AvailableTokenResponse {
  final String tokenType;
  final int price;
  final String time;
  final List<String> menu;

  AvailableTokenResponse({
    required this.tokenType,
    required this.price,
    required this.time,
    required this.menu,
  });

  factory AvailableTokenResponse.fromJson(Map<String, dynamic> json) => AvailableTokenResponse(
    tokenType: json['tokenType'],
    price: json['price'],
    time: json['time'],
    menu: List<String>.from(json['menu']),
  );
}

// --- Menu ---
class MenuResponse {
  final String mealType; // 'Lunch' | 'Dinner'
  final String time;
  final List<String> items;

  MenuResponse({required this.mealType, required this.time, required this.items});

  factory MenuResponse.fromJson(Map<String, dynamic> json) => MenuResponse(
    mealType: json['mealType'],
    time: json['time'],
    items: List<String>.from(json['items']),
  );
}

// --- Marketplace ---
class MarketplaceListingResponse {
  final String id;
  final String sellerName;
  final String sellerId;
  final String tokenType;
  final String hall;
  final String time;
  final String date;
  final int price;

  MarketplaceListingResponse({
    required this.id,
    required this.sellerName,
    required this.sellerId,
    required this.tokenType,
    required this.hall,
    required this.time,
    required this.date,
    required this.price,
  });

  factory MarketplaceListingResponse.fromJson(Map<String, dynamic> json) => MarketplaceListingResponse(
    id: json['id'],
    sellerName: json['sellerName'],
    sellerId: json['sellerId'],
    tokenType: json['tokenType'],
    hall: json['hall'],
    time: json['time'],
    date: json['date'],
    price: json['price'],
  );
}

class CreateSellRequest {
  final String tokenId;
  final int price;

  CreateSellRequest({required this.tokenId, required this.price});
  Map<String, dynamic> toJson() => {'tokenId': tokenId, 'price': price};
}

class BuyFromMarketplaceRequest {
  final String listingId;

  BuyFromMarketplaceRequest({required this.listingId});
  Map<String, dynamic> toJson() => {'listingId': listingId};
}

// --- Transaction ---
class TransactionResponse {
  final String id;
  final String status; // 'Purchased' | 'Sold'
  final String tokenType;
  final String date;
  final String hall;
  final String time;
  final int amount; // positive = credit, negative = debit
  final String tag;

  TransactionResponse({
    required this.id,
    required this.status,
    required this.tokenType,
    required this.date,
    required this.hall,
    required this.time,
    required this.amount,
    required this.tag,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) => TransactionResponse(
    id: json['id'],
    status: json['status'],
    tokenType: json['tokenType'],
    date: json['date'],
    hall: json['hall'],
    time: json['time'],
    amount: json['amount'],
    tag: json['tag'],
  );
}