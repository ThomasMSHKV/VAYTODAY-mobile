import 'package:VayToday/features/company_detail/widgets/assortment_card.dart';
import 'package:VayToday/features/company_detail/widgets/company_detail_app_bar.dart';
import 'package:VayToday/features/company_detail/widgets/company_detail_bottom_bar.dart';
import 'package:VayToday/features/company_detail/widgets/company_image_carousel.dart';
import 'package:VayToday/features/company_detail/widgets/company_info_row.dart';
import 'package:VayToday/features/company_detail/widgets/company_stats_row.dart';
import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/company_detail/data/company_detail_mock_data.dart';

class CompanyDetailScreen extends StatefulWidget {
  const CompanyDetailScreen({super.key});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final company = CompanyDetailMockData.company;

    return Scaffold(
      backgroundColor: AppColors.categoriesHeader,
      bottomNavigationBar: CompanyDetailBottomBar(
        onMapTap: () {},
        onMessageTap: () {},
      ),
      body: CustomScrollView(
        slivers: [
          const CompanyDetailAppBar(),

          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.screenBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 44, 20, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        company.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.detailTextGreen,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        '${company.category}, ${company.subcategory}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.categoryTitle,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    CompanyImageCarousel(
                      imageUrls: company.imageUrls,
                      isFavorite: _isFavorite,
                      onFavoriteTap: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    CompanyStatsRow(
                      rating: company.rating,
                      reviewsCount: company.reviewsCount,
                      workingTime: company.workingTime,
                    ),

                    const SizedBox(height: 34),

                    Text(
                      'Ассортимент',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.detailTextGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 170,
                      child: ListView.separated(
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        itemCount: company.assortment.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return AssortmentCard(
                            item: company.assortment[index],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 34),

                    Text(
                      company.organizationTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.detailTextGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      company.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.categoryTitle,
                        fontSize: 18,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 30),

                    CompanyInfoRow(
                      icon: Icons.location_on_outlined,
                      title: company.address,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
