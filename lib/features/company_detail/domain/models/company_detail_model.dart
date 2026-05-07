import 'package:VayToday/features/company_detail/domain/models/company_assortment_item.dart';

class CompanyDetailModel {
  final String title;
  final String category;
  final String subcategory;
  final List<String> imageUrls;
  final double rating;
  final int reviewsCount;
  final String workingTime;
  final String organizationTitle;
  final String description;
  final String address;
  final List<CompanyAssortmentItem> assortment;

  const CompanyDetailModel({
    required this.title,
    required this.category,
    required this.subcategory,
    required this.imageUrls,
    required this.rating,
    required this.reviewsCount,
    required this.workingTime,
    required this.organizationTitle,
    required this.description,
    required this.address,
    required this.assortment,
  });
}
