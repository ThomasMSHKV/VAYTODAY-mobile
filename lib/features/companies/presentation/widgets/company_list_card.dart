import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/company_detail/presentation/screens/company_detail_screen.dart';

class CompanyListCard extends StatelessWidget {
  final CompanyModel company;
  final bool isCompact;

  const CompanyListCard({
    super.key,
    required this.company,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = isCompact ? 118.0 : 140.0;
    final imageWidth = isCompact ? 86.0 : 100.0;
    final imageHeight = isCompact ? 92.0 : 112.0;
    final contentPadding = isCompact ? 12.0 : 14.0;
    final titleSize = isCompact ? 15.0 : 16.0;
    final descriptionSize = isCompact ? 11.0 : 12.0;
    final addressSize = isCompact ? 13.0 : 14.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CompanyDetailScreen(company: company),
            ),
          );
        },
        child: Ink(
          height: cardHeight,
          padding: EdgeInsets.all(contentPadding),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: imageWidth,
                      height: imageHeight,
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

                  SizedBox(width: isCompact ? 12 : 14),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isCompact ? 44 : 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            company.description.isEmpty
                                ? 'Описание пока не добавлено'
                                : company.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: descriptionSize,
                                  height: 1.25,
                                ),
                          ),

                          const Spacer(),

                          Text(
                            company.displayAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.categoryTitle,
                                  fontSize: addressSize,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: [
                    Text(
                      company.rating.toStringAsFixed(1),
                      style: TextStyle(
                        color: AppColors.categoryTitle,
                        fontSize: isCompact ? 11 : 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: isCompact ? 2.5 : 3.5),
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.starYellow,
                      size: isCompact ? 18 : 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
