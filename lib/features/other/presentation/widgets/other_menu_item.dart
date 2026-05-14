import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class OtherMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const OtherMenuItem({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromARGB(25, 128, 128, 128),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.authText,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
