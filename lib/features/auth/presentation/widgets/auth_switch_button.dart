import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class AuthSwitchButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const AuthSwitchButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 148,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.authCard,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(34),
              bottomRight: Radius.circular(34),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.authGold,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
