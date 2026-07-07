import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class CompanyInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const CompanyInfoRow({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.detailLightGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.detailTextGreen, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SelectableText(
            title,
            style: const TextStyle(
              color: AppColors.detailTextGreen,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
