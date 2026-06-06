import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/categories/presentation/screens/subcategories_screen.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

class CategoryGridCard extends StatelessWidget {
  final HomeCategory category;

  const CategoryGridCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SubcategoriesScreen(
                categoryTitle: category.title,
                categoryImageUrl: category.imageUrl,
                services: category.services,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.categoryCardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 8,
                right: 8,
                child: Text(
                  category.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.categoryTitle,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 48,
                bottom: -8,
                child: Image.network(
                  category.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined, size: 34),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
