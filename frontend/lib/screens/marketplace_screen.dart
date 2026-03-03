import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<UserModel> users = [];
  UserModel? selectedUser;

  List<MarketplacePostModel> openPosts = [];
  List<TokenModel> myTokens = [];
  List<MarketplacePostModel> myListings = [];
  List<MarketplacePostModel> myPurchases = [];

  bool loading = false;
  String? errorMsg;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
    // Tick every second for countdown display
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // ── Data Loading ───────────────────────────────────────────────────

  Future<void> _loadUsers() async {
    try {
      final u = await ApiService.getUsers();
      setState(() {
        users = u;
        if (u.isNotEmpty) {
          selectedUser = u.first;
        }
      });
      if (selectedUser != null) _refreshAll();
    } catch (e) {
      _showError('Failed to load users: $e');
    }
  }

  Future<void> _refreshAll() async {
    if (selectedUser == null) return;
    setState(() {
      loading = true;
      errorMsg = null;
    });
    try {
      final uid = selectedUser!.id;
      final results = await Future.wait([
        ApiService.getOpenPosts(uid),
        ApiService.getMyTokens(uid),
        ApiService.getMyListings(uid),
        ApiService.getMyPurchases(uid),
      ]);
      setState(() {
        openPosts = results[0] as List<MarketplacePostModel>;
        myTokens = results[1] as List<TokenModel>;
        myListings = results[2] as List<MarketplacePostModel>;
        myPurchases = results[3] as List<MarketplacePostModel>;
      });
    } catch (e) {
      _showError('Refresh failed: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  // ── Actions ────────────────────────────────────────────────────────

  Future<void> _sellToken(TokenModel token) async {
    try {
      await ApiService.sellToken(selectedUser!.id, token.id);
      _showSuccess('Token listed for sale!');
      _refreshAll();
    } catch (e) {
      _showError('Sell failed: $e');
    }
  }

  Future<void> _buyRequest(MarketplacePostModel post) async {
    try {
      await ApiService.sendBuyRequest(selectedUser!.id, post.id);
      _showSuccess('Buy request sent!');
      _refreshAll();
    } catch (e) {
      _showError('Buy request failed: $e');
    }
  }

  Future<void> _confirmTransfer(MarketplacePostModel post) async {
    try {
      await ApiService.confirmTransfer(selectedUser!.id, post.id);
      _showSuccess('Token transferred!');
      _refreshAll();
    } catch (e) {
      _showError('Confirm failed: $e');
    }
  }

  Future<void> _cancelRequest(MarketplacePostModel post) async {
    try {
      await ApiService.cancelBuyRequest(selectedUser!.id, post.id);
      _showSuccess('Buy request cancelled.');
      _refreshAll();
    } catch (e) {
      _showError('Cancel failed: $e');
    }
  }

  Future<void> _cancelListing(MarketplacePostModel post) async {
    try {
      await ApiService.cancelListing(selectedUser!.id, post.id);
      _showSuccess('Listing cancelled.');
      _refreshAll();
    } catch (e) {
      _showError('Cancel listing failed: $e');
    }
  }

  Future<void> _rejectRequest(MarketplacePostModel post) async {
    try {
      await ApiService.rejectBuyRequest(selectedUser!.id, post.id);
      _showSuccess('Buy request rejected.');
      _refreshAll();
    } catch (e) {
      _showError('Reject failed: $e');
    }
  }

  // ── Countdown Helper ───────────────────────────────────────────────

  Duration? _remainingTime(String? buyerRequestedAt) {
    if (buyerRequestedAt == null) return null;
    final requestTime = DateTime.parse(buyerRequestedAt);
    final expiry = requestTime.add(const Duration(minutes: 15));
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Feedback ───────────────────────────────────────────────────────

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse', icon: Icon(Icons.store)),
            Tab(text: 'My Tokens', icon: Icon(Icons.confirmation_number)),
            Tab(text: 'Activity', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildUserSelector(),
          if (loading) const LinearProgressIndicator(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(),
                _buildMyTokensTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── User Selector ──────────────────────────────────────────────────

  Widget _buildUserSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const Icon(Icons.person, size: 20),
          const SizedBox(width: 8),
          const Text('Acting as: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<UserModel>(
              value: selectedUser,
              isExpanded: true,
              items: users
                  .map((u) => DropdownMenuItem(
                        value: u,
                        child: Text('${u.name} (${u.hallName})',
                            style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (u) {
                setState(() => selectedUser = u);
                _refreshAll();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Browse Marketplace ──────────────────────────────────────

  Widget _buildBrowseTab() {
    if (openPosts.isEmpty) {
      return const Center(child: Text('No open listings in your hall.'));
    }
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: openPosts.length,
        itemBuilder: (ctx, i) {
          final post = openPosts[i];
          final isMine = post.sellerId == selectedUser?.id;
          return Card(
            child: ListTile(
              leading: Icon(
                post.mealType == 'LUNCH' ? Icons.lunch_dining : Icons.dinner_dining,
                color: post.mealType == 'LUNCH' ? Colors.orange : Colors.indigo,
                size: 36,
              ),
              title: Text('${post.mealType} — ${post.mealDate}'),
              subtitle: Text(
                '${post.mealMenu ?? "No menu"}\n'
                'Price: ৳${post.mealPrice} • Seller: ${post.sellerName}',
              ),
              isThreeLine: true,
              trailing: isMine
                  ? const Chip(label: Text('Yours'))
                  : FilledButton(
                      onPressed: () => _buyRequest(post),
                      child: const Text('Buy'),
                    ),
            ),
          );
        },
      ),
    );
  }

  // ── Tab 2: My Tokens ───────────────────────────────────────────────

  Widget _buildMyTokensTab() {
    if (myTokens.isEmpty) {
      return const Center(child: Text('You have no tokens.'));
    }
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: myTokens.length,
        itemBuilder: (ctx, i) {
          final token = myTokens[i];
          return Card(
            child: ListTile(
              leading: Icon(
                token.mealType == 'LUNCH'
                    ? Icons.lunch_dining
                    : Icons.dinner_dining,
                color: token.mealType == 'LUNCH' ? Colors.orange : Colors.indigo,
                size: 36,
              ),
              title: Text('${token.mealType} — ${token.mealDate}'),
              subtitle: Text(
                '${token.menu}\n'
                'Price: ৳${token.price} • Status: ${token.status}',
              ),
              isThreeLine: true,
              trailing: token.status == 'AVAILABLE'
                  ? OutlinedButton.icon(
                      onPressed: () => _sellToken(token),
                      icon: const Icon(Icons.sell, size: 18),
                      label: const Text('Sell'),
                    )
                  : Chip(
                      label: Text(token.status),
                      backgroundColor: _statusColor(token.status),
                    ),
            ),
          );
        },
      ),
    );
  }

  // ── Tab 3: Activity ────────────────────────────────────────────────

  Widget _buildActivityTab() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── My Listings ──
          Text('My Listings (${myListings.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          if (myListings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No active listings.'),
            ),
          ...myListings.map(_buildListingCard),

          const SizedBox(height: 24),

          // ── My Purchase Requests ──
          Text('My Purchase Requests (${myPurchases.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          if (myPurchases.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No pending purchase requests.'),
            ),
          ...myPurchases.map(_buildPurchaseCard),
        ],
      ),
    );
  }

  Widget _buildListingCard(MarketplacePostModel post) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  post.mealType == 'LUNCH'
                      ? Icons.lunch_dining
                      : Icons.dinner_dining,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text('${post.mealType} — ${post.mealDate}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Chip(
                  label: Text(post.status),
                  backgroundColor: _statusColor(post.status),
                ),
              ],
            ),
            if (post.status == 'PENDING') ...[
              const SizedBox(height: 8),
              Text('Buyer: ${post.buyerName ?? "Unknown"}'),
              Builder(builder: (_) {
                final remaining = _remainingTime(post.buyerRequestedAt);
                final isExpired = remaining == null || remaining == Duration.zero;
                return Row(
                  children: [
                    Icon(
                      isExpired ? Icons.timer_off : Icons.timer,
                      size: 16,
                      color: isExpired ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExpired
                          ? 'Expired — will auto-rollback'
                          : 'Expires in ${_formatDuration(remaining!)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isExpired ? Colors.red : Colors.orange.shade800,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _confirmTransfer(post),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Confirm'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _rejectRequest(post),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
            if (post.status == 'OPEN') ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _cancelListing(post),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel Listing'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(MarketplacePostModel post) {
    final remaining = _remainingTime(post.buyerRequestedAt);
    final isExpired = remaining == null || remaining == Duration.zero;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${post.mealType} — ${post.mealDate}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Seller: ${post.sellerName}'),
            const SizedBox(height: 8),
            // Countdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isExpired
                    ? Colors.red.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExpired ? Icons.timer_off : Icons.timer,
                    size: 18,
                    color: isExpired ? Colors.red : Colors.orange.shade800,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isExpired
                        ? 'Expired — waiting for auto-rollback'
                        : 'Seller has ${_formatDuration(remaining!)} to confirm',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? Colors.red : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _cancelRequest(post),
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Cancel Request'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green.shade100;
      case 'LISTED':
        return Colors.blue.shade100;
      case 'PENDING':
        return Colors.orange.shade100;
      case 'OPEN':
        return Colors.green.shade100;
      case 'COMPLETED':
        return Colors.grey.shade300;
      case 'USED':
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade200;
    }
  }
}
