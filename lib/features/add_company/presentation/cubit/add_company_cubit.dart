import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/features/addresses/data/addresses_repository.dart';
import 'package:VayToday/features/add_company/presentation/cubit/add_company_state.dart';
import 'package:VayToday/features/categories/data/categories_repository.dart';
import 'package:VayToday/features/companies/data/companies_repository.dart';
import 'package:VayToday/features/companies/data/company_management_repository.dart';

class AddCompanyCubit extends Cubit<AddCompanyState> {
  final CompaniesRepository _companiesRepository;
  final AddressesRepository _addressesRepository;
  final CategoriesRepository _categoriesRepository;
  final CompanyManagementRepository _managementRepository;

  AddCompanyCubit({
    CompaniesRepository? companiesRepository,
    AddressesRepository? addressesRepository,
    CategoriesRepository? categoriesRepository,
    CompanyManagementRepository? managementRepository,
  }) : _companiesRepository = companiesRepository ?? CompaniesRepository(),
       _addressesRepository = addressesRepository ?? AddressesRepository(),
       _categoriesRepository = categoriesRepository ?? CategoriesRepository(),
       _managementRepository =
           managementRepository ?? CompanyManagementRepository(),
       super(const AddCompanyState());

  Future<void> loadFormData() async {
    emit(state.copyWith(status: AddCompanyStatus.loading, errorMessage: ''));
    try {
      final citiesFuture = _companiesRepository.getCities();
      final addressesFuture = _addressesRepository.getAddresses();
      final categoriesFuture = _categoriesRepository.getCategories();
      final cities = await citiesFuture;
      final addresses = await addressesFuture;
      final categories = await categoriesFuture;
      emit(
        state.copyWith(
          status: AddCompanyStatus.ready,
          cities: cities,
          addresses: addresses,
          categories: categories,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AddCompanyStatus.failure,
          errorMessage: 'Не удалось загрузить данные для формы',
        ),
      );
    }
  }

  Future<void> createCompany(CreateCompanyRequest request) async {
    if (state.status == AddCompanyStatus.submitting) return;

    emit(state.copyWith(status: AddCompanyStatus.submitting, errorMessage: ''));
    try {
      final company = await _managementRepository.createCompany(request);
      emit(state.copyWith(status: AddCompanyStatus.success, company: company));
    } catch (error) {
      emit(
        state.copyWith(
          status: AddCompanyStatus.failure,
          errorMessage: error is CompanyManagementException
              ? error.message
              : 'Не удалось добавить компанию',
        ),
      );
    }
  }
}
