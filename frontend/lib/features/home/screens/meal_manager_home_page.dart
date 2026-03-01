import 'package:flutter/material.dart';
import 'package:frontend/core/storage/token_storage.dart';

class MealManagerHomePage extends StatefulWidget {
  const MealManagerHomePage({super.key});

  @override
  State<MealManagerHomePage> createState() => _MealManagerHomePageState();
}

class _MealManagerHomePageState extends State<MealManagerHomePage> {
  late final TokenStorage _tokenStorage;
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final email = await _tokenStorage.getEmail();
    setState(() {
      _userEmail = email;
      _userName = email?.split('@').first ?? 'Manager';
    });
  }

  Future<void> _handleLogout() async {
    await _tokenStorage.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Dining System - Meal Manager'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _handleLogout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: scheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Meal Manager Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome, ${_userName ?? 'Manager'}!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_userEmail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _userEmail!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'This is a placeholder for the meal manager home screen.\nImplement meal management features here.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
