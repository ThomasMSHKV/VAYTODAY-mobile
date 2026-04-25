import 'dart:async';
import 'package:VayToday/features/home/domain/models/recommendation_item.dart';
import 'package:flutter/material.dart';

class RecommendationCarousel extends StatefulWidget {
  final List<RecommendationItem> items;

  const RecommendationCarousel({super.key, required this.items});

  @override
  State<RecommendationCarousel> createState() => _RecommendationCarouselState();
}

class _RecommendationCarouselState extends State<RecommendationCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  static const double _horizontalPadding = 20;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 1);

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.items.isEmpty) return;

      final nextPage = (_currentPage + 1) % widget.items.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            padEnds: false,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: _RecommendationCard(item: item),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _RecommendationIndicator(
          length: widget.items.length,
          currentPage: _currentPage,
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendationItem item;

  const _RecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, size: 44),
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8EA28E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationIndicator extends StatelessWidget {
  final int length;
  final int currentPage;

  const _RecommendationIndicator({
    required this.length,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 14,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE5BE59) : const Color(0xFFB8C3B3),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
