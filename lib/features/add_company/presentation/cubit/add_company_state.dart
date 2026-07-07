import 'package:VayToday/features/addresses/domain/models/address_model.dart';
import 'package:VayToday/features/companies/domain/models/city_model.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

enum AddCompanyStatus { initial, loading, ready, submitting, success, failure }

class AddCompanyState {
  final AddCompanyStatus status;
  final List<CityModel> cities;
  final List<AddressModel> addresses;
  final List<HomeCategory> categories;
  final CompanyModel? company;
  final String errorMessage;

  const AddCompanyState({
    this.status = AddCompanyStatus.initial,
    this.cities = const [],
    this.addresses = const [],
    this.categories = const [],
    this.company,
    this.errorMessage = '',
  });

  AddCompanyState copyWith({
    AddCompanyStatus? status,
    List<CityModel>? cities,
    List<AddressModel>? addresses,
    List<HomeCategory>? categories,
    CompanyModel? company,
    String? errorMessage,
  }) {
    return AddCompanyState(
      status: status ?? this.status,
      cities: cities ?? this.cities,
      addresses: addresses ?? this.addresses,
      categories: categories ?? this.categories,
      company: company ?? this.company,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
