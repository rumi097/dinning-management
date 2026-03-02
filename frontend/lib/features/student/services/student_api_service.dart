import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class StudentApiService {
  static const String _baseUrl = 'http://localhost:3000/api'; // change to your backend
  final String _token;

  StudentApiService({required String token}) : _token = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  // ==================== AUTH ====================

  static Future<LoginResponse> login(LoginRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Login failed: ${res.body}');
  }

  // ==================== WALLET ====================

  Future<WalletResponse> getWalletBalance() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/wallet/balance'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return WalletResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch wallet balance');
  }

  // ==================== TOKENS ====================

  Future<List<TokenResponse>> getMyTokens() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/tokens/my'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => TokenResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch tokens');
  }

  Future<List<AvailableTokenResponse>> getAvailableTokens() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/tokens/available'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => AvailableTokenResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch available tokens');
  }

  Future<TokenResponse> purchaseToken(PurchaseTokenRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/tokens/purchase'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return TokenResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Purchase failed: ${res.body}');
  }

  // ==================== MENU ====================

  Future<List<MenuResponse>> getTodayMenu() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/menu/today'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MenuResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch menu');
  }

  Future<List<MenuResponse>> getFullMenu() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/menu/full'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MenuResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch full menu');
  }

  // ==================== MARKETPLACE ====================

  Future<List<MarketplaceListingResponse>> getMarketplaceListings() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/marketplace/listings'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MarketplaceListingResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch marketplace');
  }

  Future<MarketplaceListingResponse> createSellRequest(CreateSellRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/marketplace/sell'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return MarketplaceListingResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Sell request failed: ${res.body}');
  }

  Future<TokenResponse> buyFromMarketplace(String listingId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/marketplace/buy/$listingId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return TokenResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Marketplace buy failed: ${res.body}');
  }

  Future<void> cancelSellRequest(String listingId) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/marketplace/$listingId'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Cancel failed');
    }
  }

  // ==================== TRANSACTIONS ====================

  Future<List<TransactionResponse>> getTransactions() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/transactions'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => TransactionResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch transactions');
  }
}