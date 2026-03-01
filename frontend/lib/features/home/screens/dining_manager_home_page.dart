import 'package:flutter/material.dart';
import 'package:frontend/core/services/service_locator.dart';

class DiningManagerHomePage extends StatefulWidget {
  const DiningManagerHomePage({super.key});

  @override
  State<DiningManagerHomePage> createState() => _DiningManagerHomePageState();
}

class _DiningManagerHomePageState extends State<DiningManagerHomePage> {
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final email = await ServiceLocator.tokenStorage.getEmail();
    setState(() {
      _userEmail = email;
      _userName = email?.split('@').first ?? 'Manager';
    });
  }

  Future<void> _handleLogout() async {
    await ServiceLocator.tokenStorage.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Dining System - Dining Manager'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(onTap: _handleLogout, child: const Text('Logout')),
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
                Icon(Icons.domain, size: 64, color: scheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Dining Manager Dashboard',
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
                  'This is a placeholder for the dining manager home screen.\nImplement dining hall management features here.',
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
