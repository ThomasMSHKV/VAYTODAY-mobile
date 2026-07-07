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

  Map<String, dynamic> toJson() {
    return {'id': id, 'image': imageUrl};
  }
}

class CompanyModel {
  final int id;
  final String title;
  final String description;
  final String email;
  final String phones;
  final double rating;
  final bool recommendated;
  final bool isActive;
  final List<HomeService> services;
  final List<HomeService> similarServices;
  final List<CompanyImageModel> images;
  final List<int> cities;
  final int? address;
  final String manualAddress;
  final String addressName;
  final String addressLatitude;
  final String addressLongitude;
  final String cityName;
  final String workStart;
  final String workEnd;
  final int visits;
  final int reviewsCount;

  const CompanyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.email,
    required this.phones,
    required this.rating,
    required this.recommendated,
    required this.isActive,
    required this.services,
    required this.similarServices,
    required this.images,
    required this.cities,
    required this.address,
    required this.manualAddress,
    required this.addressName,
    required this.addressLatitude,
    required this.addressLongitude,
    required this.cityName,
    required this.workStart,
    required this.workEnd,
    required this.visits,
    required this.reviewsCount,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final servicesJson = _parseServices(json);
    final similarServicesJson = json['similar_services'] as List? ?? [];
    final imagesJson = json['images'] as List? ?? [];
    final citiesJson = json['cities'] as List? ?? [];
    final addressJson = json['address'] ?? json['address_field'];

    return CompanyModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phones: json['phones']?.toString() ?? json['phone']?.toString() ?? '',
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
      manualAddress: _parseManualAddress(json),
      addressName: _parseAddressField(addressJson, 'name'),
      addressLatitude: _parseAddressField(addressJson, 'latitude'),
      addressLongitude: _parseAddressField(addressJson, 'longitude'),
      cityName: json['city_name']?.toString() ?? _parseCityName(citiesJson),
      workStart: json['work_start']?.toString() ?? '',
      workEnd: json['work_end']?.toString() ?? '',
      visits: _parseInt(json['visits']),
      reviewsCount: _parseReviewsCount(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'email': email,
      'phones': phones,
      'rating': rating,
      'recommendated': recommendated,
      'is_active': isActive,
      'services': services.map((service) => service.toJson()).toList(),
      'similar_services': similarServices
          .map((service) => service.toJson())
          .toList(),
      'images': images.map((image) => image.toJson()).toList(),
      'cities': cities,
      'address': address,
      'address_text': manualAddress,
      'address_name': addressName,
      'latitude': addressLatitude,
      'longitude': addressLongitude,
      'city_name': cityName,
      'work_start': workStart,
      'work_end': workEnd,
      'visits': visits,
      'reviews_count': reviewsCount,
    };
  }

  CompanyModel copyWith({
    String? phones,
    String? manualAddress,
    List<CompanyImageModel>? images,
  }) {
    return CompanyModel(
      id: id,
      title: title,
      description: description,
      email: email,
      phones: phones ?? this.phones,
      rating: rating,
      recommendated: recommendated,
      isActive: isActive,
      services: services,
      similarServices: similarServices,
      images: images ?? this.images,
      cities: cities,
      address: address,
      manualAddress: manualAddress ?? this.manualAddress,
      addressName: addressName,
      addressLatitude: addressLatitude,
      addressLongitude: addressLongitude,
      cityName: cityName,
      workStart: workStart,
      workEnd: workEnd,
      visits: visits,
      reviewsCount: reviewsCount,
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
    if (services.isEmpty) return 'Р С™Р С•Р СР С—Р В°Р Р…Р С‘РЎРЏ';
    return services.first.name;
  }

  String get servicesText {
    if (services.isEmpty) return 'Р Р€РЎРѓР В»РЎС“Р С–Р С‘';
    return services.map((service) => service.name).join(', ');
  }

  String get detailSubtitle {
    if (services.isEmpty) return 'Р С™Р С•Р СР С—Р В°Р Р…Р С‘РЎРЏ';
    return servicesText;
  }

  String get serviceName {
    if (services.isEmpty) return 'Р Р€РЎРѓР В»РЎС“Р С–Р В°';
    return services.first.name;
  }

  String get displayAddress {
    if (manualAddress.trim().isNotEmpty) return manualAddress.trim();
    if (addressName.trim().isNotEmpty) return addressName.trim();
    if (cityName.trim().isNotEmpty) return cityName.trim();
    return 'Р С’Р Т‘РЎР‚Р ВµРЎРѓ Р С—Р С•Р С”Р В° Р Р…Р Вµ РЎС“Р С”Р В°Р В·Р В°Р Р…';
  }

  bool hasService(int serviceId) {
    return services.any((service) => service.id == serviceId);
  }

  String get workingTime {
    if (workStart.isEmpty && workEnd.isEmpty) {
      return 'Р вЂ™РЎР‚Р ВµР СРЎРЏ Р Р…Р Вµ РЎС“Р С”Р В°Р В·Р В°Р Р…Р С•';
    }

    return '${_formatTime(workStart)} - ${_formatTime(workEnd)}';
  }

  static String _formatTime(String value) {
    final match = RegExp(r'^(\d{1,2}:\d{2})(?::\d{2})$').firstMatch(value);
    return match?.group(1) ?? value;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _parseReviewsCount(Map<String, dynamic> json) {
    for (final key in [
      'reviews_count',
      'reviewsCount',
      'review_count',
      'comments_count',
    ]) {
      final count = _parseInt(json[key]);
      if (count > 0) return count;
    }

    final reviews = json['reviews'];
    if (reviews is List) return reviews.length;

    return 0;
  }

  static List<dynamic> _parseServices(Map<String, dynamic> json) {
    final services = json['services'];
    if (services is List) return services;

    final service = json['service'];
    if (service is Map) return [service];

    return const [];
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

  static String _parseManualAddress(Map<String, dynamic> json) {
    for (final key in [
      'address_text',
      'address_name',
      'manual_address',
      'custom_address',
    ]) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    final addressField = json['address_field'];
    if (addressField is String && int.tryParse(addressField) == null) {
      return addressField.trim();
    }

    final address = json['address'];
    if (address is String && int.tryParse(address) == null) {
      return address.trim();
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
