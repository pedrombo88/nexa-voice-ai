import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NexaApp());
}

class NexaApp extends StatelessWidget {
  const NexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEXA Voice AI',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}