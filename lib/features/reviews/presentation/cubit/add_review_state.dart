import 'package:equatable/equatable.dart';

sealed class AddReviewState extends Equatable {
  const AddReviewState();

  @override
  List<Object?> get props => [];
}

class AddReviewInitial extends AddReviewState {
  const AddReviewInitial();
}

class AddReviewSubmitting extends AddReviewState {
  const AddReviewSubmitting();
}

class AddReviewSuccess extends AddReviewState {
  const AddReviewSuccess();
}

class AddReviewFailure extends AddReviewState {
  final String message;

  const AddReviewFailure(this.message);

  @override
  List<Object?> get props => [message];
}
