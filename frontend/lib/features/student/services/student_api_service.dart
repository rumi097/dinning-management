import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class StudentApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator → localhost
  final String _token;

  StudentApiService({required String token}) : _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  // ==================== AUTH ====================

  static Future<AuthResponse> login(LoginRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Login failed: ${res.body}');
  }

  static Future<AuthResponse> signup(SignupRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Signup failed: ${res.body}');
  }

  Future<AuthResponse> getMe() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch user info');
  }

  // ==================== WALLET ====================

  Future<WalletModel> getWalletBalance() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/wallet/me'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return WalletModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch wallet balance');
  }

  Future<WalletModel> topUpWallet(WalletTopUpRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/wallet/topup'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return WalletModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Top-up failed: ${res.body}');
  }

  // ==================== TOKENS ====================

  Future<List<TokenModel>> getMyTokens() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/students/me/tokens'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => TokenModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch tokens');
  }

  Future<List<AvailableToken>> getAvailableTokens() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/tokens/available'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => AvailableToken.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch available tokens');
  }

  Future<TokenModel> purchaseToken(PurchaseTokenRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/tokens/purchase'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return TokenModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Purchase failed: ${res.body}');
  }

  // ==================== MENU ====================

  Future<List<MenuModel>> getTodayMenu() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/menu/today'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MenuModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch menu');
  }

  Future<List<MenuModel>> getFullMenu() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/menu/full'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MenuModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch full menu');
  }

  // ==================== MARKETPLACE ====================

  Future<List<MarketplacePost>> getMarketplacePosts() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/marketplace/posts'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MarketplacePost.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch marketplace posts');
  }

  Future<List<MyToken>> getMarketplaceMyTokens() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/marketplace/my-tokens'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MyToken.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch my tokens');
  }

  Future<List<MyListing>> getMyListings() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/marketplace/my-listings'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MyListing.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch my listings');
  }

  Future<List<MyPurchase>> getMyPurchases() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/marketplace/my-purchases'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MyPurchase.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch my purchases');
  }

  Future<void> sendBuyRequest(String postId, {required String paymentMethod}) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/marketplace/buy'),
      headers: _headers,
      body: jsonEncode({
        'postId': postId,
        'paymentMethod': paymentMethod,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Buy request failed: ${res.body}');
    }
  }

  Future<void> sellToken(CreateSellRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/marketplace/sell'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Sell request failed: ${res.body}');
    }
  }

  Future<void> confirmListing(String listingId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/marketplace/listings/$listingId/confirm'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Confirm failed: ${res.body}');
    }
  }

  Future<void> rejectListing(String listingId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/marketplace/listings/$listingId/reject'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Reject failed: ${res.body}');
    }
  }

  Future<void> cancelPurchase(String purchaseId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/marketplace/purchases/$purchaseId/cancel'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Cancel failed: ${res.body}');
    }
  }

  Future<void> cancelSellRequest(String listingId) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/marketplace/$listingId'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Cancel sell request failed');
    }
  }

  // ==================== TRANSACTIONS ====================

  Future<List<TransactionData>> getTransactions() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/students/me/transactions'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => TransactionData.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch transactions');
  }

  // ==================== STUDENT PROFILE ====================

  Future<StudentProfile> getSellerProfile(String studentId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/students/$studentId/profile'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return StudentProfile.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch seller profile');
  }

  // ==================== HALLS ====================

  Future<List<HallModel>> getHalls() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/halls'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => HallModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch halls');
  }
}