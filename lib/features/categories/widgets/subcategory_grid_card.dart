import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/presentation/screens/companies_screen.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

class SubcategoryGridCard extends StatelessWidget {
  final HomeService service;
  final String imageUrl;

  const SubcategoryGridCard({
    super.key,
    required this.service,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CompaniesScreen(
              subcategoryTitle: service.name,
              serviceId: service.id,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.categoryCardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 8,
              right: 8,
              child: Text(
                service.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.categoryTitle,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 48,
              bottom: -8,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined, size: 34),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
