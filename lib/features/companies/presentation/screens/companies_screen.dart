import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/data/companies_repository.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/companies/presentation/cubit/companies_cubit.dart';
import 'package:VayToday/features/companies/presentation/cubit/companies_state.dart';
import 'package:VayToday/features/companies/presentation/widgets/city_filter_chip.dart';
import 'package:VayToday/features/companies/presentation/widgets/companies_search_field.dart';
import 'package:VayToday/features/companies/presentation/widgets/company_list_card.dart';

const _allTitle = '\u0412\u0441\u0435';
const _emptyCompaniesTitle =
    '\u041a\u043e\u043c\u043f\u0430\u043d\u0438\u0438 \u043d\u0435 \u043d\u0430\u0439\u0434\u0435\u043d\u044b';

class CompaniesScreen extends StatelessWidget {
  final String subcategoryTitle;
  final int serviceId;

  const CompaniesScreen({
    super.key,
    required this.subcategoryTitle,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CompaniesCubit(CompaniesRepository())
            ..loadCompaniesByServiceId(serviceId),
      child: _CompaniesView(
        subcategoryTitle: subcategoryTitle,
        serviceId: serviceId,
      ),
    );
  }
}

class _CompaniesView extends StatefulWidget {
  final String subcategoryTitle;
  final int serviceId;

  const _CompaniesView({
    required this.subcategoryTitle,
    required this.serviceId,
  });

  @override
  State<_CompaniesView> createState() => _CompaniesViewState();
}

class _CompaniesViewState extends State<_CompaniesView> {
  Timer? _searchDebounce;
  String _searchQuery = '';
  int? _selectedCityId;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  List<CompanyModel> _filterCompaniesByCity(List<CompanyModel> companies) {
    return companies.where((company) {
      return _selectedCityId == null ||
          company.cities.contains(_selectedCityId);
    }).toList();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();

    setState(() => _searchQuery = value);

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final cubit = context.read<CompaniesCubit>();
      if (query.isEmpty) {
        cubit.loadCompaniesByServiceId(widget.serviceId);
      } else {
        cubit.searchCompaniesByServiceId(
          serviceId: widget.serviceId,
          query: query,
        );
      }
    });
  }

  Future<void> _refreshCompanies() {
    final cubit = context.read<CompaniesCubit>();
    final query = _searchQuery.trim();
    if (query.isEmpty) {
      return cubit.loadCompaniesByServiceId(widget.serviceId);
    }

    return cubit.searchCompaniesByServiceId(
      serviceId: widget.serviceId,
      query: query,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: BlocBuilder<CompaniesCubit, CompaniesState>(
          builder: (context, state) {
            if (state is CompaniesInitial || state is CompaniesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CompaniesFailure) {
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

            final loaded = state as CompaniesLoaded;
            final companies = _filterCompaniesByCity(loaded.companies);

            return RefreshIndicator(
              onRefresh: _refreshCompanies,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 22, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.categoryTitle,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              widget.subcategoryTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CompaniesSearchField(onChanged: _onSearchChanged),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 34,
                      child: ListView.separated(
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: loaded.cities.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return CityFilterChip(
                              title: _allTitle,
                              isSelected: _selectedCityId == null,
                              onTap: () {
                                setState(() {
                                  _selectedCityId = null;
                                });
                              },
                            );
                          }

                          final city = loaded.cities[index - 1];

                          return CityFilterChip(
                            title: city.name,
                            isSelected: _selectedCityId == city.id,
                            onTap: () {
                              setState(() {
                                _selectedCityId = city.id;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                  if (loaded.isSearching)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (companies.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          _emptyCompaniesTitle,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      sliver: SliverList.separated(
                        itemCount: companies.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return CompanyListCard(company: companies[index]);
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
