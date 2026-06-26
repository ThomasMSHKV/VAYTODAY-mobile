import 'package:dio/dio.dart';

import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/auth/domain/models/auth_user_model.dart';

class AuthTokens {
  final String refresh;
  final String access;

  const AuthTokens({required this.refresh, required this.access});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      refresh: json['refresh']?.toString() ?? '',
      access: json['access']?.toString() ?? '',
    );
  }
}

class AuthApiException implements Exception {
  final String message;
  final int? statusCode;

  const AuthApiException(this.message, {this.statusCode});

  @override
  String toString() {
    final code = statusCode;
    if (code == null) return message;

    return '$message ($code)';
  }
}

class AuthRepository {
  Future<void> register({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      'user-registration',
      data: {'username': email, 'email': email, 'password': password},
      options: _statusOptions(),
    );

    _ensureSuccess(response, fallbackMessage: 'Не удалось отправить код');
  }

  Future<void> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    final response = await ApiClient.dio.post(
      'verify-email',
      data: {'email': email, 'verification_code': verificationCode},
      options: _statusOptions(),
    );

    _ensureSuccess(response, fallbackMessage: 'Неверный код');
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      'token',
      data: {'username_or_email': email, 'password': password},
    );

    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await ApiClient.dio.post(
      'token/refresh',
      data: {'refresh': refreshToken},
    );

    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> verifyToken(String token) async {
    await ApiClient.dio.post('token/verify', data: {'token': token});
  }

  Future<void> resendVerificationCode(String email) async {
    final response = await ApiClient.dio.post(
      'resend-verification-code',
      data: {'email': email},
      options: _statusOptions(),
    );

    _ensureSuccess(response, fallbackMessage: 'Не удалось отправить код');
  }

  Future<void> sendPasswordResetCode(String email) async {
    final response = await ApiClient.dio.post(
      'reset-password',
      data: {'email': email},
      options: _statusOptions(),
    );

    _ensureSuccess(response, fallbackMessage: 'Не удалось отправить код');
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      'reset-password',
      data: {'email': email, 'code': code, 'password': password},
      options: _statusOptions(),
    );

    _ensureSuccess(response, fallbackMessage: 'Не удалось изменить пароль');
  }

  Future<List<AuthUserModel>> getUserProfile(String accessToken) async {
    final response = await ApiClient.dio.get(
      'user-profile',
      options: _authOptions(accessToken),
    );

    final results = response.data['results'] as List? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(AuthUserModel.fromJson)
        .toList();
  }

  Options _statusOptions() {
    return Options(validateStatus: (status) => status != null);
  }

  Options _authOptions(String accessToken) {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  void _ensureSuccess(
    Response<dynamic> response, {
    required String fallbackMessage,
  }) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) return;

    final message = _readErrorMessage(
      response.data,
      statusCode: statusCode,
      fallbackMessage: fallbackMessage,
    );
    throw AuthApiException(message, statusCode: statusCode);
  }

  String _readErrorMessage(
    dynamic data, {
    int? statusCode,
    required String fallbackMessage,
  }) {
    if (statusCode != null && statusCode >= 500) {
      return 'Ошибка сервера. Попробуйте позже';
    }

    if (data is Map<String, dynamic>) {
      for (final key in [
        'detail',
        'message',
        'error',
        'email',
        'username',
        'code',
        'password',
      ]) {
        final value = data[key];
        final message = _firstErrorMessage(value);
        if (message != null) return message;
      }
    }

    if (data != null) {
      final message = data.toString();
      if (_looksLikeHtml(message)) return fallbackMessage;
      if (message.trim().isNotEmpty) return message;
    }

    return fallbackMessage;
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

  bool _looksLikeHtml(String value) {
    final normalized = value.trimLeft().toLowerCase();
    return normalized.startsWith('<!doctype html') ||
        normalized.startsWith('<html') ||
        normalized.contains('<body>');
  }
}
