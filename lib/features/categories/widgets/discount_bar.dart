import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.categoryCardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -18,
            child: Text(
              '%',
              style: TextStyle(
                color: AppColors.discountPurple.withValues(alpha: 0.9),
                fontSize: 150,
                height: 0.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          Positioned(
            left: 24,
            top: 42,
            child: Text(
              'Товары и услуги\nсо скидками',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontSize: 20,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Positioned(
          //   right: 82,
          //   bottom: -12,
          //   child: Text(
          //     '%',
          //     style: TextStyle(
          //       color: AppColors.discountPurple.withValues(alpha: 0.75),
          //       fontSize: 112,
          //       height: 0.8,
          //       fontWeight: FontWeight.w900,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
