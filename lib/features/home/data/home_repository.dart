import 'dart:math';

import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/categories/data/categories_repository.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

class HomeRepository {
  final CategoriesRepository _categoriesRepository;

  HomeRepository({CategoriesRepository? categoriesRepository})
    : _categoriesRepository = categoriesRepository ?? CategoriesRepository();

  Future<List<HomeCategory>> getCategories() async {
    return _categoriesRepository.getCategories();
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
      if (companies.isEmpty) {
        return _getPopularCompaniesFallbackOrEmpty();
      }

      final shuffled = [...companies]..shuffle(Random());
      return shuffled.take(10).toList();
    } catch (_) {
      return _getPopularCompaniesFallbackOrEmpty();
    }
  }

  Future<List<CompanyModel>> searchCompanies(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const [];

    final response = await ApiClient.dio.get(
      'companies',
      queryParameters: {'search': cleanQuery, 'limit': 20, 'offset': 0},
    );

    final results = response.data['results'] as List? ?? [];
    final companies = results
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .where((company) => company.isActive)
        .toList();

    companies.sort(_compareCompaniesByRatingAndReviews);
    return companies;
  }

  int _compareCompaniesByRatingAndReviews(
    CompanyModel first,
    CompanyModel second,
  ) {
    final ratingComparison = second.rating.compareTo(first.rating);
    if (ratingComparison != 0) return ratingComparison;

    return second.reviewsCount.compareTo(first.reviewsCount);
  }

  Future<List<CompanyModel>> _getCompaniesForPopularity() async {
    final response = await ApiClient.dio.get(
      'companies',
      queryParameters: {'limit': 100, 'offset': 0},
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
