import 'package:VayToday/features/home/data/home_mock_data.dart';
import 'package:VayToday/features/home/presentation/widgets/add_company_button.dart';
import 'package:VayToday/features/home/presentation/widgets/category_tile.dart';
import 'package:VayToday/features/home/presentation/widgets/home_search_field.dart';
import 'package:VayToday/features/home/presentation/widgets/popular_company_card.dart';
import 'package:VayToday/features/home/presentation/widgets/recommendation_carousel.dart';
import 'package:VayToday/features/home/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = HomeMockData.categories;
    final recommendations = HomeMockData.recommendations;
    final popularCompanies = HomeMockData.popularCompanies;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AddCompanyButton(),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Услуги',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 22),
              const HomeSearchField(),
              const SizedBox(height: 28),
              const SectionHeader(title: 'Категории'),
              const SizedBox(height: 18),
              SizedBox(
                height: 182,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    return CategoryTile(category: categories[index]);
                  },
                ),
              ),
              const SizedBox(height: 34),
              const SectionHeader(title: 'Рекомендации'),
              const SizedBox(height: 18),
              RecommendationCarousel(items: recommendations),
              const SizedBox(height: 34),
              SectionHeader(
                title: 'Популярное',
                actionText: 'Все',
                onActionTap: () {},
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 278,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularCompanies.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return PopularCompanyCard(
                      company: popularCompanies[index],
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