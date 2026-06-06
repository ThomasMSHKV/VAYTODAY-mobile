import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/reviews/domain/models/company_review_model.dart';
import 'package:VayToday/features/reviews/presentation/widgets/review_stars.dart';

class ReviewCard extends StatelessWidget {
  final CompanyReviewModel review;

  const ReviewCard({super.key, required this.review});

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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Алексей Чанов',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.authText,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '+7 (927) ***-**-**',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
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
