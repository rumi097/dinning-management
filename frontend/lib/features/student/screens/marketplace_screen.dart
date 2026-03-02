import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

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
  // API INTEGRATION STRUCTURE (placeholder fetch + dummy seed)
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        getOpenPosts(),
        getMyTokens(),
        getMyListings(),
        getMyPurchases(),
      ]);
      if (!mounted) return;
      setState(() {
        openPosts = results[0] as List<MarketplacePost>;
        myTokens = results[1] as List<MyToken>;
        myListings = results[2] as List<MyListing>;
        myPurchases = results[3] as List<MyPurchase>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load data. Pull to retry.';
        _isLoading = false;
      });
    }
  }

  // --- Placeholder API calls (replace with real http calls later) ----------

  Future<List<MarketplacePost>> getOpenPosts() async {
    // TODO: Replace with actual API call → GET /api/marketplace/posts
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      MarketplacePost(
        postId: 'post-001',
        sellerName: 'Aarav Sharma',
        mealType: 'Lunch',
        hallName: 'Dining Hall A',
        mealTime: '12:30 PM - 2:00 PM',
        mealPrice: 50,
        avatarColor: Colors.blue,
        studentId: 'STU-2024-001',
        mobile: '+880 1712-345678',
        roomNo: 'A-301',
      ),
      MarketplacePost(
        postId: 'post-002',
        sellerName: 'Priya Patel',
        mealType: 'Dinner',
        hallName: 'Dining Hall B',
        mealTime: '7:30 PM - 9:00 PM',
        mealPrice: 50,
        avatarColor: Colors.purple,
        studentId: 'STU-2024-002',
        mobile: '+880 1798-765432',
        roomNo: 'B-215',
      ),
      MarketplacePost(
        postId: 'post-003',
        sellerName: 'Rohan Mehta',
        mealType: 'Lunch',
        hallName: 'Dining Hall A',
        mealTime: '12:30 PM - 2:00 PM',
        mealPrice: 50,
        avatarColor: Colors.teal,
        studentId: 'STU-2024-003',
        mobile: '+880 1654-321987',
        roomNo: 'A-118',
      ),
      MarketplacePost(
        postId: 'post-004',
        sellerName: 'Sneha Gupta',
        mealType: 'Dinner',
        hallName: 'Dining Hall C',
        mealTime: '7:30 PM - 9:00 PM',
        mealPrice: 50,
        avatarColor: Colors.orange,
        studentId: 'STU-2024-004',
        mobile: '+880 1876-543210',
        roomNo: 'C-402',
      ),
      MarketplacePost(
        postId: 'post-005',
        sellerName: 'Vikram Singh',
        mealType: 'Lunch',
        hallName: 'Dining Hall B',
        mealTime: '12:30 PM - 2:00 PM',
        mealPrice: 50,
        avatarColor: Colors.indigo,
        studentId: 'STU-2024-005',
        mobile: '+880 1945-678901',
        roomNo: 'B-310',
      ),
    ];
  }

  Future<List<MyToken>> getMyTokens() async {
    // TODO: Replace with actual API call → GET /api/student/tokens
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      MyToken(
        tokenId: 'tkn-101',
        mealType: 'Lunch',
        date: '01 Mar 2026',
        price: 50,
        status: 'AVAILABLE',
      ),
      MyToken(
        tokenId: 'tkn-102',
        mealType: 'Dinner',
        date: '01 Mar 2026',
        price: 60,
        status: 'LISTED',
      ),
      MyToken(
        tokenId: 'tkn-103',
        mealType: 'Lunch',
        date: '02 Mar 2026',
        price: 50,
        status: 'USED',
      ),
    ];
  }

  Future<List<MyListing>> getMyListings() async {
    // TODO: Replace with actual API call → GET /api/marketplace/my-listings
    await Future.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now();
    return [
      const MyListing(
        listingId: 'lst-201',
        mealType: 'Lunch',
        buyerName: '',
        price: 50,
        status: 'OPEN',
      ),
      MyListing(
        listingId: 'lst-202',
        mealType: 'Dinner',
        buyerName: 'Priya Patel',
        price: 60,
        status: 'PENDING',
        pendingSince: now.subtract(const Duration(minutes: 5)),
      ),
      const MyListing(
        listingId: 'lst-203',
        mealType: 'Lunch',
        buyerName: 'Rohan Mehta',
        price: 50,
        status: 'COMPLETED',
      ),
    ];
  }

  Future<List<MyPurchase>> getMyPurchases() async {
    // TODO: Replace with actual API call → GET /api/marketplace/my-purchases
    await Future.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now();
    return [
      MyPurchase(
        purchaseId: 'pur-301',
        sellerName: 'Aarav Sharma',
        mealType: 'Lunch',
        price: 50,
        status: 'PENDING',
        pendingSince: now.subtract(const Duration(minutes: 3)),
      ),
      const MyPurchase(
        purchaseId: 'pur-302',
        sellerName: 'Sneha Gupta',
        mealType: 'Dinner',
        price: 60,
        status: 'CONFIRMED',
      ),
    ];
  }

  // --- Action placeholders ---------------------------------------------------

  Future<void> sendBuyRequest(String postId) async {
    // TODO: POST /api/marketplace/buy { postId }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Buy request sent for post $postId')),
    );
    await _loadData();
  }

  Future<void> confirmListing(String listingId) async {
    // TODO: POST /api/marketplace/listings/$listingId/confirm
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Listing $listingId confirmed')),
    );
    await _loadData();
  }

  Future<void> rejectListing(String listingId) async {
    // TODO: POST /api/marketplace/listings/$listingId/reject
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Listing $listingId rejected')),
    );
    await _loadData();
  }

  Future<void> cancelPurchase(String purchaseId) async {
    // TODO: POST /api/marketplace/purchases/$purchaseId/cancel
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase $purchaseId cancelled')),
    );
    await _loadData();
  }

  Future<void> sellToken(String tokenId) async {
    // TODO: POST /api/marketplace/sell { tokenId }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token $tokenId listed for sale')),
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

  /// Shows a floating profile card for a seller.
  void _showSellerProfile(MarketplacePost post) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: post.avatarColor.withOpacity(0.2),
                  child: Text(
                    post.sellerName[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: post.avatarColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  post.sellerName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _profileRow(theme, Icons.badge_outlined, 'Student ID', post.studentId),
                const SizedBox(height: 10),
                _profileRow(theme, Icons.phone_outlined, 'Mobile', post.mobile),
                const SizedBox(height: 10),
                _profileRow(theme, Icons.apartment_outlined, 'Hall Name', post.hallName),
                const SizedBox(height: 10),
                _profileRow(theme, Icons.door_front_door_outlined, 'Room No', post.roomNo),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
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
                                onPressed: () => sendBuyRequest(req.postId),
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