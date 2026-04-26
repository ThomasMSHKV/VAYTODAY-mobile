import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class CategoriesAppBar extends StatelessWidget {
  const CategoriesAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      backgroundColor: AppColors.categoriesHeader,
      automaticallyImplyLeading: false,
      pinned: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Категории',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
