import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<HomeCategory> categories;
  final List<CompanyModel> recommendations;
  final List<CompanyModel> popularCompanies;

  const HomeLoaded({
    required this.categories,
    required this.recommendations,
    required this.popularCompanies,
  });
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);
}
