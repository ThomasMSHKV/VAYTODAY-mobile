import 'dart:async';
import 'package:flutter/material.dart';
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
  static const double _slideGap = 6;

  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _initialPage);

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.imageUrls.isEmpty) return;

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
              height: 240,
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
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final imageIndex = index % widget.imageUrls.length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _slideGap,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          widget.imageUrls[imageIndex],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_outlined, size: 44),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index % widget.imageUrls.length;
                    });
                  },
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: widget.onFavoriteTap,
                child: Icon(
                  Icons.favorite_rounded,
                  color: widget.isFavorite
                      ? AppColors.favoriteYellow
                      : Colors.white,
                  size: 34,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.imageUrls.length, (index) {
            final isActive = index == _currentPage;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 18 : 13,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.categoriesHeader
                    : AppColors.divider.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }
}
