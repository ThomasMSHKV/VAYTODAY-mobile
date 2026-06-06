import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/companies/domain/models/city_model.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';

class CompaniesRepository {
  Future<List<CityModel>> getCities() async {
    final response = await ApiClient.dio.get('cities');

    final results = response.data['results'] as List? ?? [];

    return results
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CompanyModel>> getCompaniesByServiceId(int serviceId) async {
    final response = await ApiClient.dio.get(
      'companies',
      queryParameters: {'services': serviceId, 'limit': 20, 'offset': 0},
    );

    final results = response.data['results'] as List? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .where((company) => company.isActive)
        .toList();
  }
}
