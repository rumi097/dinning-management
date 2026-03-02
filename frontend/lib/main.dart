import 'package:flutter/material.dart';
import 'package:frontend/core/services/service_locator.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/screens/login_page.dart';
import 'package:frontend/features/home/screens/dining_manager_home_page.dart';
import 'package:frontend/features/home/screens/meal_manager_home_page.dart';
import 'package:frontend/features/home/screens/student_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  runApp(const DiningApp());
}

class DiningApp extends StatefulWidget {
  const DiningApp({super.key});

  @override
  State<DiningApp> createState() => _DiningAppState();
}

class _DiningAppState extends State<DiningApp> {
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await ServiceLocator.tokenStorage.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade200),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Dining System',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: _isLoggedIn ? const StudentHomePage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/student-home': (context) => const StudentHomePage(),
        '/meal-manager-home': (context) => const MealManagerHomePage(),
        '/dining-manager-home': (context) => const DiningManagerHomePage(),
      },
    );
  }
}
