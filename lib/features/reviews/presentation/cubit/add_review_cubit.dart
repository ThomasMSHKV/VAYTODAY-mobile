import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/features/reviews/data/reviews_repository.dart';
import 'package:VayToday/features/reviews/presentation/cubit/add_review_state.dart';

class AddReviewCubit extends Cubit<AddReviewState> {
  final ReviewsRepository _repository;

  AddReviewCubit(this._repository) : super(const AddReviewInitial());

  Future<void> submit({
    required int companyId,
    required String text,
    required int rating,
  }) async {
    if (state is AddReviewSubmitting) return;

    emit(const AddReviewSubmitting());

    try {
      await _repository.createReview(
        companyId: companyId,
        text: text,
        rating: rating,
      );
      emit(const AddReviewSuccess());
    } on ReviewsApiException catch (error) {
      emit(AddReviewFailure(error.message));
    } catch (_) {
      emit(const AddReviewFailure('Не удалось отправить отзыв'));
    }
  }
}
