import 'package:flutter/material.dart';
import 'package:frontend/core/services/service_locator.dart';
import 'package:frontend/features/auth/screens/login_page.dart';
import 'package:frontend/features/meal_manager/screens/manager_dashboard.dart';
import 'package:frontend/features/student/screens/student_home.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ServiceLocator on all platforms
  // TokenStorage gracefully handles web (SharedPreferences not supported)
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
  String _token = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check stored login status
    final isLoggedIn = await ServiceLocator.tokenStorage.isLoggedIn();
    final token = await ServiceLocator.tokenStorage.getToken();
    final role = await ServiceLocator.tokenStorage.getRole();

    setState(() {
      _isLoggedIn = isLoggedIn;
      _token = token ?? '';
      _userRole = role ?? '';
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

    // Determine home screen based on login status and role
    Widget homeScreen;
    if (!_isLoggedIn) {
      homeScreen = const LoginPage();
    } else if (_userRole.toUpperCase() == 'MEAL_MANAGER' ||
        _userRole.toUpperCase() == 'MANAGER') {
      homeScreen = const ManagerDashboard();
    } else {
      // Default to student home for 'STUDENT' or other roles
      homeScreen = StudentHome(token: _token);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Dining System',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: homeScreen,
      routes: {
        '/login': (_) => const LoginPage(),
        '/student-home': (_) => StudentHome(token: _token),
        '/meal-manager-home': (_) => const ManagerDashboard(),
        '/dining-manager-home': (_) =>
            const _PlaceholderPage(title: 'Dining Manager'),
      },
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Home - Coming Soon')),
    );
  }
}
