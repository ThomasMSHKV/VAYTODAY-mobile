import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/categories/data/categories_repository.dart';
import 'package:VayToday/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:VayToday/features/categories/presentation/cubit/categories_state.dart';
import 'package:VayToday/features/categories/widgets/categories_app_bar.dart';
import 'package:VayToday/features/categories/widgets/category_grid_card.dart';
import 'package:VayToday/features/categories/widgets/discount_bar.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit(CategoriesRepository())..loadCategories(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading || state is CategoriesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoriesFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.authText, fontSize: 16),
              ),
            );
          }

          final loaded = state as CategoriesLoaded;

          return RefreshIndicator(
            onRefresh: () => context.read<CategoriesCubit>().loadCategories(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const CategoriesAppBar(),
                const SliverToBoxAdapter(child: SizedBox(height: 56)),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: DiscountBanner()),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverGrid.builder(
                    itemCount: loaded.categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                    itemBuilder: (context, index) {
                      return CategoryGridCard(
                        category: loaded.categories[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
