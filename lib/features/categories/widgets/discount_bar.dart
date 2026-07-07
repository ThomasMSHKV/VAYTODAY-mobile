import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/categories/presentation/screens/discount_products_screen.dart';

const _discountTitle =
    '\u0422\u043e\u0432\u0430\u0440\u044b \u0438 \u0443\u0441\u043b\u0443\u0433\u0438\n\u0432 \u043e\u0434\u0438\u043d \u043a\u043b\u0438\u043a';

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DiscountProductsScreen()),
          );
        },
        child: Container(
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
                  _discountTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
