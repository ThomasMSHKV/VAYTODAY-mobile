import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/company_visits/data/company_visits_repository.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/company_detail/domain/models/company_assortment_item.dart';
import 'package:VayToday/features/company_detail/widgets/assortment_card.dart';
import 'package:VayToday/features/company_detail/widgets/company_detail_app_bar.dart';
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
      if (mounted) {
        setState(() {
          _isFavoriteRequestInProgress = false;
        });
      }
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
        oldPrice: product.oldPrice.isEmpty ? null : product.oldPrice,
      );
    }).toList();
  }

  void _showProductDetails(ProductModel product) {
    showDialog<void>(
      context: context,
      builder: (_) => _ProductDetailsDialog(product: product),
    );
  }

  Future<void> _shareCompanyLink() async {
    final link = 'https://vaytoday.ru/company/${widget.company.id}';
    await Clipboard.setData(ClipboardData(text: link));
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final imageUrls = company.imageUrls.isEmpty
        ? [company.imageUrl]
        : company.imageUrls;
    const bottomContentPadding = 28.0;

    return Scaffold(
      backgroundColor: AppColors.categoriesHeader,
      // First release: map and chat actions are disabled until these flows are ready.
      // bottomNavigationBar: CompanyDetailBottomBar(
      //   onMapTap: () {},
      //   onMessageTap: () {},
      // ),
      body: CustomScrollView(
        slivers: [
          CompanyDetailAppBar(onShareTap: _shareCompanyLink),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.screenBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
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
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.categoryTitle,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  CompanyImageCarousel(
                    imageUrls: imageUrls,
                    isFavorite: _isFavorite,
                    onFavoriteTap: _toggleFavorite,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      28,
                      20,
                      bottomContentPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.detailTextGreen,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 18),
                        FutureBuilder<List<ProductModel>>(
                          future: _productsFuture,
                          builder: (context, snapshot) {
                            final products = snapshot.data ?? const [];
                            final assortmentItems = _mapProductsToAssortment(
                              products,
                            );

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 170,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
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
                              height: 170,
                              child: ListView.separated(
                                clipBehavior: Clip.none,
                                scrollDirection: Axis.horizontal,
                                itemCount: assortmentItems.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  return AssortmentCard(
                                    item: assortmentItems[index],
                                    onTap: () =>
                                        _showProductDetails(products[index]),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 34),
                        Text(
                          company.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
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
                        if (company.phones.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          CompanyInfoRow(
                            icon: Icons.phone_outlined,
                            title: company.phones.trim(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailsDialog extends StatelessWidget {
  final ProductModel product;

  const _ProductDetailsDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: product.imageUrl.isEmpty
                      ? Container(
                          color: AppColors.detailLightGreen,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.detailTextGreen,
                            size: 48,
                          ),
                        )
                      : Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.detailLightGreen,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppColors.detailTextGreen,
                                size: 48,
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                product.title,
                style: const TextStyle(
                  color: AppColors.detailTextGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (product.price.trim().isNotEmpty)
                    Text(
                      product.price.trim(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  if (product.oldPrice.trim().isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Text(
                      product.oldPrice.trim(),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              if (product.description.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  product.description.trim(),
                  style: const TextStyle(
                    color: AppColors.categoryTitle,
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Закрыть'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
