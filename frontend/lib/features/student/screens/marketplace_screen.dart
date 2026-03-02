import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/student_api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MarketplaceScreen extends StatefulWidget {
  final StudentApiService apiService;

  const MarketplaceScreen({super.key, required this.apiService});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Timer? _countdownTimer;

  // --- State flags ---
  bool _isLoading = true;
  String? _errorMessage;

  // --- Filter state ---
  String? _selectedMealType;   // null = All
  String? _selectedHallName;   // null = All

  // --- Data lists ---
  List<MarketplacePost> openPosts = [];
  List<MyToken> myTokens = [];
  List<MyListing> myListings = [];
  List<MyPurchase> myPurchases = [];

  // ───────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadData();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // COUNTDOWN TIMER  (ticks every second for pending items)
  // ───────────────────────────────────────────────────────────────────────────

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {}); // rebuild to update mm:ss labels
    });
  }

  /// Returns remaining time as `mm:ss` for a 15-minute window.
  /// Returns `null` when expired.
  String? _remainingTime(DateTime? since) {
    if (since == null) return null;
    final expiry = since.add(const Duration(minutes: 15));
    final diff = expiry.difference(DateTime.now());
    if (diff.isNegative) return null; // expired
    final m = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ───────────────────────────────────────────────────────────────────────────
  // API INTEGRATION (real API calls via StudentApiService)
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Uncomment when backend is ready
    // try {
    //   final results = await Future.wait([
    //     widget.apiService.getMarketplacePosts(),
    //     widget.apiService.getMarketplaceMyTokens(),
    //     widget.apiService.getMyListings(),
    //     widget.apiService.getMyPurchases(),
    //   ]);
    //   if (!mounted) return;
    //   setState(() {
    //     openPosts = results[0] as List<MarketplacePost>;
    //     myTokens = results[1] as List<MyToken>;
    //     myListings = results[2] as List<MyListing>;
    //     myPurchases = results[3] as List<MyPurchase>;
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   if (!mounted) return;
    //   setState(() {
    //     _errorMessage = 'Failed to load data. Pull to retry.';
    //     _isLoading = false;
    //   });
    // }

    // --- Dummy data (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      openPosts = [
        MarketplacePost(
          postId: 'POST-001',
          sellerName: 'Rahim Uddin',
          mealType: 'Lunch',
          hallName: 'Shahid Minar Hall',
          mealTime: '12:30 PM',
          mealPrice: 55,
          avatarColor: Colors.blue,
          studentId: 'STU-101',
          mobile: '01712345678',
          roomNo: '305',
        ),
        MarketplacePost(
          postId: 'POST-002',
          sellerName: 'Karim Hasan',
          mealType: 'Dinner',
          hallName: 'Bangabandhu Hall',
          mealTime: '7:30 PM',
          mealPrice: 50,
          avatarColor: Colors.green,
          studentId: 'STU-102',
          mobile: '01898765432',
          roomNo: '210',
        ),
        MarketplacePost(
          postId: 'POST-003',
          sellerName: 'Nusrat Jahan',
          mealType: 'Lunch',
          hallName: 'Rokeya Hall',
          mealTime: '12:30 PM',
          mealPrice: 60,
          avatarColor: Colors.purple,
          studentId: 'STU-103',
          mobile: '01556781234',
          roomNo: '412',
        ),
      ];
      myTokens = const [
        MyToken(
          tokenId: 'TKN-010',
          mealType: 'Lunch',
          date: '2025-01-16',
          price: 50,
          status: 'AVAILABLE',
        ),
        MyToken(
          tokenId: 'TKN-011',
          mealType: 'Dinner',
          date: '2025-01-16',
          price: 50,
          status: 'LISTED',
        ),
      ];
      myListings = [
        MyListing(
          listingId: 'LST-001',
          mealType: 'Dinner',
          buyerName: 'Fahim Ahmed',
          price: 55,
          status: 'PENDING',
          pendingSince: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        const MyListing(
          listingId: 'LST-002',
          mealType: 'Lunch',
          buyerName: '',
          price: 50,
          status: 'OPEN',
        ),
      ];
      myPurchases = [
        MyPurchase(
          purchaseId: 'PUR-001',
          sellerName: 'Rahim Uddin',
          mealType: 'Lunch',
          price: 55,
          status: 'PENDING',
          pendingSince: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ];
      _isLoading = false;
    });
  }

  // --- Action methods (real API calls) ---

  Future<void> sendBuyRequest(String postId, {required String paymentMethod}) async {
    // TODO: Uncomment when backend is ready
    // try {
    //   await widget.apiService.sendBuyRequest(postId, paymentMethod: paymentMethod);
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Buy request sent ($paymentMethod)')),
    //   );
    // } catch (e) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Buy request failed: $e'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }

    // --- Dummy action (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Buy request sent via $paymentMethod (dummy)')),
    );
    await _loadData();
  }

  /// Shows a bottom-sheet to choose Cash or Credit Transfer, then sends buy request.
  void _showPaymentMethodPicker(String postId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose Payment Method',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Cash option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.money, color: Colors.green),
                  ),
                  title: const Text('Cash'),
                  subtitle: const Text('Pay with cash on delivery'),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    sendBuyRequest(postId, paymentMethod: 'cash');
                  },
                ),
                const SizedBox(height: 8),
                // Credit Transfer option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.blue),
                  ),
                  title: const Text('Credit Transfer'),
                  subtitle: const Text('Pay from wallet balance'),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    sendBuyRequest(postId, paymentMethod: 'credit');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> confirmListing(String listingId) async {
    // TODO: Uncomment when backend is ready
    // try {
    //   await widget.apiService.confirmListing(listingId);
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Listing $listingId confirmed')),
    //   );
    // } catch (e) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Confirm failed: $e'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }

    // --- Dummy action (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Listing $listingId confirmed (dummy)')),
    );
    await _loadData();
  }

  Future<void> rejectListing(String listingId) async {
    // TODO: Uncomment when backend is ready
    // try {
    //   await widget.apiService.rejectListing(listingId);
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Listing $listingId rejected')),
    //   );
    // } catch (e) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Reject failed: $e'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }

    // --- Dummy action (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Listing $listingId rejected (dummy)')),
    );
    await _loadData();
  }

  Future<void> cancelPurchase(String purchaseId) async {
    // TODO: Uncomment when backend is ready
    // try {
    //   await widget.apiService.cancelPurchase(purchaseId);
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Purchase $purchaseId cancelled')),
    //   );
    // } catch (e) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Cancel failed: $e'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }

    // --- Dummy action (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase $purchaseId cancelled (dummy)')),
    );
    await _loadData();
  }

  Future<void> sellToken(String tokenId) async {
    // TODO: Uncomment when backend is ready
    // try {
    //   await widget.apiService.sellToken(
    //     CreateSellRequest(tokenId: tokenId, price: 50),
    //   );
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Token $tokenId listed for sale')),
    //   );
    // } catch (e) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Sell failed: $e'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }

    // --- Dummy action (remove when backend is ready) ---
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token $tokenId listed for sale (dummy)')),
    );
    await _loadData();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'My Tokens'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError(theme)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBrowseTab(theme),
                    _buildMyTokensTab(theme),
                    _buildActivityTab(theme),
                  ],
                ),
    );
  }

  // ───────────── Error state ─────────────

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1 — BROWSE  (existing UI preserved)
  // ───────────────────────────────────────────────────────────────────────────

  /// Returns posts filtered by the current meal-type & hall-name selections.
  List<MarketplacePost> get _filteredPosts {
    return openPosts.where((p) {
      if (_selectedMealType != null && p.mealType != _selectedMealType) {
        return false;
      }
      if (_selectedHallName != null && p.hallName != _selectedHallName) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Shows a floating profile card for a seller, fetched from API.
  void _showSellerProfile(MarketplacePost post) {
    showDialog(
      context: context,
      builder: (ctx) {
        return _SellerProfileDialog(
          apiService: widget.apiService,
          post: post,
        );
      },
    );
  }

  Widget _profileRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrowseTab(ThemeData theme) {
    // Derive unique hall names from posts for the filter dropdown
    final hallNames = openPosts.map((p) => p.hallName).toSet().toList()..sort();
    final mealTypes = openPosts.map((p) => p.mealType).toSet().toList()..sort();
    final filtered = _filteredPosts;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          // --- Filter Row ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                // Meal Type filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedMealType,
                        isExpanded: true,
                        hint: const Text('All Meals'),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: theme.textTheme.bodyMedium,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Meals'),
                          ),
                          ...mealTypes.map((type) => DropdownMenuItem<String?>(
                                value: type,
                                child: Text(type),
                              )),
                        ],
                        onChanged: (v) => setState(() => _selectedMealType = v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Hall Name filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedHallName,
                        isExpanded: true,
                        hint: const Text('All Halls'),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: theme.textTheme.bodyMedium,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Halls'),
                          ),
                          ...hallNames.map((hall) => DropdownMenuItem<String?>(
                                value: hall,
                                child: Text(hall),
                              )),
                        ],
                        onChanged: (v) => setState(() => _selectedHallName = v),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Sell Request List ---
          Expanded(
            child: filtered.isEmpty
                ? _emptyState(theme, Icons.storefront_outlined,
                    'No listings available')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final req = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Avatar (tappable)
                              GestureDetector(
                                onTap: () => _showSellerProfile(req),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      req.avatarColor.withOpacity(0.2),
                                  child: Text(
                                    req.sellerName[0],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: req.avatarColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showSellerProfile(req),
                                      child: Text(
                                        req.sellerName,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: req.mealType == 'Lunch'
                                                ? Colors.orange
                                                    .withOpacity(0.15)
                                                : Colors.deepPurple
                                                    .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            req.mealType,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  req.mealType == 'Lunch'
                                                      ? Colors
                                                          .orange.shade800
                                                      : Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '৳${req.mealPrice}',
                                          style: theme
                                              .textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme
                                                .colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${req.hallName}  •  ${req.mealTime}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Buy Now button
                              FilledButton(
                                onPressed: () => _showPaymentMethodPicker(req.postId),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Buy Now'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2 — MY TOKENS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildMyTokensTab(ThemeData theme) {
    if (myTokens.isEmpty) {
      return _emptyState(
          theme, Icons.confirmation_number_outlined, 'No tokens yet');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: myTokens.length,
        itemBuilder: (context, index) {
          final token = myTokens[index];

          final Color statusColor;
          final IconData statusIcon;
          switch (token.status) {
            case 'AVAILABLE':
              statusColor = Colors.green;
              statusIcon = Icons.check_circle;
            case 'LISTED':
              statusColor = Colors.orange;
              statusIcon = Icons.storefront;
            case 'USED':
              statusColor = Colors.grey;
              statusIcon = Icons.done_all;
            default:
              statusColor = Colors.grey;
              statusIcon = Icons.help_outline;
          }

          final Color mealColor = token.mealType == 'Lunch'
              ? Colors.orange
              : Colors.deepPurple;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: mealColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          token.mealType == 'Lunch'
                              ? Icons.wb_sunny_outlined
                              : Icons.nightlight_outlined,
                          color: mealColor,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${token.mealType} Token',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: mealColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    token.mealType,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: token.mealType == 'Lunch'
                                          ? Colors.orange.shade800
                                          : Colors.deepPurple,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '৳${token.price}',
                                  style:
                                      theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              token.date,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon,
                                size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              token.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Sell button — only for AVAILABLE tokens
                  if (token.status == 'AVAILABLE') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => sellToken(token.tokenId),
                        icon: const Icon(Icons.sell_outlined),
                        label: const Text('Sell This Token'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3 — ACTIVITY  (My Listings + My Purchases)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildActivityTab(ThemeData theme) {
    if (myListings.isEmpty && myPurchases.isEmpty) {
      return _emptyState(
          theme, Icons.receipt_long_outlined, 'No activity yet');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section A: My Listings ──
          if (myListings.isNotEmpty) ...[
            Text(
              'My Listings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...myListings.map((l) => _buildListingCard(theme, l)),
            const SizedBox(height: 24),
          ],

          // ── Section B: My Purchases ──
          if (myPurchases.isNotEmpty) ...[
            Text(
              'My Purchases',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...myPurchases.map((p) => _buildPurchaseCard(theme, p)),
          ],
        ],
      ),
    );
  }

  // ─────── Listing card ───────

  Widget _buildListingCard(ThemeData theme, MyListing listing) {
    final Color statusColor;
    final IconData statusIcon;
    switch (listing.status) {
      case 'OPEN':
        statusColor = Colors.blue;
        statusIcon = Icons.visibility;
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_top;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    final Color mealColor =
        listing.mealType == 'Lunch' ? Colors.orange : Colors.deepPurple;
    final remaining = _remainingTime(listing.pendingSince);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: mealColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    listing.mealType == 'Lunch'
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_outlined,
                    color: mealColor,
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${listing.mealType} Token',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: mealColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              listing.mealType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: listing.mealType == 'Lunch'
                                    ? Colors.orange.shade800
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '৳${listing.price}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (listing.buyerName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Buyer: ${listing.buyerName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        listing.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Pending → timer + confirm/reject
            if (listing.status == 'PENDING') ...[
              const SizedBox(height: 12),
              if (remaining != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        'Expires in $remaining',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          confirmListing(listing.listingId),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          rejectListing(listing.listingId),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────── Purchase card ───────

  Widget _buildPurchaseCard(ThemeData theme, MyPurchase purchase) {
    final Color statusColor;
    final IconData statusIcon;
    switch (purchase.status) {
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_top;
      case 'CONFIRMED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    final Color mealColor =
        purchase.mealType == 'Lunch' ? Colors.orange : Colors.deepPurple;
    final remaining = _remainingTime(purchase.pendingSince);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: mealColor.withOpacity(0.2),
                  child: Text(
                    purchase.sellerName[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: mealColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.sellerName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: mealColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              purchase.mealType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: purchase.mealType == 'Lunch'
                                    ? Colors.orange.shade800
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '৳${purchase.price}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        purchase.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Pending → timer + cancel
            if (purchase.status == 'PENDING') ...[
              const SizedBox(height: 12),
              if (remaining != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        'Expires in $remaining',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      cancelPurchase(purchase.purchaseId),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel Request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────── Empty state helper ─────────────

  Widget _emptyState(ThemeData theme, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELLER PROFILE DIALOG (fetches from API)
// ─────────────────────────────────────────────────────────────────────────────

class _SellerProfileDialog extends StatefulWidget {
  final StudentApiService apiService;
  final MarketplacePost post;

  const _SellerProfileDialog({
    required this.apiService,
    required this.post,
  });

  @override
  State<_SellerProfileDialog> createState() => _SellerProfileDialogState();
}

class _SellerProfileDialogState extends State<_SellerProfileDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  StudentProfile? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    // TODO: Uncomment when backend is ready
    // setState(() {
    //   _isLoading = true;
    //   _errorMessage = null;
    // });
    //
    // try {
    //   final profile =
    //       await widget.apiService.getSellerProfile(widget.post.studentId);
    //   if (!mounted) return;
    //   setState(() {
    //     _profile = profile;
    //     _isLoading = false;
    //   });
    // } catch (_) {
    //   if (!mounted) return;
    //   setState(() {
    //     _isLoading = false;
    //     _errorMessage = null;
    //     _profile = null;
    //   });
    // }

    // --- Dummy: skip API, use post data directly ---
    setState(() {
      _isLoading = false;
      _profile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;

    // Use API data if available, fallback to post data
    final name = _profile?.name ?? post.sellerName;
    final studentId = _profile?.roll ?? post.studentId;
    final mobile = _profile?.phoneNo ?? post.mobile;
    final hallName = _profile?.hallName ?? post.hallName;
    final roomNo = _profile?.roomNo ?? post.roomNo;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 24),
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                  SizedBox(height: 24),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: post.avatarColor.withOpacity(0.2),
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: post.avatarColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _profileRow(theme, Icons.badge_outlined, 'Student ID', studentId),
                  const SizedBox(height: 10),
                  _profileRow(theme, Icons.phone_outlined, 'Mobile', mobile),
                  const SizedBox(height: 10),
                  _profileRow(theme, Icons.apartment_outlined, 'Hall Name', hallName),
                  const SizedBox(height: 10),
                  _profileRow(theme, Icons.door_front_door_outlined, 'Room No', roomNo ?? 'N/A'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _profileRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}