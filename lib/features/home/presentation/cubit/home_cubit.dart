import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/home/data/home_repository.dart';
import 'package:VayToday/features/home/presentation/cubit/home_state.dart';

const _homeLoadErrorMessage =
    '\u041d\u0435 \u0443\u0434\u0430\u043b\u043e\u0441\u044c \u0437\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u044c \u0434\u0430\u043d\u043d\u044b\u0435';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(const HomeInitial());

  Future<void> loadHome() async {
    emit(const HomeLoading());

    try {
      final categoriesFuture = _repository.getCategories();
      final recommendationsFuture = _repository.getRecommendedCompanies();
      final popularCompaniesFuture = _repository.getPopularCompanies();

      final categories = await categoriesFuture;
      final recommendations = await recommendationsFuture;
      final popularCompanies = await popularCompaniesFuture;

      emit(
        HomeLoaded(
          categories: categories,
          recommendations: recommendations,
          popularCompanies: popularCompanies,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('HOME API ERROR: $e');
      debugPrint('HOME STACK: $stackTrace');

      emit(HomeFailure('$_homeLoadErrorMessage: $e'));
    }
  }
}
