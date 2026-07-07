import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/add_company/presentation/screens/add_company_screen.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_required_action.dart';
import 'package:VayToday/features/company_management/presentation/screens/company_management_screen.dart';
import 'package:VayToday/features/companies/data/company_management_repository.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/companies/presentation/widgets/company_list_card.dart';
import 'package:VayToday/features/my_companies/presentation/cubit/my_companies_cubit.dart';
import 'package:VayToday/features/my_companies/presentation/cubit/my_companies_state.dart';

class MyCompaniesScreen extends StatelessWidget {
  const MyCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MyCompaniesCubit(CompanyManagementRepository())..loadCompanies(),
      child: const _MyCompaniesView(),
    );
  }
}

class _MyCompaniesView extends StatelessWidget {
  const _MyCompaniesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          child: Column(
            children: [
              BlocBuilder<MyCompaniesCubit, MyCompaniesState>(
                builder: (context, state) {
                  final hasCompanies =
                      state is MyCompaniesLoaded && state.companies.isNotEmpty;
                  return _buildHeader(context, showAddButton: hasCompanies);
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<MyCompaniesCubit, MyCompaniesState>(
                  builder: (context, state) {
                    if (state is MyCompaniesLoading ||
                        state is MyCompaniesInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is MyCompaniesFailure) {
                      return _EmptyCompaniesView(
                        onAddTap: () => _openAddCompanyScreen(context),
                      );
                    }

                    final companies = (state as MyCompaniesLoaded).companies;
                    if (companies.isEmpty) {
                      return _EmptyCompaniesView(
                        onAddTap: () => _openAddCompanyScreen(context),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: context.read<MyCompaniesCubit>().loadCompanies,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        itemCount: companies.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final company = companies[index];
                          return _MyCompanyCard(
                            company: company,
                            onManageTap: () =>
                                _openCompanyManagement(context, company),
                          );
                        },
                      ),
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

  Widget _buildHeader(BuildContext context, {required bool showAddButton}) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Мои компании',
            style: TextStyle(
              color: AppColors.authText,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (showAddButton)
          _AddCompanyActionButton(onTap: () => _openAddCompanyScreen(context)),
      ],
    );
  }

  Future<void> _openAddCompanyScreen(BuildContext context) async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddCompanyScreen()));
    if (created == true && context.mounted) {
      await context.read<MyCompaniesCubit>().loadCompanies();
    }
  }

  Future<void> _openCompanyManagement(
    BuildContext context,
    CompanyModel company,
  ) async {
    await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => CompanyManagementScreen(company: company),
      ),
    );
    if (context.mounted) {
      await context.read<MyCompaniesCubit>().loadCompanies();
    }
  }
}

class _MyCompanyCard extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onManageTap;

  const _MyCompanyCard({required this.company, required this.onManageTap});

  @override
  Widget build(BuildContext context) {
    final isApproved = company.isActive;
    return CompanyListCard(
      company: company,
      statusLabel: isApproved ? 'Одобрено' : 'В обработке',
      statusColor: isApproved
          ? AppColors.moderationApproved
          : AppColors.moderationPending,
      footerAction: _ManageCompanyButton(onTap: onManageTap),
    );
  }
}

class _ManageCompanyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ManageCompanyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.detailTextGreen,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, color: AppColors.white, size: 15),
              SizedBox(width: 5),
              Text(
                'Управлять',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCompaniesView extends StatelessWidget {
  final VoidCallback onAddTap;

  const _EmptyCompaniesView({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'У вас пока нет компании, создайте ее',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          _AddCompanyActionButton(onTap: onAddTap),
        ],
      ),
    );
  }
}

class _AddCompanyActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCompanyActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AuthRequiredAction(
      dialogMessage: 'Чтобы добавить компанию, необходимо войти в аккаунт.',
      onAuthorized: onTap,
      builder: (context, onTap, isChecking) {
        return IconButton.filled(
          tooltip: 'Добавить компанию',
          onPressed: isChecking ? null : onTap,
          style: IconButton.styleFrom(
            fixedSize: const Size(58, 58),
            backgroundColor: AppColors.authGold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: isChecking
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.add_rounded,
                  color: AppColors.detailTextGreen,
                  size: 34,
                ),
        );
      },
    );
  }
}
