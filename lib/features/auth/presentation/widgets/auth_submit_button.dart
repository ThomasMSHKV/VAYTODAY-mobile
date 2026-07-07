import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class AuthSubmitButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isEnabled;
  final double top;
  final double right;

  const AuthSubmitButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
    this.top = 100,
    this.right = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      top: top,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isEnabled ? 1 : 0.35,
          child: Container(
            width: 65,
            height: 65,
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
      ),
    );
  }
}
