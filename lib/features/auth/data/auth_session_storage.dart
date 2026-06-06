import 'package:shared_preferences/shared_preferences.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';

class AuthSessionStorage {
  static const _isAuthorizedKey = 'auth_is_authorized';
  static const _emailKey = 'auth_email';
  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  Future<void> saveAuthorizedUser(
    String email, {
    AuthTokens? tokens,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isAuthorizedKey, true);
    await preferences.setString(_emailKey, email);

    if (tokens != null) {
      await preferences.setString(_accessTokenKey, tokens.access);
      await preferences.setString(_refreshTokenKey, tokens.refresh);
    }
  }

  Future<bool> isAuthorized() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isAuthorizedKey) ?? false;
  }

  Future<String?> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_refreshTokenKey);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_isAuthorizedKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
  }
}
