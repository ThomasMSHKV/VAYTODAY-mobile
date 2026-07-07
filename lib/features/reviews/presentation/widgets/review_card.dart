import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/reviews/domain/models/company_review_model.dart';
import 'package:VayToday/features/reviews/presentation/widgets/review_stars.dart';

class ReviewCard extends StatelessWidget {
  final CompanyReviewModel review;
  final bool canReply;
  final bool isUpdatingReply;
  final VoidCallback? onReplyTap;

  const ReviewCard({
    super.key,
    required this.review,
    this.canReply = false,
    this.isUpdatingReply = false,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.displayUsername,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.authText,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ReviewStars(
                    rating: review.rating.toDouble(),
                    size: 22,
                    spacing: 0,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(review.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            review.text.isEmpty
                ? 'Пользователь пока не добавил текст отзыва.'
                : review.text,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 17,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (review.reply.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Ответ компании: ${review.reply}',
              style: const TextStyle(
                color: AppColors.detailTextGreen,
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (canReply) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: isUpdatingReply ? null : onReplyTap,
              icon: isUpdatingReply
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      review.reply.isEmpty
                          ? Icons.reply_rounded
                          : Icons.edit_outlined,
                    ),
              label: Text(
                review.reply.isEmpty ? 'Ответить' : 'Редактировать ответ',
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '';

    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'мая',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
