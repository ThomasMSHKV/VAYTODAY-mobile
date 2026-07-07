import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/reviews/data/reviews_repository.dart';
import 'package:VayToday/features/reviews/presentation/cubit/add_review_cubit.dart';
import 'package:VayToday/features/reviews/presentation/cubit/add_review_state.dart';

class AddReviewScreen extends StatelessWidget {
  final CompanyModel company;

  const AddReviewScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddReviewCubit(ReviewsRepository()),
      child: _AddReviewView(company: company),
    );
  }
}

class _AddReviewView extends StatefulWidget {
  final CompanyModel company;

  const _AddReviewView({required this.company});

  @override
  State<_AddReviewView> createState() => _AddReviewViewState();
}

class _AddReviewViewState extends State<_AddReviewView> {
  final _textController = TextEditingController();
  int _rating = 0;

  bool get _canSubmit {
    return _rating > 0 && _textController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;

    FocusScope.of(context).unfocus();
    context.read<AddReviewCubit>().submit(
      companyId: widget.company.id,
      text: _textController.text.trim(),
      rating: _rating,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddReviewCubit, AddReviewState>(
      listener: (context, state) {
        if (state is AddReviewSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Отзыв опубликован')));
          Navigator.of(context).pop(true);
        }

        if (state is AddReviewFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isSubmitting = state is AddReviewSubmitting;

        return Scaffold(
          backgroundColor: AppColors.screenBackground,
          appBar: AppBar(
            title: const Text('Добавить отзыв'),
            backgroundColor: AppColors.screenBackground,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.company.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.authText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.company.displayAddress,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Ваша оценка',
                    style: TextStyle(
                      color: AppColors.authText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RatingSelector(
                    rating: _rating,
                    isEnabled: !isSubmitting,
                    onChanged: (rating) => setState(() => _rating = rating),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Ваш отзыв',
                    style: TextStyle(
                      color: AppColors.authText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    enabled: !isSubmitting,
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 1000,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Расскажите о вашем опыте',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _canSubmit && !isSubmitting ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.detailTextGreen,
                        foregroundColor: AppColors.white,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Опубликовать отзыв'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RatingSelector extends StatelessWidget {
  final int rating;
  final bool isEnabled;
  final ValueChanged<int> onChanged;

  const _RatingSelector({
    required this.rating,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = value <= rating;

        return IconButton(
          tooltip: '$value из 5',
          onPressed: isEnabled ? () => onChanged(value) : null,
          iconSize: 40,
          padding: const EdgeInsets.only(right: 6),
          constraints: const BoxConstraints(minWidth: 46, minHeight: 46),
          icon: Icon(
            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
            color: isSelected ? AppColors.favoriteYellow : AppColors.textLight,
          ),
        );
      }),
    );
  }
}
