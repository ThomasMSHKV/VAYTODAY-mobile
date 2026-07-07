import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/products/domain/models/product_model.dart';

class ProductApiException implements Exception {
  final String message;

  const ProductApiException(this.message);

  @override
  String toString() => message;
}

class ProductSaveRequest {
  final int companyId;
  final String title;
  final String description;
  final String price;
  final String oldPrice;
  final bool isOnDiscountAd;

  const ProductSaveRequest({
    required this.companyId,
    required this.title,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.isOnDiscountAd,
  });
}

class ProductsRepository {
  final AuthSessionStorage _sessionStorage;
  final AuthRepository _authRepository;

  ProductsRepository({
    AuthSessionStorage? sessionStorage,
    AuthRepository? authRepository,
  }) : _sessionStorage = sessionStorage ?? AuthSessionStorage(),
       _authRepository = authRepository ?? AuthRepository();

  Future<List<ProductModel>> getProducts({
    int limit = 100,
    String query = '',
    bool discountedOnly = false,
  }) async {
    const pageSize = 50;
    const maxPages = 6;
    final products = <ProductModel>[];
    final cleanQuery = query.trim();

    for (var page = 0; page < maxPages && products.length < limit; page++) {
      final response = await ApiClient.dio.get(
        'products',
        queryParameters: {
          if (discountedOnly) 'is_on_discount_ad': true,
          if (cleanQuery.isNotEmpty) 'search': cleanQuery,
          'limit': pageSize,
          'offset': page * pageSize,
        },
      );

      final results = response.data['results'] as List? ?? [];
      final pageProducts = results
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .where((product) => !discountedOnly || product.isOnDiscountAd)
          .toList();

      products.addAll(pageProducts);

      final hasNext = response.data is Map && response.data['next'] != null;
      if (!hasNext || results.isEmpty) break;
    }

    products.shuffle();
    final limitedProducts = products.take(limit).toList();
    return Future.wait(limitedProducts.map(_attachImages));
  }

  Future<List<ProductModel>> getDiscountProducts({int limit = 20}) {
    return getProducts(limit: limit, discountedOnly: true);
  }

  Future<CompanyModel> getProductCompany(int companyId) async {
    final response = await ApiClient.dio.get('companies/$companyId');

    if (response.data is Map<String, dynamic>) {
      return CompanyModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw const ProductApiException('Сервер вернул некорректный ответ');
  }

  Future<List<ProductModel>> getProductsByCompanyId(int companyId) async {
    final response = await ApiClient.dio.get(
      'products',
      queryParameters: {'company': companyId, 'limit': 100, 'offset': 0},
    );

    final results = response.data['results'] as List? ?? [];
    final products = results
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .where((product) => product.companyId == companyId)
        .toList();

    return Future.wait(products.map(_attachImages));
  }

  Future<ProductModel> createProduct(ProductSaveRequest request) async {
    final response = await _authorizedRequest(
      (options) => ApiClient.dio.post(
        'products',
        data: _productPayload(request),
        options: options,
      ),
    );

    return _readProduct(response.data);
  }

  Future<ProductModel> updateProduct(
    int productId,
    ProductSaveRequest request,
  ) async {
    final response = await _authorizedRequest(
      (options) => ApiClient.dio.patch(
        'products/$productId',
        data: _productPayload(request),
        options: options,
      ),
    );

    return _readProduct(response.data);
  }

  Future<void> deleteProduct(int productId) async {
    await _authorizedRequest(
      (options) =>
          ApiClient.dio.delete('products/$productId', options: options),
    );
  }

  Future<ProductImageModel> saveProductImage({
    required int productId,
    required String imagePath,
    int? imageId,
  }) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final imageBase64 = base64Encode(imageBytes);
    final data = {'product': productId, 'image': imageBase64};

    if (imageId != null) {
      try {
        final response = await _authorizedRequest(
          (options) => ApiClient.dio.patch(
            'product-images/$imageId',
            data: data,
            options: options,
          ),
        );

        if (response.data is Map<String, dynamic>) {
          return ProductImageModel.fromJson(
            response.data as Map<String, dynamic>,
          );
        }
      } on ProductApiException {
        await deleteProductImage(imageId);
      }
    }

    final response = await _authorizedRequest(
      (options) =>
          ApiClient.dio.post('product-images', data: data, options: options),
    );

    if (response.data is Map<String, dynamic>) {
      return ProductImageModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw const ProductApiException('Сервер вернул некорректный ответ');
  }

  Future<void> deleteProductImage(int imageId) async {
    await _authorizedRequest(
      (options) =>
          ApiClient.dio.delete('product-images/$imageId', options: options),
    );
  }

  Future<ProductModel> _attachImages(ProductModel product) async {
    if (product.images.isNotEmpty) return product;

    final images = await _getProductImages(product.id);
    if (images.isEmpty) return product;

    return product.copyWith(images: images);
  }

  Future<List<ProductImageModel>> _getProductImages(int productId) async {
    try {
      final response = await ApiClient.dio.get(
        'product-images',
        queryParameters: {'product': productId, 'limit': 20, 'offset': 0},
      );

      final results = response.data['results'] as List? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .where((json) => _parseInt(json['product']) == productId)
          .map(ProductImageModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> _productPayload(ProductSaveRequest request) {
    final oldPrice = request.oldPrice.trim();
    return {
      'company': request.companyId,
      'title': request.title.trim(),
      'description': request.description.trim(),
      'price': request.price.trim(),
      if (oldPrice.isNotEmpty) 'old_price': oldPrice,
      'is_on_discount_ad': request.isOnDiscountAd,
    };
  }

  ProductModel _readProduct(dynamic data) {
    if (data is Map<String, dynamic>) {
      return ProductModel.fromJson(data);
    }

    throw const ProductApiException('Сервер вернул некорректный ответ');
  }

  Future<Response<dynamic>> _authorizedRequest(
    Future<Response<dynamic>> Function(Options options) request,
  ) async {
    try {
      return await request(await _authOptions());
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) {
        throw ProductApiException(_readErrorMessage(error.response?.data));
      }

      final refreshToken = await _sessionStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _sessionStorage.clear();
        throw const ProductApiException('Войдите в аккаунт заново');
      }

      try {
        final tokens = await _authRepository.refreshToken(refreshToken);
        await _sessionStorage.saveTokens(tokens);
        return await request(await _authOptions());
      } on DioException catch (retryError) {
        throw ProductApiException(_readErrorMessage(retryError.response?.data));
      } catch (_) {
        await _sessionStorage.clear();
        throw const ProductApiException('Сессия истекла. Войдите заново');
      }
    }
  }

  Future<Options> _authOptions() async {
    final token = await _sessionStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const ProductApiException('Войдите в аккаунт заново');
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

    return 'Не удалось сохранить продукт';
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
      'company': 'Компания',
      'title': 'Название',
      'description': 'Описание',
      'price': 'Цена',
      'old_price': 'Старая цена',
      'is_on_discount_ad': 'Скидка',
      'image': 'Фотография',
      'product': 'Продукт',
    };
    return names[key] ?? key;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
