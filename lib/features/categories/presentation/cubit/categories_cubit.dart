import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/categories/data/categories_repository.dart';
import 'package:VayToday/features/categories/presentation/cubit/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepository _repository;

  CategoriesCubit(this._repository) : super(const CategoriesInitial());

  Future<void> loadCategories() async {
    emit(const CategoriesLoading());

    try {
      final categories = await _repository.getCategories();

      emit(CategoriesLoaded(categories: categories));
    } catch (e, stackTrace) {
      debugPrint('CATEGORIES API ERROR: $e');
      debugPrint('CATEGORIES STACK: $stackTrace');

      emit(CategoriesFailure('Не удалось загрузить категории: $e'));
    }
  }
}
