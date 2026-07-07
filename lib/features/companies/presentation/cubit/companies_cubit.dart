import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/companies/data/companies_repository.dart';
import 'package:VayToday/features/companies/domain/models/city_model.dart';
import 'package:VayToday/features/companies/presentation/cubit/companies_state.dart';

const _companiesLoadError =
    '\u041d\u0435 \u0443\u0434\u0430\u043b\u043e\u0441\u044c \u0437\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u044c \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0438';

class CompaniesCubit extends Cubit<CompaniesState> {
  final CompaniesRepository _repository;
  List<CityModel> _cities = const [];

  CompaniesCubit(this._repository) : super(const CompaniesInitial());

  Future<void> loadCompaniesByServiceId(int serviceId) async {
    emit(const CompaniesLoading());

    try {
      _cities = await _repository.getCities();
      final companies = await _repository.getCompaniesByServiceId(serviceId);

      emit(CompaniesLoaded(companies: companies, cities: _cities));
    } catch (_) {
      emit(const CompaniesFailure(_companiesLoadError));
    }
  }

  Future<void> searchCompaniesByServiceId({
    required int serviceId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      await loadCompaniesByServiceId(serviceId);
      return;
    }

    emit(
      CompaniesLoaded(companies: const [], cities: _cities, isSearching: true),
    );

    try {
      if (_cities.isEmpty) {
        _cities = await _repository.getCities();
      }
      final companies = await _repository.searchCompaniesByServiceId(
        serviceId: serviceId,
        query: query,
      );

      emit(CompaniesLoaded(companies: companies, cities: _cities));
    } catch (_) {
      emit(CompaniesLoaded(companies: const [], cities: _cities));
    }
  }
}
