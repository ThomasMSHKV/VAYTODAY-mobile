import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/company_visits/data/company_visits_repository.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/company_detail/domain/models/company_assortment_item.dart';
import 'package:VayToday/features/company_detail/widgets/assortment_card.dart';
import 'package:VayToday/features/company_detail/widgets/company_detail_app_bar.dart';
import 'package:VayToday/features/company_detail/widgets/company_detail_bottom_bar.dart';
import 'package:VayToday/features/company_detail/widgets/company_image_carousel.dart';
import 'package:VayToday/features/company_detail/widgets/company_info_row.dart';
import 'package:VayToday/features/company_detail/widgets/company_stats_row.dart';
import 'package:VayToday/features/products/data/products_repository.dart';
import 'package:VayToday/features/products/domain/models/product_model.dart';
import 'package:VayToday/features/profile/data/profile_repository.dart';
import 'package:VayToday/features/reviews/data/reviews_repository.dart';
import 'package:VayToday/features/reviews/presentation/screens/reviews_screen.dart';

class CompanyDetailScreen extends StatefulWidget {
  final CompanyModel company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isFavorite = false;
  bool _isFavoriteRequestInProgress = false;
  late final Future<int> _reviewsCountFuture;
  late final Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsCountFuture = ReviewsRepository().getCompanyReviewsCount(
      widget.company.id,
    );
    _productsFuture = ProductsRepository().getProductsByCompanyId(
      widget.company.id,
    );
    _loadFavoriteState();
    CompanyVisitsRepository().recordCompanyVisit(widget.company.id);
  }

  Future<void> _loadFavoriteState() async {
    try {
      final isFavorite = await _profileRepository.isFavoriteCompany(
        widget.company.id,
      );

      if (!mounted) return;

      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (_) {
      // The company detail screen is still usable if the user is not logged in
      // or the favorite endpoint is temporarily unavailable.
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteRequestInProgress) return;

    final nextValue = !_isFavorite;

    setState(() {
      _isFavorite = nextValue;
      _isFavoriteRequestInProgress = true;
    });

    try {
      if (nextValue) {
        await _profileRepository.addFavoriteCompany(widget.company);
      } else {
        await _profileRepository.removeFavoriteCompany(widget.company.id);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isFavorite = !nextValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить сохраненные компании'),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isFavoriteRequestInProgress = false;
      });
    }
  }

  List<CompanyAssortmentItem> _mapProductsToAssortment(
    List<ProductModel> products,
  ) {
    return products.map((product) {
      return CompanyAssortmentItem(
        title: product.title,
        imageUrl: product.imageUrl,
        subtitle: product.description,
        price: product.price.isEmpty ? null : product.price,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final imageUrls = company.imageUrls.isEmpty
        ? [company.imageUrl]
        : company.imageUrls;

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
                padding: const EdgeInsets.fromLTRB(20, 44, 20, 130),
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
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        company.detailSubtitle,
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
                      imageUrls: imageUrls,
                      isFavorite: _isFavorite,
                      onFavoriteTap: _toggleFavorite,
                    ),
                    const SizedBox(height: 28),
                    FutureBuilder<int>(
                      future: _reviewsCountFuture,
                      builder: (context, snapshot) {
                        return CompanyStatsRow(
                          rating: company.rating,
                          reviewsCount: snapshot.data ?? 0,
                          workingTime: company.workingTime,
                          onReviewsTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReviewsScreen(company: company),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'Ассортимент',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.detailTextGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FutureBuilder<List<ProductModel>>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        final assortmentItems = _mapProductsToAssortment(
                          snapshot.data ?? const [],
                        );

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 155,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (assortmentItems.isEmpty) {
                          return const Text(
                            'Ассортимент пока не добавлен',
                            style: TextStyle(
                              color: AppColors.categoryTitle,
                              fontSize: 16,
                            ),
                          );
                        }

                        return SizedBox(
                          height: 155,
                          child: ListView.separated(
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            itemCount: assortmentItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              return AssortmentCard(
                                item: assortmentItems[index],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 34),
                    Text(
                      company.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.detailTextGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      company.description.isEmpty
                          ? 'Описание компании пока не добавлено'
                          : company.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.categoryTitle,
                        fontSize: 20,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CompanyInfoRow(
                      icon: Icons.location_on_outlined,
                      title: company.displayAddress,
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
