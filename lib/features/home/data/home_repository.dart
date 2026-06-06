import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

class HomeRepository {
  Future<List<HomeCategory>> getCategories() async {
    final response = await ApiClient.dio.get('categories');

    final results = response.data['results'] as List? ?? [];

    return results
        .map((e) => HomeCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CompanyModel>> getRecommendedCompanies() async {
    final response = await ApiClient.dio.get('recommendated-companies');

    final results = response.data['results'] as List? ?? [];

    return results
        .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CompanyModel>> getPopularCompanies() async {
    try {
      final companies = await _getCompaniesForPopularity();

      companies.sort((first, second) {
        if (first.visits != second.visits) {
          return second.visits.compareTo(first.visits);
        }

        return second.rating.compareTo(first.rating);
      });

      final visitedCompanies = companies
          .where((company) => company.visits > 0)
          .take(10)
          .toList();

      if (visitedCompanies.isEmpty) {
        return _getPopularCompaniesFallbackOrEmpty();
      }

      return visitedCompanies;
    } catch (_) {
      return _getPopularCompaniesFallbackOrEmpty();
    }
  }

  Future<List<CompanyModel>> _getCompaniesForPopularity() async {
    final response = await ApiClient.dio.get(
      'companies',
      queryParameters: {'limit': 10, 'offset': 0},
    );

    final results = response.data['results'] as List? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .where((company) => company.isActive)
        .toList();
  }

  Future<List<CompanyModel>> _getPopularCompaniesFallbackOrEmpty() async {
    try {
      final response = await ApiClient.dio.get('popular-companies');

      final results = response.data['results'] as List? ?? [];

      return results
          .whereType<Map<String, dynamic>>()
          .map(CompanyModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
