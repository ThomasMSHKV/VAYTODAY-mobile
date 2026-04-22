import 'package:VayToday/features/home/domain/models/popular_company.dart';
import 'package:flutter/material.dart';

class PopularCompanyCard extends StatelessWidget {
  final PopularCompany company;

  const PopularCompanyCard({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE9D9A8),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.network(
                    company.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined, size: 42),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB27D2F).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        company.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD54F),
                        size: 16,
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD54F),
                        size: 16,
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD54F),
                        size: 16,
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD54F),
                        size: 16,
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD54F),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            company.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            company.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}