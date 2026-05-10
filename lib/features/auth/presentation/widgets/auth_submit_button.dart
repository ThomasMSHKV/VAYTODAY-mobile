import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class AuthSubmitButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const AuthSubmitButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 30,
      top: 80,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.authBlack,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.authGold, size: 44),
        ),
      ),
    );
  }
}
