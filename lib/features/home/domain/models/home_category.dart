class HomeService {
  final int id;
  final String name;
  final int categoryId;

  const HomeService({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory HomeService.fromJson(Map<String, dynamic> json) {
    return HomeService(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: json['name']?.toString() ?? '',
      categoryId: _parseCategoryId(json['category']),
    );
  }

  static int _parseCategoryId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is Map<String, dynamic>) {
      return int.tryParse('${value['id'] ?? 0}') ?? 0;
    }
    return 0;
  }
}

class HomeCategory {
  final int id;
  final String title;
  final String shortName;
  final String imageUrl;
  final int sortOrder;
  final List<HomeService> services;

  const HomeCategory({
    required this.id,
    required this.title,
    required this.shortName,
    required this.imageUrl,
    required this.sortOrder,
    required this.services,
  });

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    final servicesJson = json['services'] as List? ?? [];

    return HomeCategory(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      imageUrl: json['icon'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      services: servicesJson
          .map((e) => HomeService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
