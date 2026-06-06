import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class ReviewStars extends StatelessWidget {
  final double rating;
  final double size;
  final double spacing;

  const ReviewStars({
    super.key,
    required this.rating,
    this.size = 28,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isSelected = rating >= index + 1;

        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : spacing),
          child: Icon(
            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
            color: isSelected
                ? AppColors.favoriteYellow
                : AppColors.detailTextGreen,
            size: size,
          ),
        );
      }),
    );
  }
}
