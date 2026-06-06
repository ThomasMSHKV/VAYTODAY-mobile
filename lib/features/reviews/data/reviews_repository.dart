import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/reviews/domain/models/company_review_model.dart';

class ReviewsRepository {
  Future<int> getCompanyReviewsCount(int companyId) async {
    final response = await getCompanyReviews(companyId);
    return response.count > 0 ? response.count : response.reviews.length;
  }

  Future<ReviewsResponse> getCompanyReviews(int companyId) async {
    final response = await ApiClient.dio.get(
      'company-reviews',
      queryParameters: {'company': companyId},
    );

    final results = response.data['results'] as List? ?? [];

    final reviews = results
        .whereType<Map<String, dynamic>>()
        .map(CompanyReviewModel.fromJson)
        .where((review) => review.companyId == companyId)
        .toList();

    return ReviewsResponse(
      count: _parseInt(response.data['count']),
      reviews: reviews,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ReviewsResponse {
  final int count;
  final List<CompanyReviewModel> reviews;

  const ReviewsResponse({required this.count, required this.reviews});
}
