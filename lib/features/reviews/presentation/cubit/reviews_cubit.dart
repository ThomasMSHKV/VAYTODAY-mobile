import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/companies/data/company_management_repository.dart';
import 'package:VayToday/features/reviews/domain/models/company_review_model.dart';
import 'package:VayToday/features/reviews/data/reviews_repository.dart';
import 'package:VayToday/features/reviews/presentation/cubit/reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewsRepository _repository;
  final CompanyManagementRepository _companyRepository;

  ReviewsCubit(
    this._repository, {
    CompanyManagementRepository? companyRepository,
  }) : _companyRepository = companyRepository ?? CompanyManagementRepository(),
       super(const ReviewsInitial());

  Future<void> loadReviews(int companyId) async {
    emit(const ReviewsLoading());

    try {
      final results = await Future.wait([
        _repository.getCompanyReviews(companyId),
        _repository.getUserRating(companyId),
        _companyRepository.hasCompany(companyId),
      ]);
      final response = results[0] as ReviewsResponse;
      final userRating = results[1] as int;
      final isCompanyOwner = results[2] as bool;

      emit(
        ReviewsLoaded(
          count: response.count,
          reviews: response.reviews,
          userRating: userRating,
          isCompanyOwner: isCompanyOwner,
        ),
      );
    } catch (_) {
      emit(const ReviewsFailure('Не удалось загрузить отзывы'));
    }
  }

  Future<void> saveReply({
    required CompanyReviewModel review,
    required String reply,
  }) async {
    final currentState = state;
    if (currentState is! ReviewsLoaded || !currentState.isCompanyOwner) return;
    if (currentState.updatingReplyId != null) return;

    emit(currentState.copyWith(updatingReplyId: review.id));

    try {
      final updatedReview = await _repository.updateReviewReply(
        review: review,
        reply: reply,
      );
      final reviews = currentState.reviews
          .map((item) => item.id == updatedReview.id ? updatedReview : item)
          .toList();

      emit(currentState.copyWith(reviews: reviews, clearUpdatingReply: true));
    } on ReviewsApiException catch (error) {
      emit(
        currentState.copyWith(
          clearUpdatingReply: true,
          replyError: error.message,
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          clearUpdatingReply: true,
          replyError: 'Не удалось сохранить ответ',
        ),
      );
    }
  }
}
