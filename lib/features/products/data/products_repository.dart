import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/products/domain/models/product_model.dart';

class ProductsRepository {
  Future<List<ProductModel>> getProductsByCompanyId(int companyId) async {
    final response = await ApiClient.dio.get(
      'products',
      queryParameters: {
        'company': companyId,
        'limit': 100,
        'offset': 0,
      },
    );

    final results = response.data['results'] as List? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .where((product) => product.companyId == companyId)
        .toList();
  }
}
