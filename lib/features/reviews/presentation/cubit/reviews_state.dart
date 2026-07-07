import 'package:equatable/equatable.dart';
import 'package:VayToday/features/reviews/domain/models/company_review_model.dart';

sealed class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {
  const ReviewsInitial();
}

class ReviewsLoading extends ReviewsState {
  const ReviewsLoading();
}

class ReviewsLoaded extends ReviewsState {
  final int count;
  final List<CompanyReviewModel> reviews;
  final int userRating;
  final bool isCompanyOwner;
  final int? updatingReplyId;
  final String replyError;

  const ReviewsLoaded({
    required this.count,
    required this.reviews,
    required this.userRating,
    required this.isCompanyOwner,
    this.updatingReplyId,
    this.replyError = '',
  });

  ReviewsLoaded copyWith({
    List<CompanyReviewModel>? reviews,
    int? updatingReplyId,
    bool clearUpdatingReply = false,
    String replyError = '',
  }) {
    return ReviewsLoaded(
      count: count,
      reviews: reviews ?? this.reviews,
      userRating: userRating,
      isCompanyOwner: isCompanyOwner,
      updatingReplyId: clearUpdatingReply
          ? null
          : updatingReplyId ?? this.updatingReplyId,
      replyError: replyError,
    );
  }

  int get reviewsCount => count > 0 ? count : reviews.length;

  int get repliesCount {
    return reviews.where((review) => review.reply.trim().isNotEmpty).length;
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (total, review) => total + review.rating);
    return sum / reviews.length;
  }

  @override
  List<Object?> get props => [
    count,
    reviews,
    userRating,
    isCompanyOwner,
    updatingReplyId,
    replyError,
  ];
}

class ReviewsFailure extends ReviewsState {
  final String message;

  const ReviewsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
