import 'package:VayToday/features/companies/domain/models/city_model.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';

abstract class CompaniesState {
  const CompaniesState();
}

class CompaniesInitial extends CompaniesState {
  const CompaniesInitial();
}

class CompaniesLoading extends CompaniesState {
  const CompaniesLoading();
}

class CompaniesLoaded extends CompaniesState {
  final List<CompanyModel> companies;
  final List<CityModel> cities;

  const CompaniesLoaded({required this.companies, required this.cities});
}

class CompaniesFailure extends CompaniesState {
  final String message;

  const CompaniesFailure(this.message);
}
