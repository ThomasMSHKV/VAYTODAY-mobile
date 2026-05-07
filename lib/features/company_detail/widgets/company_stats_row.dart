import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class CompanyStatsRow extends StatelessWidget {
  final double rating;
  final int reviewsCount;
  final String workingTime;

  const CompanyStatsRow({
    super.key,
    required this.rating,
    required this.reviewsCount,
    required this.workingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          title: rating.toStringAsFixed(1),
          subtitle: 'Оценка',
          icon: const Icon(
            Icons.star_rounded,
            color: AppColors.starYellow,
            size: 20,
          ),
        ),
        _StatItem(title: reviewsCount.toString(), subtitle: 'Отзыва'),
        _StatItem(
          title: workingTime,
          subtitle: 'Время работы',
          titleColor: const Color(0xFFA8C0A8),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? icon;
  final Color? titleColor;

  const _StatItem({
    required this.title,
    required this.subtitle,
    this.icon,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor ?? AppColors.detailTextGreen,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (icon != null) ...[const SizedBox(width: 4), icon!],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.categoryTitle,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
