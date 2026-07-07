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

    return _readCompanies(response.data, serviceId: serviceId);
  }

  Future<List<CompanyModel>> searchCompaniesByServiceId({
    required int serviceId,
    required String query,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return getCompaniesByServiceId(serviceId);

    final response = await ApiClient.dio.get(
      'companies',
      queryParameters: {
        'services': serviceId,
        'search': cleanQuery,
        'limit': 20,
        'offset': 0,
      },
    );

    return _readCompanies(response.data, serviceId: serviceId);
  }

  List<CompanyModel> _readCompanies(dynamic data, {required int serviceId}) {
    final results = data is Map<String, dynamic>
        ? data['results'] as List? ?? []
        : const [];

    final companies = results
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .where((company) => company.isActive)
        .where((company) => company.hasService(serviceId))
        .toList();

    companies.sort((first, second) {
      final ratingComparison = second.rating.compareTo(first.rating);
      if (ratingComparison != 0) return ratingComparison;

      return second.reviewsCount.compareTo(first.reviewsCount);
    });

    return companies;
  }
}
