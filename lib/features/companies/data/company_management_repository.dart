import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';

class CompanyManagementException implements Exception {
  final String message;

  const CompanyManagementException(this.message);

  @override
  String toString() => message;
}

class CreateCompanyRequest {
  final String title;
  final String description;
  final String phone;
  final List<int> serviceIds;
  final int cityId;
  final int? addressId;
  final String addressText;
  final String workStart;
  final String workEnd;
  final List<String> imagePaths;

  const CreateCompanyRequest({
    required this.title,
    required this.description,
    required this.phone,
    required this.serviceIds,
    required this.cityId,
    required this.addressId,
    required this.addressText,
    required this.workStart,
    required this.workEnd,
    required this.imagePaths,
  });
}

class UpdateCompanyRequest {
  final CompanyModel company;
  final String title;
  final String description;
  final String phone;
  final int addressId;
  final List<int> serviceIds;
  final String addressText;
  final String workStart;
  final String workEnd;

  const UpdateCompanyRequest({
    required this.company,
    required this.title,
    required this.description,
    required this.phone,
    required this.addressId,
    required this.serviceIds,
    required this.addressText,
    required this.workStart,
    required this.workEnd,
  });
}

class CompanyManagementRepository {
  static const _legacyCachedCompaniesKey = 'my_cached_companies';
  static const _companyIdsKeyPrefix = 'my_company_ids_';
  static const _cachedCompaniesKeyPrefix = 'my_cached_companies_';
  static const _cacheMigrationKeyPrefix = 'my_companies_cache_migrated_';

  final AuthSessionStorage _sessionStorage;
  final AuthRepository _authRepository;

  CompanyManagementRepository({
    AuthSessionStorage? sessionStorage,
    AuthRepository? authRepository,
  }) : _sessionStorage = sessionStorage ?? AuthSessionStorage(),
       _authRepository = authRepository ?? AuthRepository();

  Future<CompanyModel> createCompany(CreateCompanyRequest request) async {
    final email = await _sessionStorage.getEmail() ?? '';
    final payload = _createCompanyPayload(request, email);
    final response = await _authorizedRequest(
      (options) =>
          ApiClient.dio.post('companies', data: payload, options: options),
    );

    if (response.data is! Map<String, dynamic>) {
      throw const CompanyManagementException(
        'Сервер вернул некорректный ответ',
      );
    }

    final data = Map<String, dynamic>.from(response.data as Map);
    var company = CompanyModel.fromJson(data);
    company = _applySubmittedContactFields(company, request);
    if (!request.serviceIds.every(company.hasService)) {
      company = await _retryServiceBinding(company, request, email);
      company = _applySubmittedContactFields(company, request);
    }

    await _saveCompanyId(company.id);
    await _saveCachedCompany(_companyToCacheJson(company));

    for (final imagePath in request.imagePaths.take(4)) {
      try {
        await _uploadCompanyImage(company.id, imagePath);
      } catch (_) {
        // The company is already created; image upload should not make the
        // user create a duplicate company by retrying the whole form.
      }
    }

    return company;
  }

  Future<CompanyModel> updateCompany(UpdateCompanyRequest request) async {
    final email = await _sessionStorage.getEmail() ?? request.company.email;
    final response = await _authorizedRequest(
      (options) => ApiClient.dio.patch(
        'companies/${request.company.id}',
        data: _updateCompanyPayload(request, email),
        options: options,
      ),
    );

    if (response.data is! Map<String, dynamic>) {
      throw const CompanyManagementException(
        'Сервер вернул некорректный ответ',
      );
    }

    final updated =
        CompanyModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        ).copyWith(
          phones: request.phone.trim(),
          manualAddress: request.addressText.trim(),
        );

    await _saveCachedCompany(_companyToCacheJson(updated));
    return updated;
  }

  Future<void> deleteCompany(int companyId) async {
    await _authorizedRequest(
      (options) =>
          ApiClient.dio.delete('companies/$companyId', options: options),
    );

    await _removeCompanyFromCache(companyId);
  }

  Future<void> clearCurrentAccountCache() async {
    await _replaceAccountCache(const []);
  }

  Map<String, dynamic> _createCompanyPayload(
    CreateCompanyRequest request,
    String email,
  ) {
    return {
      'title': request.title.trim(),
      'description': request.description.trim(),
      'site': '',
      'instagram': '',
      'email': email,
      'phones': request.phone.trim(),
      'recommendated': false,
      'services': request.serviceIds,
      'text_from_admin': '',
      'cities': [request.cityId],
      if (request.addressId != null) 'address': request.addressId,
      if (request.addressId == null && request.addressText.trim().isNotEmpty)
        'address_field': request.addressText.trim(),
      'work_start': request.workStart,
      'work_end': request.workEnd,
      'order_method': 'site',
    };
  }

  Map<String, dynamic> _updateCompanyPayload(
    UpdateCompanyRequest request,
    String email,
  ) {
    final company = request.company;
    return {
      'title': request.title.trim(),
      'description': request.description.trim(),
      'site': '',
      'instagram': '',
      'email': email,
      'phones': request.phone.trim(),
      'recommendated': company.recommendated,
      'is_active': company.isActive,
      if (company.cities.isNotEmpty) 'cities': company.cities,
      'address': request.addressId,
      'services': request.serviceIds,
      'text_from_admin': '',
      'work_start': request.workStart,
      'work_end': request.workEnd,
      'order_method': 'site',
    };
  }

  Future<CompanyModel> _retryServiceBinding(
    CompanyModel company,
    CreateCompanyRequest request,
    String email,
  ) async {
    final kotlinBusinessSentPayload = {
      'title': request.title.trim(),
      'description': request.description.trim(),
      'site': '',
      'instagram': '',
      'email': email,
      'phones': request.phone.trim(),
      'recommendated': false,
      'services': request.serviceIds,
      'text_from_admin': '',
      'cities': [request.cityId],
      if (request.addressId != null) 'address_field': request.addressId,
      if (request.addressId == null && request.addressText.trim().isNotEmpty)
        'address_field_text': request.addressText.trim(),
    };

    for (final path in [
      'companies/${company.id}',
      'companies/${company.id}/',
    ]) {
      try {
        final response = await _authorizedRequest(
          (options) => ApiClient.dio.put(
            path,
            data: kotlinBusinessSentPayload,
            options: options,
          ),
        );
        if (response.data is Map<String, dynamic>) {
          return CompanyModel.fromJson(response.data as Map<String, dynamic>);
        }
        return company;
      } catch (_) {
        continue;
      }
    }

    return company;
  }

  Future<void> _uploadCompanyImage(int companyId, String imagePath) async {
    await _authorizedRequest((options) async {
      final imageBytes = await File(imagePath).readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      return ApiClient.dio.post(
        'company-images',
        data: {'company': companyId, 'image': imageBase64},
        options: options,
      );
    });
  }

  CompanyModel _applySubmittedContactFields(
    CompanyModel company,
    CreateCompanyRequest request,
  ) {
    return company.copyWith(
      phones: company.phones.trim().isEmpty
          ? request.phone.trim()
          : company.phones,
      manualAddress:
          company.manualAddress.trim().isEmpty &&
              company.addressName.trim().isEmpty
          ? request.addressText.trim()
          : company.manualAddress,
    );
  }

  Future<List<CompanyModel>> getMyCompanies() async {
    await _migrateLegacyCompaniesForCurrentAccount();
    final response = await _authorizedRequest(
      (options) => ApiClient.dio.get(
        'user-profile/companies',
        queryParameters: {'limit': 1000, 'offset': 0},
        options: options,
      ),
    );

    final results = _readResults(response.data);
    final serverCompanies = results
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .toList();
    final companies = await Future.wait(serverCompanies.map(_attachImages));

    companies.sort((a, b) => b.id.compareTo(a.id));
    await _replaceAccountCache(companies);
    return companies;
  }

  List<dynamic> _readResults(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return data['results'] as List? ?? const [];
    }
    return const [];
  }

  Future<void> _replaceAccountCache(List<CompanyModel> companies) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      await _companyIdsKey(),
      companies.map((company) => company.id.toString()).toList(),
    );
    await preferences.setStringList(
      await _cachedCompaniesKey(),
      companies
          .map((company) => jsonEncode(_companyToCacheJson(company)))
          .toList(),
    );
  }

  Future<List<CompanyModel>> getCachedMyCompanies() async {
    await _migrateLegacyCompaniesForCurrentAccount();
    final email = await _sessionStorage.getEmail() ?? '';
    final companies = await _getCachedCompanies();
    final filtered = email.isEmpty
        ? companies
        : companies
              .where(
                (company) => company.email.isEmpty || company.email == email,
              )
              .toList();

    filtered.sort((a, b) => b.id.compareTo(a.id));
    return filtered;
  }

  Future<CompanyModel> _attachImages(CompanyModel company) async {
    if (company.images.isNotEmpty) return company;

    final images = await _getCompanyImages(company.id);
    if (images.isEmpty) return company;

    return company.copyWith(images: images);
  }

  Future<List<CompanyImageModel>> _getCompanyImages(int companyId) async {
    try {
      final response = await _authorizedRequest(
        (options) => ApiClient.dio.get(
          'company-images',
          queryParameters: {'company': companyId, 'limit': 20, 'offset': 0},
          options: options,
        ),
      );

      final results = response.data['results'] as List? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .where((json) => _parseInt(json['company']) == companyId)
          .map(CompanyImageModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> hasCompany(int companyId) async {
    final ids = await _getSavedCompanyIds();
    if (ids.contains(companyId.toString())) return true;

    try {
      final companies = await getMyCompanies();
      return companies.any((company) => company.id == companyId);
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveCompanyId(int companyId) async {
    final preferences = await SharedPreferences.getInstance();
    final key = await _companyIdsKey();
    final value = companyId.toString();

    await _appendCompanyId(preferences, key, value);
  }

  Future<void> _migrateLegacyCompaniesForCurrentAccount() async {
    final email =
        (await _sessionStorage.getEmail())?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final migrationKey = '$_cacheMigrationKeyPrefix$email';
    if (preferences.getBool(migrationKey) == true) return;

    final legacyCompanies =
        preferences.getStringList(_legacyCachedCompaniesKey) ?? [];
    for (final value in legacyCompanies) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is! Map) continue;

        final data = Map<String, dynamic>.from(decoded);
        final companyEmail = data['email']?.toString().trim().toLowerCase();
        if (companyEmail != email) continue;

        final companyId = _parseInt(data['id']);
        if (companyId <= 0) continue;

        await _saveCompanyId(companyId);
        await _saveCachedCompany(data);
      } catch (_) {
        continue;
      }
    }

    await preferences.setBool(migrationKey, true);
  }

  Future<void> _saveCachedCompany(Map<String, dynamic> companyJson) async {
    final preferences = await SharedPreferences.getInstance();
    final cacheKey = await _cachedCompaniesKey();
    final cached = preferences.getStringList(cacheKey) ?? [];
    final companyId = companyJson['id']?.toString() ?? '';
    final withoutCurrent = cached.where((value) {
      try {
        final data = jsonDecode(value);
        return data is! Map || data['id']?.toString() != companyId;
      } catch (_) {
        return false;
      }
    }).toList();

    await preferences.setStringList(cacheKey, [
      ...withoutCurrent,
      jsonEncode(companyJson),
    ]);
  }

  Future<void> _removeCompanyFromCache(int companyId) async {
    final preferences = await SharedPreferences.getInstance();
    final value = companyId.toString();

    final idsKey = await _companyIdsKey();
    final ids = preferences.getStringList(idsKey) ?? <String>[];
    await preferences.setStringList(
      idsKey,
      ids.where((id) => id != value).toList(),
    );

    final cacheKey = await _cachedCompaniesKey();
    final cached = preferences.getStringList(cacheKey) ?? <String>[];
    final filtered = cached.where((cachedValue) {
      try {
        final data = jsonDecode(cachedValue);
        return data is! Map || data['id']?.toString() != value;
      } catch (_) {
        return false;
      }
    }).toList();

    await preferences.setStringList(cacheKey, filtered);
  }

  Map<String, dynamic> _companyToCacheJson(CompanyModel company) {
    return {
      'id': company.id,
      'title': company.title,
      'description': company.description,
      'email': company.email,
      'phones': company.phones,
      'rating': company.rating,
      'recommendated': company.recommendated,
      'is_active': company.isActive,
      'services': company.services.map((service) => service.toJson()).toList(),
      'similar_services': company.similarServices
          .map((service) => service.toJson())
          .toList(),
      'images': company.images
          .map((image) => {'id': image.id, 'image': image.imageUrl})
          .toList(),
      'cities': company.cities
          .map(
            (cityId) => {
              'id': cityId,
              if (company.cityName.isNotEmpty) 'name': company.cityName,
            },
          )
          .toList(),
      'address': company.address == null
          ? null
          : {
              'id': company.address,
              'name': company.addressName,
              'latitude': company.addressLatitude,
              'longitude': company.addressLongitude,
            },
      'address_field': company.manualAddress,
      'work_start': company.workStart,
      'work_end': company.workEnd,
      'visits': company.visits,
    };
  }

  Future<List<CompanyModel>> _getCachedCompanies() async {
    final preferences = await SharedPreferences.getInstance();
    final cached = preferences.getStringList(await _cachedCompaniesKey()) ?? [];
    final companies = <CompanyModel>[];

    for (final value in cached) {
      try {
        final data = jsonDecode(value);
        if (data is Map) {
          companies.add(CompanyModel.fromJson(Map<String, dynamic>.from(data)));
        }
      } catch (_) {
        continue;
      }
    }

    return companies;
  }

  Future<List<String>> _getSavedCompanyIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(await _companyIdsKey()) ?? [];
  }

  Future<void> _appendCompanyId(
    SharedPreferences preferences,
    String key,
    String value,
  ) async {
    final ids = preferences.getStringList(key) ?? <String>[];
    if (ids.contains(value)) return;

    await preferences.setStringList(key, [...ids, value]);
  }

  Future<String> _companyIdsKey() async {
    return '$_companyIdsKeyPrefix${await _accountKey()}';
  }

  Future<String> _cachedCompaniesKey() async {
    return '$_cachedCompaniesKeyPrefix${await _accountKey()}';
  }

  Future<String> _accountKey() async {
    final email = await _sessionStorage.getEmail();
    final normalizedEmail = email?.trim().toLowerCase() ?? '';
    return normalizedEmail.isEmpty ? 'anonymous' : normalizedEmail;
  }

  Future<Response<dynamic>> _authorizedRequest(
    Future<Response<dynamic>> Function(Options options) request,
  ) async {
    try {
      return await request(await _authOptions());
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) {
        throw CompanyManagementException(
          _readErrorMessage(error.response?.data),
        );
      }

      final refreshToken = await _sessionStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _sessionStorage.clear();
        throw const CompanyManagementException('Войдите в аккаунт заново');
      }

      try {
        final tokens = await _authRepository.refreshToken(refreshToken);
        await _sessionStorage.saveTokens(tokens);
        return await request(await _authOptions());
      } on DioException catch (retryError) {
        throw CompanyManagementException(
          _readErrorMessage(retryError.response?.data),
        );
      } catch (_) {
        await _sessionStorage.clear();
        throw const CompanyManagementException(
          'Сессия истекла. Войдите заново',
        );
      }
    }
  }

  Future<Options> _authOptions() async {
    final token = await _sessionStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const CompanyManagementException('Войдите в аккаунт заново');
    }

    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'Authorization': 'Bearer $token',
      },
    );
  }

  String _readErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final entry in data.entries) {
        final message = _firstErrorMessage(entry.value);
        if (message == null) continue;

        if (['detail', 'message', 'error'].contains(entry.key)) {
          return message;
        }
        return '${_fieldName(entry.key)}: $message';
      }
    }

    return 'Не удалось добавить компанию';
  }

  String? _firstErrorMessage(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    if (value is List) {
      for (final item in value) {
        final message = _firstErrorMessage(item);
        if (message != null) return message;
      }
    }
    if (value is Map) {
      for (final item in value.values) {
        final message = _firstErrorMessage(item);
        if (message != null) return message;
      }
    }
    return null;
  }

  String _fieldName(String key) {
    const names = {
      'title': 'Название',
      'description': 'Описание',
      'email': 'Email',
      'services': 'Подкатегория',
      'cities': 'Город',
      'address': 'Адрес',
      'address_field': 'Адрес',
      'work_start': 'Начало работы',
      'work_end': 'Конец работы',
      'order_method': 'Способ заказа',
      'image': 'Фотография',
    };
    return names[key] ?? key;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
