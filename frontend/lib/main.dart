import 'package:flutter/material.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Digital Dining System',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}