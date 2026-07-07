import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

class CategoriesRepository {
  static const _cacheKey = 'cached_categories';
  static const _cacheTimeKey = 'cached_categories_time';
  static const _cacheLifetime = Duration(hours: 24);

  Future<List<HomeCategory>> getCategories() async {
    final cached = await _readCache();
    if (cached != null && cached.isFresh) {
      return cached.categories;
    }

    try {
      final response = await ApiClient.dio.get('categories');
      final results = response.data['results'] as List? ?? [];
      final categories = results
          .whereType<Map<String, dynamic>>()
          .map(HomeCategory.fromJson)
          .toList();

      await _writeCache(categories);
      return categories;
    } catch (_) {
      if (cached != null) return cached.categories;
      rethrow;
    }
  }

  Future<_CategoriesCache?> _readCache() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      final categories = decoded
          .whereType<Map>()
          .map((json) => HomeCategory.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      final savedAt = DateTime.fromMillisecondsSinceEpoch(
        preferences.getInt(_cacheTimeKey) ?? 0,
      );

      return _CategoriesCache(categories: categories, savedAt: savedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<HomeCategory> categories) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _cacheKey,
      jsonEncode(categories.map((category) => category.toJson()).toList()),
    );
    await preferences.setInt(
      _cacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class _CategoriesCache {
  final List<HomeCategory> categories;
  final DateTime savedAt;

  const _CategoriesCache({required this.categories, required this.savedAt});

  bool get isFresh {
    return DateTime.now().difference(savedAt) <
        CategoriesRepository._cacheLifetime;
  }
}
