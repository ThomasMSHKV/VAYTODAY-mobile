import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class CompanyImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const CompanyImageCarousel({
    super.key,
    required this.imageUrls,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  State<CompanyImageCarousel> createState() => _CompanyImageCarouselState();
}

class _CompanyImageCarouselState extends State<CompanyImageCarousel> {
  static const int _initialPage = 1000;

  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.imageUrls.length > 1 ? _initialPage : 0,
    );
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant CompanyImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.length != widget.imageUrls.length) {
      _currentPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(
          widget.imageUrls.length > 1 ? _initialPage : 0,
        );
      }
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.imageUrls.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.imageUrls.length <= 1) return;

      final nextPage = (_pageController.page?.round() ?? _initialPage) + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 204,
              width: double.infinity,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _stopAutoScroll();
                  }

                  if (notification is ScrollEndNotification) {
                    _startAutoScroll();
                  }

                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length > 1
                      ? null
                      : widget.imageUrls.length,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  clipBehavior: Clip.hardEdge,
                  onPageChanged: (index) {
                    setState(
                      () => _currentPage = index % widget.imageUrls.length,
                    );
                  },
                  itemBuilder: (context, index) {
                    final imageUrl =
                        widget.imageUrls[index % widget.imageUrls.length];

                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      placeholder: (context, url) => const _ImagePlaceholder(),
                      errorWidget: (context, url, error) =>
                          const _ImagePlaceholder(),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 20,
              child: GestureDetector(
                onTap: widget.onFavoriteTap,
                child: Icon(
                  widget.isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: widget.isFavorite
                      ? AppColors.favoriteYellow
                      : Colors.white,
                  size: 34,
                ),
              ),
            ),
          ],
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              final isActive = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 14,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.authGold
                      : AppColors.categoriesHeader.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
        ],
      ],
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
      child: Container(color: AppColors.detailLightGreen),
    );
  }
}
