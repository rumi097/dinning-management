import 'package:flutter/material.dart';
import 'package:frontend/core/services/service_locator.dart';
import '../services/student_api_service.dart';
import 'dashboard_screen.dart';
import 'marketplace_screen.dart';
import 'history_screen.dart';
import 'qr_screen.dart';

class StudentHome extends StatefulWidget {
  final String token;

  const StudentHome({super.key, required this.token});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _currentIndex = 0;
  late final StudentApiService _apiService;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _apiService = StudentApiService.withClient(ServiceLocator.apiClient);
    _screens = [
      DashboardScreen(apiService: _apiService, onLogout: _logout),
      QrScreen(apiService: _apiService, onLogout: _logout),
      MarketplaceScreen(apiService: _apiService, onLogout: _logout),
      HistoryScreen(apiService: _apiService, onLogout: _logout),
    ];
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ServiceLocator.tokenStorage.clearAll();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_2_outlined),
            selectedIcon: Icon(Icons.qr_code_2),
            label: 'My Tokens',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'History',
          ),
        ],
      ),
    );
  }
}