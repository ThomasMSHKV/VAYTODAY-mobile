import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/features/companies/data/company_management_repository.dart';
import 'package:VayToday/features/my_companies/presentation/cubit/my_companies_state.dart';

class MyCompaniesCubit extends Cubit<MyCompaniesState> {
  final CompanyManagementRepository _repository;

  MyCompaniesCubit(this._repository) : super(const MyCompaniesInitial());

  Future<void> loadCompanies() async {
    final cachedCompanies = await _repository.getCachedMyCompanies();
    if (cachedCompanies.isEmpty) {
      emit(const MyCompaniesLoading());
    } else {
      emit(MyCompaniesLoaded(cachedCompanies));
    }

    try {
      final companies = await _repository.getMyCompanies();
      emit(MyCompaniesLoaded(companies));
    } catch (error) {
      if (cachedCompanies.isNotEmpty) return;

      emit(
        MyCompaniesFailure(
          error is CompanyManagementException
              ? error.message
              : 'Не удалось загрузить ваши компании',
        ),
      );
    }
  }
}
