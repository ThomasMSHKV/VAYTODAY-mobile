import 'package:dio/dio.dart';
import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/auth/domain/models/auth_user_model.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';

class ProfileRepository {
  final AuthSessionStorage _sessionStorage;

  ProfileRepository({
    AuthSessionStorage? sessionStorage,
  }) : _sessionStorage = sessionStorage ?? AuthSessionStorage();

  Future<AuthUserModel?> getUserProfile() async {
    final response = await ApiClient.dio.get(
      'user-profile',
      options: await _authOptions(),
    );

    final results = response.data['results'] as List? ?? [];
    final profiles = results.whereType<Map<String, dynamic>>().toList();

    if (profiles.isEmpty) return null;

    return AuthUserModel.fromJson(profiles.first);
  }

  Future<List<CompanyModel>> getFavoriteCompanies() async {
    final response = await ApiClient.dio.get(
      'user-profile/favorite-companies',
      options: await _authOptions(),
    );

    final results = response.data['results'] as List? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .where((company) => company.isActive)
        .toList();
  }

  Future<bool> isFavoriteCompany(int companyId) async {
    final companies = await getFavoriteCompanies();
    return companies.any((company) => company.id == companyId);
  }

  Future<void> addFavoriteCompany(CompanyModel company) async {
    await ApiClient.dio.post(
      'user-profile/favorite-companies',
      data: {
        'title': company.title,
        'description': company.description,
        'site': '',
        'instagram': '',
        'email': '',
        'phones': '',
        'recommendated': company.recommendated,
        'is_active': company.isActive,
        'cities': company.cities,
        'address': company.address,
        'text_from_admin': '',
        'work_start': company.workStart,
        'work_end': company.workEnd,
        'order_method': 'site',
      },
      options: await _authOptions(),
    );
  }

  Future<void> removeFavoriteCompany(int companyId) async {
    await ApiClient.dio.delete(
      'user-profile/favorite-companies/$companyId',
      options: await _authOptions(),
    );
  }

  Future<Options> _authOptions() async {
    final accessToken = await _sessionStorage.getAccessToken();

    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
