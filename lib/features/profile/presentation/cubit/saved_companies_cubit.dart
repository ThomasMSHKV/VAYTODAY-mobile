import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/profile/data/profile_repository.dart';
import 'package:VayToday/features/profile/presentation/cubit/saved_companies_state.dart';

class SavedCompaniesCubit extends Cubit<SavedCompaniesState> {
  final ProfileRepository _repository;

  SavedCompaniesCubit(this._repository) : super(const SavedCompaniesInitial());

  Future<void> loadSavedCompanies() async {
    emit(const SavedCompaniesLoading());

    try {
      final companies = await _repository.getFavoriteCompanies();
      emit(SavedCompaniesLoaded(companies));
    } catch (_) {
      emit(
        const SavedCompaniesFailure(
          'Не удалось загрузить сохраненные компании',
        ),
      );
    }
  }
}
