import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/data/companies_mock_data.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/companies/presentation/widgets/city_filter_chip.dart';
import 'package:VayToday/features/companies/presentation/widgets/companies_search_field.dart';
import 'package:VayToday/features/companies/presentation/widgets/company_list_card.dart';

class CompaniesScreen extends StatefulWidget {
  final String subcategoryTitle;

  const CompaniesScreen({super.key, required this.subcategoryTitle});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final List<String> _cities = const [
    'Все города',
    'Назрань',
    'Магас',
    'Сунжа',
  ];

  String _selectedCity = 'Все города';
  String _searchQuery = '';

  List<CompanyModel> get _filteredCompanies {
    return CompaniesMockData.companies.where((company) {
      final matchesCity =
          _selectedCity == 'Все города' || company.city == _selectedCity;

      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          company.title.toLowerCase().contains(query) ||
          company.description.toLowerCase().contains(query) ||
          company.city.toLowerCase().contains(query);

      return matchesCity && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final companies = _filteredCompanies;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.categoryTitle,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                widget.subcategoryTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: CompaniesSearchField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.categoryTitle,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 56,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _cities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final city = _cities[index];

                  return CityFilterChip(
                    title: city,
                    isSelected: _selectedCity == city,
                    onTap: () {
                      setState(() {
                        _selectedCity = city;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 2),

            Expanded(
              child: companies.isEmpty
                  ? const Center(child: Text('Компании не найдены'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: companies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return CompanyListCard(company: companies[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
