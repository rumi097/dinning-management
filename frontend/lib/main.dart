import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/service_locator.dart';
import 'package:frontend/features/student/screens/student_home.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Skip ServiceLocator initialization on web (shared_preferences not supported)
  if (!kIsWeb) {
    await ServiceLocator.init();
  }
  
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
  String _token = 'dev-token';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    if (kIsWeb) {
      // On web, go directly to student home with dev token
      setState(() {
        _isLoggedIn = true;
        _token = 'dev-token';
        _isInitialized = true;
      });
      return;
    }
    
    final isLoggedIn = await ServiceLocator.tokenStorage.isLoggedIn();
    if (isLoggedIn) {
      final token = await ServiceLocator.tokenStorage.getToken();
      setState(() {
        _isLoggedIn = true;
        _token = token ?? 'dev-token';
        _isInitialized = true;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
        _isInitialized = true;
      });
    }
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
      home: _isLoggedIn 
          ? StudentHome(token: _token)
          : const LoginPlaceholder(),
    );
  }
}

class LoginPlaceholder extends StatelessWidget {
  const LoginPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Dining System')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Please login',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: scheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
