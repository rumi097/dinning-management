import 'package:flutter/material.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/screens/login_page.dart';
import 'package:frontend/features/home/screens/dining_manager_home_page.dart';
import 'package:frontend/features/home/screens/meal_manager_home_page.dart';
import 'package:frontend/features/home/screens/student_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStorage = TokenStorage();
  await tokenStorage.init();
  runApp(DiningApp(tokenStorage: tokenStorage));
}

class DiningApp extends StatefulWidget {
  final TokenStorage tokenStorage;

  const DiningApp({super.key, required this.tokenStorage});

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
    final isLoggedIn = await widget.tokenStorage.isLoggedIn();
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
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue.shade200,
              ),
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
      initialRoute: _isLoggedIn ? '/student-home' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/student-home': (context) => const StudentHomePage(),
        '/meal-manager-home': (context) => const MealManagerHomePage(),
        '/dining-manager-home': (context) => const DiningManagerHomePage(),
      },
    );
  }
}
