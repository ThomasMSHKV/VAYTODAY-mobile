import 'package:VayToday/features/categories/widgets/subcategory_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/categories/data/subcategories_mock_data.dart';

class SubcategoriesScreen extends StatelessWidget {
  final String categoryTitle;

  const SubcategoriesScreen({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    final subcategories = SubcategoriesMockData.getByCategory(categoryTitle);

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
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        itemCount: subcategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          return SubcategoryGridCard(subcategory: subcategories[index]);
        },
      ),
    );
  }
}
