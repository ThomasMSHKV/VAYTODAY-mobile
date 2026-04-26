import 'package:VayToday/features/home/data/home_mock_data.dart';
import 'package:VayToday/features/home/presentation/widgets/add_company_button.dart';
import 'package:VayToday/features/home/presentation/widgets/category_tile.dart';
import 'package:VayToday/features/home/presentation/widgets/home_search_field.dart';
import 'package:VayToday/features/home/presentation/widgets/popular_company_card.dart';
import 'package:VayToday/features/home/presentation/widgets/recommendation_carousel.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Верхняя кнопка
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [AddCompanyButton()],
                ),
              ),

              const SizedBox(height: 18),

              /// Заголовок
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Услуги',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              /// Поиск (с отступами!)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: HomeSearchField(),
              ),

              const SizedBox(height: 28),

              /// Категории заголовок
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

              const SizedBox(height: 18),

              SizedBox(
                height: 240, // 👈 общая высота под 2 ряда
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 👈 2 строки
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 120 / 140, // 👈 важно под размер карточки
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryTile(category: categories[index]);
                  },
                ),
              ),

              const SizedBox(height: 34),

              /// Рекомендации заголовок
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

              const SizedBox(height: 18),

              /// Карусель — ВАЖНО: без padding
              RecommendationCarousel(items: recommendations),

              const SizedBox(height: 34),

              /// Популярное заголовок
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

              const SizedBox(height: 18),

              /// Популярное список
              SizedBox(
                height: 184,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: popularCompanies.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    return PopularCompanyCard(company: popularCompanies[index]);
                  },
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
