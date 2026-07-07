import 'package:VayToday/features/companies/domain/models/company_model.dart';

abstract class SavedCompaniesState {
  const SavedCompaniesState();
}

class SavedCompaniesInitial extends SavedCompaniesState {
  const SavedCompaniesInitial();
}

class SavedCompaniesLoading extends SavedCompaniesState {
  const SavedCompaniesLoading();
}

class SavedCompaniesLoaded extends SavedCompaniesState {
  final List<CompanyModel> companies;

  const SavedCompaniesLoaded(this.companies);
}

class SavedCompaniesFailure extends SavedCompaniesState {
  final String message;

  const SavedCompaniesFailure(this.message);
}
