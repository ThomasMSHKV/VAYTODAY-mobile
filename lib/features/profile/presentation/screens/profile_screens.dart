import 'package:flutter/material.dart';
import 'package:VayToday/features/auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const bool _isAuthorized = false;

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return const LoginScreen();
    }

    return const Scaffold(body: Center(child: Text('Профиль')));
  }
}
