import 'package:VayToday/features/home/domain/models/home_category.dart';

abstract class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<HomeCategory> categories;

  const CategoriesLoaded({required this.categories});
}

class CategoriesFailure extends CategoriesState {
  final String message;

  const CategoriesFailure(this.message);
}
