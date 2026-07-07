import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/profile/data/profile_repository.dart';
import 'package:VayToday/features/profile/presentation/cubit/saved_companies_state.dart';

class SavedCompaniesCubit extends Cubit<SavedCompaniesState> {
  final ProfileRepository _repository;

  SavedCompaniesCubit(this._repository) : super(const SavedCompaniesInitial());

  Future<void> loadSavedCompanies() async {
    final cachedCompanies = await _repository.getCachedFavoriteCompanies();
    if (cachedCompanies.isEmpty) {
      emit(const SavedCompaniesLoading());
    } else {
      emit(SavedCompaniesLoaded(cachedCompanies));
    }

    try {
      final companies = await _repository.getFavoriteCompanies();
      emit(SavedCompaniesLoaded(companies));
    } catch (_) {
      if (cachedCompanies.isNotEmpty) return;

      emit(
        const SavedCompaniesFailure(
          'Не удалось загрузить сохраненные компании',
        ),
      );
    }
  }
}
