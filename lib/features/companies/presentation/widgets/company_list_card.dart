import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';

class CompanyListCard extends StatelessWidget {
  final CompanyModel company;

  const CompanyListCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.companyCardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Основной контент
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Картинка
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 120,
                  child: Image.network(
                    company.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined, size: 30),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 14),

              /// Текст названии
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 50,
                  ), // 👈 чтобы текст не залезал под рейтинг
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        company.city,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.categoryTitle,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// ⭐ Рейтинг (правый верхний угол)
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              children: [
                Text(
                  company.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.categoryTitle,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3.5),
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.starYellow,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
