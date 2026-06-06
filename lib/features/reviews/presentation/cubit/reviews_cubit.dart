import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VayToday/features/reviews/data/reviews_repository.dart';
import 'package:VayToday/features/reviews/presentation/cubit/reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewsRepository _repository;

  ReviewsCubit(this._repository) : super(const ReviewsInitial());

  Future<void> loadReviews(int companyId) async {
    emit(const ReviewsLoading());

    try {
      final response = await _repository.getCompanyReviews(companyId);
      emit(ReviewsLoaded(count: response.count, reviews: response.reviews));
    } catch (_) {
      emit(const ReviewsFailure('Не удалось загрузить отзывы'));
    }
  }
}
