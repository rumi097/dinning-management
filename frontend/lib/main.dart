import 'package:flutter/material.dart';
import 'package:frontend/features/student/screens/student_home.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const DiningApp());
}

class DiningApp extends StatelessWidget {
  const DiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Dining System',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      // TODO: Replace with actual auth flow — for now uses a dev token
      home: const StudentHome(token: 'dev-token'),
    );
  }
}
