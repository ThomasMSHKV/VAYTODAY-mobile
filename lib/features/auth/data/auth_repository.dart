import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/auth/domain/models/auth_user_model.dart';
import 'package:dio/dio.dart';

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

class AuthRepository {
  Future<AuthUserModel> register({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      'user-registration',
      data: {
        'username': email,
        'email': email,
        'password': password,
      },
    );

    return AuthUserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    await ApiClient.dio.post(
      'verify-email',
      data: {
        'email': email,
        'verification_code': verificationCode,
      },
    );
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      'token',
      data: {
        'username_or_email': email,
        'password': password,
      },
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
    await ApiClient.dio.post(
      'token/verify',
      data: {'token': token},
    );
  }

  Future<void> resendVerificationCode(String email) async {
    await ApiClient.dio.post(
      'resend-verification-code',
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await ApiClient.dio.post(
      'reset-password',
      data: {
        'email': email,
        'code': code,
        'password': password,
      },
    );
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

  Options _authOptions(String accessToken) {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
