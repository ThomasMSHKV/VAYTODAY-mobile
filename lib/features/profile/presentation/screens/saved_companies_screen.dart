import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/companies/presentation/widgets/company_list_card.dart';
import 'package:VayToday/features/profile/data/profile_repository.dart';
import 'package:VayToday/features/profile/presentation/cubit/saved_companies_cubit.dart';
import 'package:VayToday/features/profile/presentation/cubit/saved_companies_state.dart';

class SavedCompaniesScreen extends StatelessWidget {
  const SavedCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SavedCompaniesCubit(ProfileRepository())..loadSavedCompanies(),
      child: const _SavedCompaniesView(),
    );
  }
}

class _SavedCompaniesView extends StatelessWidget {
  const _SavedCompaniesView();

  Future<void> _refresh(BuildContext context) {
    return context.read<SavedCompaniesCubit>().loadSavedCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: BlocBuilder<SavedCompaniesCubit, SavedCompaniesState>(
          builder: (context, state) {
            final companies = state is SavedCompaniesLoaded
                ? state.companies
                : const <CompanyModel>[];

            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 22, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.categoryTitle,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              'Сохраненные компании',
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
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  if (state is SavedCompaniesInitial ||
                      state is SavedCompaniesLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is SavedCompaniesFailure)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (companies.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            'Пока нет сохраненных компаний',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                      sliver: SliverList.separated(
                        itemCount: companies.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return CompanyListCard(
                            company: companies[index],
                            isCompact: true,
                          );
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
