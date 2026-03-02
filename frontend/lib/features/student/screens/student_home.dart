import 'package:flutter/material.dart';
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
    _apiService = StudentApiService(token: widget.token);
    _screens = [
      DashboardScreen(apiService: _apiService),
      QrScreen(apiService: _apiService),
      MarketplaceScreen(apiService: _apiService),
      HistoryScreen(apiService: _apiService),
    ];
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