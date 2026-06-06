import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/categories/presentation/screens/subcategories_screen.dart';
import 'package:VayToday/features/company_detail/presentation/screens/company_detail_screen.dart';
import 'package:VayToday/features/home/data/home_repository.dart';
import 'package:VayToday/features/home/presentation/cubit/home_cubit.dart';
import 'package:VayToday/features/home/presentation/cubit/home_state.dart';
import 'package:VayToday/features/home/presentation/widgets/add_company_button.dart';
import 'package:VayToday/features/home/presentation/widgets/category_tile.dart';
import 'package:VayToday/features/home/presentation/widgets/home_search_field.dart';
import 'package:VayToday/features/home/presentation/widgets/popular_company_card.dart';
import 'package:VayToday/features/home/presentation/widgets/recommendation_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(HomeRepository())..loadHome(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeFailure) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    color: AppColors.authText,
                    fontSize: 16,
                  ),
                ),
              );
            }

            final loaded = state as HomeLoaded;

            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().loadHome(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [AddCompanyButton()],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Услуги',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: HomeSearchField(),
                    ),

                    const SizedBox(height: 28),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Категории',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 240,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 120 / 140,
                            ),
                        itemCount: loaded.categories.length,
                        itemBuilder: (context, index) {
                          final category = loaded.categories[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SubcategoriesScreen(
                                    categoryTitle: category.title,
                                    services: category.services,
                                    categoryImageUrl: category.imageUrl,
                                  ),
                                ),
                              );
                            },
                            child: CategoryTile(category: category),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 34),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Рекомендации',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    RecommendationCarousel(
                      items: loaded.recommendations,
                      onCompanyTap: (company) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                CompanyDetailScreen(company: company),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 34),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Популярное',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 184,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: loaded.popularCompanies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final company = loaded.popularCompanies[index];

                          return PopularCompanyCard(
                            company: company,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CompanyDetailScreen(company: company),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
