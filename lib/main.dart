import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/main_navigation/presentation/screens/main_navigation_screen.dart';

void main() {
  runApp(const VayTodayApp());
}

class VayTodayApp extends StatelessWidget {
  const VayTodayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VayToday',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}