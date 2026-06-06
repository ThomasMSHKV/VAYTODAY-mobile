class ProductImageModel {
  final int id;
  final int productId;
  final String imageUrl;

  const ProductImageModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: _parseInt(json['id']),
      productId: _parseInt(json['product']),
      imageUrl: json['image']?.toString() ?? '',
    );
  }
}

class ProductModel {
  final int id;
  final int companyId;
  final String title;
  final String description;
  final String price;
  final String oldPrice;
  final bool isOnDiscountAd;
  final List<ProductImageModel> images;

  const ProductModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.isOnDiscountAd,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List? ?? [];

    return ProductModel(
      id: _parseInt(json['id']),
      companyId: _parseRelationId(json['company']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      oldPrice: json['old_price']?.toString() ?? '',
      isOnDiscountAd: json['is_on_discount_ad'] == true,
      images: imagesJson
          .whereType<Map<String, dynamic>>()
          .map(ProductImageModel.fromJson)
          .toList(),
    );
  }

  String get imageUrl {
    if (images.isEmpty) return '';
    return images.first.imageUrl;
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _parseRelationId(dynamic value) {
  if (value is Map<String, dynamic>) {
    return _parseInt(value['id']);
  }

  return _parseInt(value);
}
