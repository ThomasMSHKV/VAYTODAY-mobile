import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/auth/domain/models/auth_user_model.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';

class ProfileApiException implements Exception {
  final String message;

  const ProfileApiException(this.message);

  @override
  String toString() => message;
}

class ProfileRepository {
  static const _savedCompaniesKeyPrefix = 'saved_companies_';

  final AuthSessionStorage _sessionStorage;
  final AuthRepository _authRepository;

  ProfileRepository({
    AuthSessionStorage? sessionStorage,
    AuthRepository? authRepository,
  }) : _sessionStorage = sessionStorage ?? AuthSessionStorage(),
       _authRepository = authRepository ?? AuthRepository();

  Future<AuthUserModel?> getUserProfile() async {
    final response = await _authorizedRequest(
      (options) => ApiClient.dio.get('user-profile', options: options),
    );
    return _readUserFromResponse(response.data);
  }

  Future<AuthUserModel?> updateUsername(String username) async {
    final currentUser = await getUserProfile();
    final data = {
      'username': username,
      if (currentUser != null) ...{
        'email': currentUser.email,
        'is_email_verified': currentUser.isEmailVerified,
      },
    };

    try {
      final response = await _authorizedRequest(
        (options) =>
            ApiClient.dio.patch('user-profile', data: data, options: options),
      );

      final updatedUser = _readUserFromResponse(response.data);
      return updatedUser ?? await getUserProfile();
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode ?? 0;
      final shouldTryDetailEndpoint =
          currentUser != null &&
          (statusCode == 400 || statusCode == 404 || statusCode == 405);

      if (!shouldTryDetailEndpoint) {
        throw ProfileApiException(_readErrorMessage(error.response?.data));
      }

      return _updateUsernameByProfileId(currentUser.id, data);
    }
  }

  Future<AuthUserModel?> _updateUsernameByProfileId(
    int userId,
    Map<String, Object> data,
  ) async {
    DioException? lastError;

    for (final path in ['user-profile/$userId', 'user-profile/$userId/']) {
      try {
        final response = await _authorizedRequest(
          (options) => ApiClient.dio.patch(path, data: data, options: options),
        );

        final updatedUser = _readUserFromResponse(response.data);
        return updatedUser ?? await getUserProfile();
      } on DioException catch (error) {
        lastError = error;
      }
    }

    throw ProfileApiException(_readErrorMessage(lastError?.response?.data));
  }

  Future<List<CompanyModel>> getFavoriteCompanies() async {
    final cachedCompanies = await getCachedFavoriteCompanies();

    final response = await _authorizedRequest(
      (options) => ApiClient.dio.get(
        'user-profile/favorite-companies',
        options: options,
      ),
    );

    final results = response.data['results'] as List? ?? [];

    final companies = results
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .where((company) => company.isActive)
        .toList();

    if (cachedCompanies.isNotEmpty) {
      return cachedCompanies;
    }

    await _replaceCachedFavoriteCompanies(companies);
    return companies;
  }

  Future<List<CompanyModel>> getCachedFavoriteCompanies() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(await _savedCompaniesKey()) ?? [];

    final companies = <CompanyModel>[];
    for (final value in values) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is! Map) continue;
        companies.add(
          CompanyModel.fromJson(Map<String, dynamic>.from(decoded)),
        );
      } catch (_) {
        continue;
      }
    }

    return companies;
  }

  Future<bool> isFavoriteCompany(int companyId) async {
    final cachedCompanies = await getCachedFavoriteCompanies();
    if (cachedCompanies.any((company) => company.id == companyId)) {
      return true;
    }

    final companies = await getFavoriteCompanies();
    return companies.any((company) => company.id == companyId);
  }

  Future<void> addFavoriteCompany(CompanyModel company) async {
    await _saveCachedFavoriteCompany(company);

    try {
      await _authorizedRequest(
        (options) => ApiClient.dio.post(
          'user-profile/favorite-companies',
          data: {
            'title': company.title,
            'description': company.description,
            'site': '',
            'instagram': '',
            'email': '',
            'phones': company.phones,
            'recommendated': company.recommendated,
            'is_active': company.isActive,
            'cities': company.cities,
            'address': company.address,
            'text_from_admin': '',
            'work_start': company.workStart,
            'work_end': company.workEnd,
            'order_method': 'site',
          },
          options: options,
        ),
      );
    } catch (_) {
      // Local saving is enough for the profile screen; the server copy is a
      // best-effort sync when the endpoint is available.
    }
  }

  Future<void> removeFavoriteCompany(int companyId) async {
    await _removeCachedFavoriteCompany(companyId);

    try {
      await _authorizedRequest(
        (options) => ApiClient.dio.delete(
          'user-profile/favorite-companies/$companyId',
          options: options,
        ),
      );
    } catch (_) {
      // The local state is the source of truth for the app UI.
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _authorizedRequest(
        (options) => ApiClient.dio.delete('user-profile', options: options),
      );
    } on DioException catch (error) {
      throw ProfileApiException(_readErrorMessage(error.response?.data));
    }
  }

  Future<Response<dynamic>> _authorizedRequest(
    Future<Response<dynamic>> Function(Options options) request,
  ) async {
    try {
      return await request(await _authOptions());
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;

      final refreshToken = await _sessionStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _sessionStorage.clear();
        throw const ProfileApiException('Войдите в аккаунт заново');
      }

      AuthTokens tokens;
      try {
        tokens = await _authRepository.refreshToken(refreshToken);
      } catch (_) {
        await _sessionStorage.clear();
        throw const ProfileApiException('Сессия истекла. Войдите заново');
      }

      await _sessionStorage.saveTokens(tokens);
      return request(await _authOptions());
    }
  }

  Future<Options> _authOptions() async {
    final accessToken = await _sessionStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw const ProfileApiException('Войдите в аккаунт заново');
    }

    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  Future<void> _saveCachedFavoriteCompany(CompanyModel company) async {
    final companies = await getCachedFavoriteCompanies();
    final updated = [
      company,
      ...companies.where((item) => item.id != company.id),
    ];
    await _replaceCachedFavoriteCompanies(updated);
  }

  Future<void> _removeCachedFavoriteCompany(int companyId) async {
    final companies = await getCachedFavoriteCompanies();
    await _replaceCachedFavoriteCompanies(
      companies.where((company) => company.id != companyId).toList(),
    );
  }

  Future<void> _replaceCachedFavoriteCompanies(
    List<CompanyModel> companies,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      await _savedCompaniesKey(),
      companies.map((company) => jsonEncode(company.toJson())).toList(),
    );
  }

  Future<String> _savedCompaniesKey() async {
    final email = await _sessionStorage.getEmail();
    final normalizedEmail = email?.trim().toLowerCase() ?? '';
    return '$_savedCompaniesKeyPrefix${normalizedEmail.isEmpty ? 'anonymous' : normalizedEmail}';
  }

  AuthUserModel? _readUserFromResponse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final results = data['results'];
    if (results is List && results.isNotEmpty) {
      final firstProfile = results.first;
      if (firstProfile is Map<String, dynamic>) {
        return AuthUserModel.fromJson(firstProfile);
      }
    }

    final hasUserFields =
        data.containsKey('id') ||
        data.containsKey('username') ||
        data.containsKey('email');

    if (!hasUserFields) return null;

    return AuthUserModel.fromJson(data);
  }

  String _readErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final key in ['detail', 'message', 'error', 'username']) {
        final value = data[key];
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value != null) return value.toString();
      }
    }

    if (data != null) {
      final message = data.toString();
      if (message.trim().isNotEmpty) return message;
    }

    return 'Не удалось обновить имя';
  }
}
