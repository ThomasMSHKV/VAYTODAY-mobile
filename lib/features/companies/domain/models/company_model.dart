import 'package:VayToday/features/home/domain/models/home_category.dart';

class CompanyImageModel {
  final int id;
  final String imageUrl;

  const CompanyImageModel({required this.id, required this.imageUrl});

  factory CompanyImageModel.fromJson(Map<String, dynamic> json) {
    return CompanyImageModel(
      id: _parseInt(json['id']),
      imageUrl: json['image']?.toString() ?? '',
    );
  }
}

class CompanyModel {
  final int id;
  final String title;
  final String description;
  final double rating;
  final bool recommendated;
  final bool isActive;
  final List<HomeService> services;
  final List<HomeService> similarServices;
  final List<CompanyImageModel> images;
  final List<int> cities;
  final int? address;
  final String addressName;
  final String addressLatitude;
  final String addressLongitude;
  final String cityName;
  final String workStart;
  final String workEnd;
  final int visits;

  const CompanyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.recommendated,
    required this.isActive,
    required this.services,
    required this.similarServices,
    required this.images,
    required this.cities,
    required this.address,
    required this.addressName,
    required this.addressLatitude,
    required this.addressLongitude,
    required this.cityName,
    required this.workStart,
    required this.workEnd,
    required this.visits,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final servicesJson = json['services'] as List? ?? [];
    final similarServicesJson = json['similar_services'] as List? ?? [];
    final imagesJson = json['images'] as List? ?? [];
    final citiesJson = json['cities'] as List? ?? [];
    final addressJson = json['address'];

    return CompanyModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rating: double.tryParse('${json['rating'] ?? '0'}') ?? 0,
      recommendated: json['recommendated'] == true,
      isActive: json['is_active'] == true,
      services: servicesJson
          .whereType<Map<String, dynamic>>()
          .map(HomeService.fromJson)
          .toList(),
      similarServices: similarServicesJson
          .whereType<Map<String, dynamic>>()
          .map(HomeService.fromJson)
          .toList(),
      images: imagesJson
          .whereType<Map<String, dynamic>>()
          .map(CompanyImageModel.fromJson)
          .toList(),
      cities: citiesJson
          .map(_parseRelationId)
          .where((id) => id != null)
          .cast<int>()
          .toList(),
      address: _parseRelationId(addressJson),
      addressName: _parseAddressField(addressJson, 'name'),
      addressLatitude: _parseAddressField(addressJson, 'latitude'),
      addressLongitude: _parseAddressField(addressJson, 'longitude'),
      cityName: _parseCityName(citiesJson),
      workStart: json['work_start']?.toString() ?? '',
      workEnd: json['work_end']?.toString() ?? '',
      visits: _parseInt(json['visits']),
    );
  }

  String get imageUrl {
    if (images.isEmpty) return '';
    return images.first.imageUrl;
  }

  List<String> get imageUrls {
    return images
        .map((e) => e.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();
  }

  String get categoryName {
    if (services.isEmpty) return 'Компания';
    return services.first.name;
  }

  String get servicesText {
    if (services.isEmpty) return 'Услуги';
    return services.map((service) => service.name).join(', ');
  }

  String get detailSubtitle {
    if (services.isEmpty) return 'Компания';
    return servicesText;
  }

  String get serviceName {
    if (services.isEmpty) return 'Услуга';
    return services.first.name;
  }

  String get displayAddress {
    if (addressName.trim().isNotEmpty) return addressName.trim();
    if (cityName.trim().isNotEmpty) return cityName.trim();
    return 'Адрес пока не указан';
  }

  bool hasService(int serviceId) {
    return services.any((service) => service.id == serviceId);
  }

  String get workingTime {
    if (workStart.isEmpty && workEnd.isEmpty) {
      return 'Время не указано';
    }

    return '$workStart - $workEnd';
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseRelationId(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is String) {
      return int.tryParse(value);
    }

    if (value is Map<String, dynamic>) {
      return _parseInt(value['id']);
    }

    if (value is List && value.isNotEmpty) {
      return _parseRelationId(value.first);
    }

    return null;
  }

  static String _parseAddressField(dynamic value, String field) {
    if (value is Map<String, dynamic>) {
      return value[field]?.toString() ?? '';
    }

    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map<String, dynamic>) {
        return first[field]?.toString() ?? '';
      }
    }

    return '';
  }

  static String _parseCityName(List<dynamic> citiesJson) {
    if (citiesJson.isEmpty) return '';

    final first = citiesJson.first;

    if (first is Map<String, dynamic>) {
      return first['name']?.toString() ?? '';
    }

    return '';
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
