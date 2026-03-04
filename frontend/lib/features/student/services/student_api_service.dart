import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/token_storage.dart';
import '../models/models.dart';

/// Student API service using [ApiClient] (Dio) with automatic Bearer token
/// injection via the shared [TokenStorage].
///
/// All backend responses are wrapped in `{ success, message, data }`.
/// This service unwraps `.data` before returning domain objects.
class StudentApiService {
  late final ApiClient _client;

  /// Create a service that reuses an existing [ApiClient].
  StudentApiService.withClient(ApiClient client) : _client = client;

  /// Create a service for the given JWT [token].
  /// Internally spins up a dedicated [ApiClient] that stores the token.
  StudentApiService({required String token}) {
    final storage = TokenStorage();
    // persist token so ApiClient interceptor picks it up
    storage.saveToken(token);
    _client = ApiClient(tokenStorage: storage);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Unwrap `{ success, message, data }` → returns `data` (dynamic).
  dynamic _unwrap(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// Unwrap and cast to `List<dynamic>`.
  List<dynamic> _unwrapList(Response response) {
    final d = _unwrap(response);
    if (d is List) return d;
    return [];
  }

  // ---------------------------------------------------------------------------
  // WALLET  (GET /students/wallet)
  // ---------------------------------------------------------------------------

  Future<WalletModel> getWalletBalance() async {
    final res = await _client.get('/students/wallet');
    final data = _unwrap(res) as Map<String, dynamic>;
    return WalletModel(
      balance: (data['balance'] as num).toDouble(),
    );
  }

  // ---------------------------------------------------------------------------
  // TOKENS  (TokenController)
  // ---------------------------------------------------------------------------

  /// GET /tokens/me → list of owned tokens
  Future<List<TokenModel>> getMyTokens() async {
    final res = await _client.get('/tokens/me');
    final list = _unwrapList(res);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final status = m['status']?.toString() ?? '';
      final isValid = status == 'AVAILABLE';
      return TokenModel(
        id: m['id'].toString(),
        tokenType: _capitalize(m['mealType']?.toString() ?? ''),
        date: m['mealDate']?.toString() ?? '',
        hall: '',
        time: '',
        status: isValid ? 'Available' : status,
        price: (m['price'] is num) ? (m['price'] as num).toInt() : 0,
        isValid: isValid,
      );
    }).toList();
  }

  /// POST /tokens/purchase  body: { "mealId": <id> }
  Future<void> purchaseToken(int mealId) async {
    await _client.post('/tokens/purchase', data: {'mealId': mealId});
  }

  /// POST /tokens/{id}/generate-qr → QR code base64
  Future<String> generateQr(int tokenId) async {
    final res = await _client.post('/tokens/$tokenId/generate-qr');
    final data = _unwrap(res) as Map<String, dynamic>;
    return data['qrCode']?.toString() ?? '';
  }

  // ---------------------------------------------------------------------------
  // MEALS  (StudentController)
  // ---------------------------------------------------------------------------

  /// GET /students/meals/today → today's meals for the student's hall
  Future<List<MenuModel>> getTodayMenu() async {
    final res = await _client.get('/students/meals/today');
    final list = _unwrapList(res);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final menuStr = m['menu']?.toString() ?? '';
      // Backend stores menu as a comma-separated string
      final items = menuStr.isNotEmpty
          ? menuStr.split(',').map((s) => s.trim()).toList()
          : <String>[];
      return MenuModel(
        mealType: _capitalize(m['mealType']?.toString() ?? ''),
        time: '',
        items: items,
        date: m['mealDate']?.toString(),
      );
    }).toList();
  }

  /// GET /students/meals/available → meals available for purchase
  /// Returns [MealOption] objects with mealId stored in the time field for purchase.
  Future<List<MealOption>> getAvailableMeals() async {
    final res = await _client.get('/students/meals/available');
    final list = _unwrapList(res);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final mealType = _capitalize(m['mealType']?.toString() ?? '');
      final menuStr = m['menu']?.toString() ?? '';
      final items = menuStr.isNotEmpty
          ? menuStr.split(',').map((s) => s.trim()).toList()
          : <String>[];
      final price = (m['price'] is num) ? (m['price'] as num).toInt() : 0;
      return MealOption(
        mealType: mealType,
        price: price,
        time: m['mealId']?.toString() ?? '', // store mealId for purchase
        menu: items,
        icon: mealType == 'Lunch'
            ? Icons.wb_sunny_outlined
            : Icons.nightlight_outlined,
        accentColor: mealType == 'Lunch' ? Colors.orange : Colors.deepPurple,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // TRANSACTION HISTORY  (GET /students/history)
  // ---------------------------------------------------------------------------

  /// GET /students/history → aggregated transaction history
  Future<List<TransactionData>> getTransactionHistory() async {
    final res = await _client.get('/students/history');
    final list = _unwrapList(res);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final type = m['type']?.toString() ?? '';
      final amount = (m['amount'] is num) ? (m['amount'] as num).toInt() : 0;
      final mealType = m['mealType']?.toString() ?? '';
      final mealDate = m['mealDate']?.toString() ?? '';
      final status = m['status']?.toString() ?? '';
      final paymentMethod = m['paymentMethod']?.toString() ?? 'wallet';
      final description = m['description']?.toString() ?? '';

      // Determine tag for display
      String tag;
      switch (type) {
        case 'PURCHASE':
          tag = 'Purchase';
          break;
        case 'TOPUP':
          tag = 'Top-up';
          break;
        case 'MARKETPLACE_SELL':
          tag = 'Sold';
          break;
        case 'MARKETPLACE_BUY':
          tag = 'Bought';
          break;
        case 'USED':
          tag = 'Used';
          break;
        case 'REFUND':
          tag = 'Refund';
          break;
        default:
          tag = type;
      }

      return TransactionData(
        status: status,
        tokenType: mealType.isNotEmpty
            ? '${mealType[0]}${mealType.substring(1).toLowerCase()} Token'
            : description,
        date: mealDate,
        hall: '',
        time: '',
        amount: amount,
        tag: tag,
        paymentMethod: paymentMethod,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // MARKETPLACE  (MarketplaceController)
  // ---------------------------------------------------------------------------

  /// GET /marketplace/posts → open sell listings in the student's hall
  Future<List<MarketplacePost>> getMarketplacePosts() async {
    final res = await _client.get('/marketplace/posts');
    final list = _unwrapList(res);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return MarketplacePost(
        postId: m['id'].toString(),
        sellerName: m['sellerName']?.toString() ?? '',
        mealType: _capitalize(m['mealType']?.toString() ?? ''),
        hallName: '',
        mealTime: m['mealDate']?.toString() ?? '',
        mealPrice: (m['mealPrice'] is num) ? (m['mealPrice'] as num).toInt() : 0,
        avatarColor: _avatarColor(m['sellerName']?.toString() ?? ''),
        studentId: m['sellerId']?.toString() ?? '',
        mobile: '',
        roomNo: '',
      );
    }).toList();
  }

  /// GET /marketplace/my-tokens → tokens available for selling
  Future<List<MyToken>> getMarketplaceMyTokens() async {
    final res = await _client.get('/marketplace/my-tokens');
    final list = _unwrapList(res);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return MyToken(
        tokenId: m['id'].toString(),
        mealType: _capitalize(m['mealType']?.toString() ?? ''),
        date: m['mealDate']?.toString() ?? '',
        price: (m['price'] is num) ? (m['price'] as num).toInt() : 0,
        status: m['status']?.toString() ?? 'AVAILABLE',
      );
    }).toList();
  }

  /// GET /marketplace/my-listings → seller's active listings
  Future<List<MyListing>> getMyListings() async {
    final res = await _client.get('/marketplace/my-listings');
    final list = _unwrapList(res);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return MyListing(
        listingId: m['id'].toString(),
        mealType: _capitalize(m['mealType']?.toString() ?? ''),
        buyerName: m['buyerName']?.toString() ?? '',
        price: (m['mealPrice'] is num) ? (m['mealPrice'] as num).toInt() : 0,
        status: m['status']?.toString() ?? 'OPEN',
        pendingSince: m['buyerRequestedAt'] != null
            ? DateTime.tryParse(m['buyerRequestedAt'].toString())
            : null,
      );
    }).toList();
  }

  /// GET /marketplace/my-purchases → buyer's purchase requests
  Future<List<MyPurchase>> getMyPurchases() async {
    final res = await _client.get('/marketplace/my-purchases');
    final list = _unwrapList(res);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return MyPurchase(
        purchaseId: m['id'].toString(),
        sellerName: m['sellerName']?.toString() ?? '',
        mealType: _capitalize(m['mealType']?.toString() ?? ''),
        price: (m['mealPrice'] is num) ? (m['mealPrice'] as num).toInt() : 0,
        status: m['status']?.toString() ?? 'PENDING',
        pendingSince: m['buyerRequestedAt'] != null
            ? DateTime.tryParse(m['buyerRequestedAt'].toString())
            : null,
      );
    }).toList();
  }

  /// POST /marketplace/sell  body: { "tokenId": <id> }
  Future<void> sellToken(String tokenId) async {
    await _client.post('/marketplace/sell', data: {
      'tokenId': int.parse(tokenId),
    });
  }

  /// POST /marketplace/buy  body: { "postId": <id>, "paymentType": "TRANSACTION"|"TOPUP" }
  Future<void> sendBuyRequest(String postId, {required String paymentType}) async {
    await _client.post('/marketplace/buy', data: {
      'postId': int.parse(postId),
      'paymentType': paymentType,
    });
  }

  /// POST /marketplace/listings/{id}/confirm
  Future<void> confirmListing(String listingId) async {
    await _client.post('/marketplace/listings/$listingId/confirm');
  }

  /// POST /marketplace/listings/{id}/reject
  Future<void> rejectListing(String listingId) async {
    await _client.post('/marketplace/listings/$listingId/reject');
  }

  /// POST /marketplace/purchases/{id}/cancel
  Future<void> cancelPurchase(String purchaseId) async {
    await _client.post('/marketplace/purchases/$purchaseId/cancel');
  }

  /// DELETE /marketplace/{id}  — cancel a sell listing
  Future<void> cancelSellRequest(String listingId) async {
    await _client.delete('/marketplace/$listingId');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// "LUNCH" → "Lunch", "DINNER" → "Dinner"
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Deterministic avatar color from a name string.
  Color _avatarColor(String name) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}