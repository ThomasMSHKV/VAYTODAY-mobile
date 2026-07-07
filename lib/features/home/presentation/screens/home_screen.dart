import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/categories/presentation/screens/subcategories_screen.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/companies/presentation/widgets/company_list_card.dart';
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

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final HomeRepository _searchRepository = HomeRepository();
  Timer? _searchDebounce;
  String _searchQuery = '';
  List<CompanyModel> _searchCompanies = const [];
  bool _isSearchLoading = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();

    setState(() {
      _searchQuery = value;
      if (query.isEmpty) {
        _searchCompanies = const [];
        _isSearchLoading = false;
      } else {
        _isSearchLoading = true;
      }
    });

    if (query.isEmpty) return;

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _searchCompaniesByQuery(query);
    });
  }

  Future<void> _searchCompaniesByQuery(String query) async {
    try {
      final companies = await _searchRepository.searchCompanies(query);
      if (!mounted || _searchQuery.trim() != query) return;

      setState(() {
        _searchCompanies = companies;
        _isSearchLoading = false;
      });
    } catch (_) {
      if (!mounted || _searchQuery.trim() != query) return;

      setState(() {
        _searchCompanies = const [];
        _isSearchLoading = false;
      });
    }
  }

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
            final isSearching = _searchQuery.trim().isNotEmpty;

            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().loadHome(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [AddCompanyButton()],
                      ),
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: HomeSearchField(onChanged: _onSearchChanged),
                    ),
                    const SizedBox(height: 24),
                    if (isSearching)
                      _buildSearchResults(_searchCompanies)
                    else
                      _buildDefaultHome(context, loaded),
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

  Widget _buildSearchResults(List<CompanyModel> companies) {
    if (_isSearchLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 80, 20, 0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (companies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 80, 20, 0),
        child: Center(
          child: Text(
            'Компании не найдены',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Результаты поиска',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: companies.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return CompanyListCard(company: companies[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultHome(BuildContext context, HomeLoaded loaded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Категории',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 212,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemCount: loaded.categories.length,
            itemBuilder: (context, index) {
              final category = loaded.categories[index];
              return InkWell(
                borderRadius: BorderRadius.circular(20),
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
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Рекомендации',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        RecommendationCarousel(
          items: loaded.recommendations,
          onCompanyTap: (company) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CompanyDetailScreen(company: company),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Популярное',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 184,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: loaded.popularCompanies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final company = loaded.popularCompanies[index];
              return PopularCompanyCard(
                company: company,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompanyDetailScreen(company: company),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
