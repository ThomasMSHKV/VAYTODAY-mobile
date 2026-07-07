import 'package:VayToday/features/home/domain/models/home_category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class CategoryTile extends StatelessWidget {
  final HomeCategory category;

  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.categoryCardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 7,
            right: 7,
            child: Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.categoryTitle,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 40,
            bottom: -6,
            child: CachedNetworkImage(
              imageUrl: category.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.categoryCardBackground),
              errorWidget: (context, url, error) {
                return Container(
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_outlined, size: 30),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
