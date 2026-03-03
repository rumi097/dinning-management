import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // For iOS simulator: localhost works.
  // For Android emulator: use 10.0.2.2 instead.
  // For physical device: use your machine's LAN IP.
  static const String baseUrl = 'http://localhost:8080/api/v1';

  static Map<String, String> _headers(int userId) => {
        'Content-Type': 'application/json',
        'X-User-Id': userId.toString(),
      };

  // ── Test Helpers ───────────────────────────────────────────────────

  static Future<List<UserModel>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/test/users'));
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return (body['data'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  static Future<List<TokenModel>> getMyTokens(int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/test/tokens'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return (body['data'] as List)
        .map((e) => TokenModel.fromJson(e))
        .toList();
  }

  // ── Marketplace ────────────────────────────────────────────────────

  static Future<List<MarketplacePostModel>> getOpenPosts(int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/marketplace'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return (body['data'] as List)
        .map((e) => MarketplacePostModel.fromJson(e))
        .toList();
  }

  static Future<MarketplacePostModel> sellToken(int userId, int tokenId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/marketplace/sell'),
      headers: _headers(userId),
      body: jsonEncode({'tokenId': tokenId}),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return MarketplacePostModel.fromJson(body['data']);
  }

  static Future<MarketplacePostModel> sendBuyRequest(
      int userId, int postId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/marketplace/$postId/buy-request'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return MarketplacePostModel.fromJson(body['data']);
  }

  static Future<MarketplacePostModel> confirmTransfer(
      int userId, int postId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/marketplace/$postId/confirm-transfer'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return MarketplacePostModel.fromJson(body['data']);
  }

  static Future<MarketplacePostModel> cancelBuyRequest(
      int userId, int postId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/marketplace/$postId/cancel-request'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return MarketplacePostModel.fromJson(body['data']);
  }

  static Future<MarketplacePostModel> rejectBuyRequest(
      int userId, int postId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/marketplace/$postId/reject-request'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return MarketplacePostModel.fromJson(body['data']);
  }

  static Future<void> cancelListing(int userId, int postId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/marketplace/$postId/cancel-listing'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
  }

  static Future<List<MarketplacePostModel>> getMyListings(int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/marketplace/my-listings'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return (body['data'] as List)
        .map((e) => MarketplacePostModel.fromJson(e))
        .toList();
  }

  static Future<List<MarketplacePostModel>> getMyPurchases(int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/marketplace/my-purchases'),
      headers: _headers(userId),
    );
    final body = jsonDecode(res.body);
    if (body['success'] != true) throw Exception(body['message']);
    return (body['data'] as List)
        .map((e) => MarketplacePostModel.fromJson(e))
        .toList();
  }
}
