import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/categories/widgets/subcategory_grid_card.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

class SubcategoriesScreen extends StatelessWidget {
  final String categoryTitle;
  final String categoryImageUrl;
  final List<HomeService> services;

  const SubcategoriesScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryImageUrl,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.categoriesHeader,
        elevation: 0,
        centerTitle: false,
        title: Text(
          categoryTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: services.isEmpty
          ? const Center(
              child: Text(
                'Подкатегории пока не добавлены',
                style: TextStyle(color: AppColors.categoryTitle, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                return SubcategoryGridCard(
                  service: services[index],
                  imageUrl: categoryImageUrl,
                );
              },
            ),
    );
  }
}
