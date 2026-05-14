import 'package:flutter/material.dart';
import 'package:VayToday/features/auth/presentation/screens/login_screen.dart';
import 'package:VayToday/features/other/presentation/screens/other_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const bool _isAuthorized = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_isAuthorized)
          const LoginScreen()
        else
          const Scaffold(body: Center(child: Text('Профиль'))),

        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 18, right: 22),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OtherScreen()),
                  );
                },
                child: const Icon(
                  Icons.menu_rounded,
                  size: 42,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
