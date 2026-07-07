import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/company_detail/presentation/screens/company_detail_screen.dart';

class CompanyListCard extends StatelessWidget {
  final CompanyModel company;
  final bool isCompact;
  final String? statusLabel;
  final Color? statusColor;
  final Widget? footerAction;

  const CompanyListCard({
    super.key,
    required this.company,
    this.isCompact = false,
    this.statusLabel,
    this.statusColor,
    this.footerAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasFooterAction = footerAction != null;
    final cardHeight = hasFooterAction
        ? (isCompact ? 138.0 : 158.0)
        : (isCompact ? 118.0 : 140.0);
    final imageWidth = isCompact ? 86.0 : 100.0;
    final imageHeight = isCompact ? 92.0 : 112.0;
    final contentPadding = isCompact ? 12.0 : 14.0;
    final titleSize = isCompact ? 15.0 : 16.0;
    final descriptionSize = isCompact ? 11.0 : 12.0;
    final addressSize = isCompact ? 13.0 : 14.0;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: AppColors.companyCardBackground,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CompanyDetailScreen(company: company),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(contentPadding),
            decoration: BoxDecoration(
              color: AppColors.companyCardBackground,
              borderRadius: BorderRadius.circular(18),
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
                          errorBuilder: (context, error, stackTrace) {
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
                        padding: EdgeInsets.only(
                          right: statusLabel == null
                              ? (isCompact ? 44 : 50)
                              : 0,
                          bottom: hasFooterAction ? 38 : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: statusLabel == null ? 0 : 92,
                              ),
                              child: Text(
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
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.only(
                                right: statusLabel == null ? 0 : 92,
                              ),
                              child: Text(
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
                  child: statusLabel == null
                      ? _RatingBadge(company: company, isCompact: isCompact)
                      : _StatusBadge(label: statusLabel!, color: statusColor),
                ),
                if (footerAction != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 126),
                      child: footerAction!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final CompanyModel company;
  final bool isCompact;

  const _RatingBadge({required this.company, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: effectiveColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
