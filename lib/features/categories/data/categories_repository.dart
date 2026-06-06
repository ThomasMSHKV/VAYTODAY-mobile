import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

class CategoriesRepository {
  Future<List<HomeCategory>> getCategories() async {
    final response = await ApiClient.dio.get('categories');

    final results = response.data['results'] as List? ?? [];

    return results
        .map((e) => HomeCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
