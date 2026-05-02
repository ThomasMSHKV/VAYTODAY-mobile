import 'package:VayToday/features/categories/widgets/categories_app_bar.dart';
import 'package:VayToday/features/categories/widgets/category_grid_card.dart';
import 'package:VayToday/features/categories/widgets/discount_bar.dart';
import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/categories/data/categories_mock_data.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = CategoriesMockData.categories;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: CustomScrollView(
        slivers: [
          const CategoriesAppBar(),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),

          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: DiscountBanner()),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverGrid.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                return CategoryGridCard(category: categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
