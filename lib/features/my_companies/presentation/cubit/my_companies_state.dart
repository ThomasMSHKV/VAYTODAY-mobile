import 'package:VayToday/features/companies/domain/models/company_model.dart';

abstract class MyCompaniesState {
  const MyCompaniesState();
}

class MyCompaniesInitial extends MyCompaniesState {
  const MyCompaniesInitial();
}

class MyCompaniesLoading extends MyCompaniesState {
  const MyCompaniesLoading();
}

class MyCompaniesLoaded extends MyCompaniesState {
  final List<CompanyModel> companies;

  const MyCompaniesLoaded(this.companies);
}

class MyCompaniesFailure extends MyCompaniesState {
  final String message;

  const MyCompaniesFailure(this.message);
}
