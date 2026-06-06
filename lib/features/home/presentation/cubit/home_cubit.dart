import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/home/data/home_repository.dart';
import 'package:VayToday/features/home/presentation/cubit/home_state.dart';

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

      emit(HomeFailure('Не удалось загрузить данные: $e'));
    }
  }
}
