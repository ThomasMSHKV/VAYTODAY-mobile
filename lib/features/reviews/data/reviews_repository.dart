import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:VayToday/core/network/api_client.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/reviews/domain/models/company_review_model.dart';

class ReviewsApiException implements Exception {
  final String message;

  const ReviewsApiException(this.message);

  @override
  String toString() => message;
}

class ReviewsRepository {
  static const _userRatingKeyPrefix = 'review_user_rating_';

  final AuthSessionStorage _sessionStorage;
  final AuthRepository _authRepository;

  ReviewsRepository({
    AuthSessionStorage? sessionStorage,
    AuthRepository? authRepository,
  }) : _sessionStorage = sessionStorage ?? AuthSessionStorage(),
       _authRepository = authRepository ?? AuthRepository();

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
    final reviewsWithReplies = await Future.wait(
      reviews.map(_loadReplyIfNeeded),
    );

    return ReviewsResponse(
      count: _parseInt(response.data['count']),
      reviews: reviewsWithReplies,
    );
  }

  Future<CompanyReviewModel> createReview({
    required int companyId,
    required String text,
    required int rating,
  }) async {
    final response = await _authorizedRequest(
      (options) => ApiClient.dio.post(
        'company-reviews',
        data: {'company': companyId, 'text': text, 'rating': rating},
        options: options,
      ),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final review = CompanyReviewModel.fromJson(data);
      await _saveUserRating(companyId, rating);
      return review;
    }

    throw const ReviewsApiException('Сервер вернул некорректный ответ');
  }

  Future<CompanyReviewModel> updateReviewReply({
    required CompanyReviewModel review,
    required String reply,
  }) async {
    final response = await _authorizedRequest(
      (options) => ApiClient.dio.patch(
        'company-review-reply/${review.id}',
        data: {'reply': reply.trim()},
        options: options,
      ),
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return review.copyWith(reply: data['reply']?.toString() ?? reply.trim());
    }

    throw const ReviewsApiException('Сервер вернул некорректный ответ');
  }

  Future<CompanyReviewModel> _loadReplyIfNeeded(
    CompanyReviewModel review,
  ) async {
    if (review.reply.isNotEmpty) return review;

    for (final path in [
      'company-review-reply/${review.id}',
      'company-review-reply/${review.id}/',
    ]) {
      try {
        final response = await ApiClient.dio.get(path);
        if (response.data is Map<String, dynamic>) {
          final reply = response.data['reply']?.toString() ?? '';
          return review.copyWith(reply: reply);
        }
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) continue;
        return review;
      } catch (_) {
        return review;
      }
    }

    return review;
  }

  Future<int> getUserRating(int companyId) async {
    final preferences = await SharedPreferences.getInstance();
    final key = await _userRatingKey(companyId);
    final rating = preferences.getInt(key) ?? 0;

    if (rating < 1 || rating > 5) return 0;
    return rating;
  }

  Future<void> _saveUserRating(int companyId, int rating) async {
    final preferences = await SharedPreferences.getInstance();
    final key = await _userRatingKey(companyId);
    await preferences.setInt(key, rating);
  }

  Future<String> _userRatingKey(int companyId) async {
    final email = await _sessionStorage.getEmail() ?? 'anonymous';
    return '$_userRatingKeyPrefix${email}_$companyId';
  }

  Future<Response<dynamic>> _authorizedRequest(
    Future<Response<dynamic>> Function(Options options) request,
  ) async {
    try {
      return await request(await _authOptions());
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) {
        throw ReviewsApiException(_readErrorMessage(error.response?.data));
      }

      final refreshToken = await _sessionStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _sessionStorage.clear();
        throw const ReviewsApiException('Войдите в аккаунт заново');
      }

      try {
        final tokens = await _authRepository.refreshToken(refreshToken);
        await _sessionStorage.saveTokens(tokens);
      } catch (_) {
        await _sessionStorage.clear();
        throw const ReviewsApiException('Сессия истекла. Войдите заново');
      }

      try {
        return await request(await _authOptions());
      } on DioException catch (retryError) {
        throw ReviewsApiException(_readErrorMessage(retryError.response?.data));
      }
    }
  }

  Future<Options> _authOptions() async {
    final accessToken = await _sessionStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ReviewsApiException('Войдите в аккаунт заново');
    }

    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  String _readErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final key in [
        'detail',
        'message',
        'error',
        'reply',
        'text',
        'rating',
      ]) {
        final value = data[key];
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value != null) return value.toString();
      }
    }

    return 'Не удалось отправить отзыв';
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
