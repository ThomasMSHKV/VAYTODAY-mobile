import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/companies/data/companies_repository.dart';
import 'package:VayToday/features/companies/presentation/cubit/companies_state.dart';

class CompaniesCubit extends Cubit<CompaniesState> {
  final CompaniesRepository _repository;

  CompaniesCubit(this._repository) : super(const CompaniesInitial());

  Future<void> loadCompaniesByServiceId(int serviceId) async {
    emit(const CompaniesLoading());

    try {
      final cities = await _repository.getCities();
      final companies = await _repository.getCompaniesByServiceId(serviceId);

      emit(CompaniesLoaded(companies: companies, cities: cities));
    } catch (_) {
      emit(const CompaniesFailure('Не удалось загрузить компании'));
    }
  }
}
