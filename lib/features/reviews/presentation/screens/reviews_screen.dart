import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_required_action.dart';
import 'package:VayToday/features/companies/data/company_management_repository.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/reviews/data/reviews_repository.dart';
import 'package:VayToday/features/reviews/domain/models/company_review_model.dart';
import 'package:VayToday/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:VayToday/features/reviews/presentation/cubit/reviews_state.dart';
import 'package:VayToday/features/reviews/presentation/screens/add_review_screen.dart';
import 'package:VayToday/features/reviews/presentation/widgets/review_card.dart';
import 'package:VayToday/features/reviews/presentation/widgets/review_stars.dart';

class ReviewsScreen extends StatelessWidget {
  final CompanyModel company;

  const ReviewsScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewsCubit(ReviewsRepository())..loadReviews(company.id),
      child: _ReviewsView(company: company),
    );
  }
}

class _ReviewsView extends StatelessWidget {
  final CompanyModel company;

  const _ReviewsView({required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: BlocConsumer<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (state is ReviewsLoaded && state.replyError.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.replyError)));
            }
          },
          builder: (context, state) {
            if (state is ReviewsInitial || state is ReviewsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReviewsFailure) {
              return _ReviewsScaffold(
                company: company,
                averageRating: company.rating,
                reviewsCount: 0,
                userRating: 0,
                repliesCount: 0,
                isCompanyOwner: false,
                onWriteReview: () => _handleWriteReview(context),
                child: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }

            final loaded = state as ReviewsLoaded;

            return _ReviewsScaffold(
              company: company,
              averageRating: loaded.averageRating,
              reviewsCount: loaded.reviewsCount,
              userRating: loaded.userRating,
              repliesCount: loaded.repliesCount,
              isCompanyOwner: loaded.isCompanyOwner,
              onWriteReview: () => _handleWriteReview(context),
              child: loaded.reviews.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'У этой компании пока нет отзывов',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 22),
                      sliver: SliverList.separated(
                        itemCount: loaded.reviews.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final review = loaded.reviews[index];
                          return ReviewCard(
                            review: review,
                            canReply: loaded.isCompanyOwner,
                            isUpdatingReply:
                                loaded.updatingReplyId == review.id,
                            onReplyTap: () => _showReplyDialog(context, review),
                          );
                        },
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleWriteReview(BuildContext context) async {
    final isOwnCompany = await CompanyManagementRepository().hasCompany(
      company.id,
    );
    if (!context.mounted) return;

    if (isOwnCompany) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нельзя оставить отзыв своей компании')),
      );
      return;
    }

    final isCreated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddReviewScreen(company: company)),
    );

    if (!context.mounted || isCreated != true) return;

    await context.read<ReviewsCubit>().loadReviews(company.id);
  }

  Future<void> _showReplyDialog(
    BuildContext context,
    CompanyReviewModel review,
  ) async {
    final reply = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _ReplyDialog(review: review),
    );

    if (reply == null || !context.mounted) return;
    await context.read<ReviewsCubit>().saveReply(review: review, reply: reply);
  }
}

class _ReviewsScaffold extends StatelessWidget {
  final CompanyModel company;
  final double averageRating;
  final int reviewsCount;
  final int userRating;
  final int repliesCount;
  final bool isCompanyOwner;
  final VoidCallback onWriteReview;
  final Widget child;

  const _ReviewsScaffold({
    required this.company,
    required this.averageRating,
    required this.reviewsCount,
    required this.userRating,
    required this.repliesCount,
    required this.isCompanyOwner,
    required this.onWriteReview,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.detailTextGreen,
                    size: 28,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Отзывы',
                      style: TextStyle(
                        color: AppColors.authText,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.authText,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    company.displayAddress,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Средняя\nоценка',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.detailTextGreen,
                                fontSize: 36,
                                height: 1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.favoriteYellow,
                              size: 33,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'На основе $reviewsCount\nотзывов',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, color: AppColors.border),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompanyOwner ? 'Ваши ответы' : 'Ваша оценка',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (isCompanyOwner) ...[
                          Text(
                            '$repliesCount',
                            style: const TextStyle(
                              color: AppColors.detailTextGreen,
                              fontSize: 36,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'из $reviewsCount отзывов',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ] else
                          ReviewStars(
                            rating: userRating.toDouble(),
                            size: 25,
                            spacing: 2,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isCompanyOwner)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: AuthRequiredAction(
                  dialogMessage: 'Чтобы написать отзыв, нужно войти в аккаунт.',
                  onAuthorized: onWriteReview,
                  builder: (context, onTap, isChecking) {
                    return ElevatedButton(
                      onPressed: isChecking ? null : onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.detailTextGreen,
                        foregroundColor: AppColors.white,
                        elevation: 7,
                        shadowColor: AppColors.detailTextGreen.withValues(
                          alpha: 0.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: isChecking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text(
                              'Написать отзыв',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Text.rich(
              TextSpan(
                text: 'Отзывы: ',
                children: [
                  TextSpan(
                    text: '$reviewsCount',
                    style: const TextStyle(color: AppColors.detailTextGreen),
                  ),
                ],
              ),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ReplyDialog extends StatefulWidget {
  final CompanyReviewModel review;

  const _ReplyDialog({required this.review});

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.review.reply);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.review.reply.isEmpty
            ? 'Ответить на отзыв'
            : 'Редактировать ответ',
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 1000,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Введите ответ компании'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Введите текст ответа';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.of(context).pop(_controller.text.trim());
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
