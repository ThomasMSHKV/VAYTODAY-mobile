import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/company_detail/domain/models/company_assortment_item.dart';

class AssortmentCard extends StatelessWidget {
  final CompanyAssortmentItem item;
  final VoidCallback? onTap;

  const AssortmentCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 140,
          decoration: BoxDecoration(
            color: AppColors.detailLightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 94,
                  width: double.infinity,
                  child: item.imageUrl.isEmpty
                      ? const _ImagePlaceholder()
                      : CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 360,
                          fadeInDuration: Duration.zero,
                          placeholder: (context, url) =>
                              const _ImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              const _ImagePlaceholder(),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.price ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if ((item.oldPrice ?? '').trim().isNotEmpty) ...[
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  item.oldPrice!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.detailTextGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.categoriesHeader,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
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

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.detailLightGreen,
      highlightColor: AppColors.favoriteYellow.withValues(alpha: 0.35),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.detailLightGreen,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
