import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/company_detail/presentation/screens/company_detail_screen.dart';
import 'package:VayToday/features/products/data/products_repository.dart';
import 'package:VayToday/features/products/domain/models/product_model.dart';

const _screenTitle =
    '\u0422\u043e\u0432\u0430\u0440\u044b \u0438 \u0443\u0441\u043b\u0443\u0433\u0438 \u0432 \u043e\u0434\u0438\u043d \u043a\u043b\u0438\u043a';
const _emptyTitle =
    '\u041f\u043e\u043a\u0430 \u043d\u0435\u0442 \u0442\u043e\u0432\u0430\u0440\u043e\u0432 \u0438 \u0443\u0441\u043b\u0443\u0433';
const _emptyDiscountTitle =
    '\u041f\u043e\u043a\u0430 \u043d\u0435\u0442 \u0442\u043e\u0432\u0430\u0440\u043e\u0432 \u0441\u043e \u0441\u043a\u0438\u0434\u043a\u0430\u043c\u0438';
const _discountOnlyTitle =
    '\u0421\u043e \u0441\u043a\u0438\u0434\u043a\u0430\u043c\u0438';
const _descriptionTitle = '\u041e\u043f\u0438\u0441\u0430\u043d\u0438\u0435';
const _companyLabel = '\u041a\u043e\u043c\u043f\u0430\u043d\u0438\u044f: ';

class DiscountProductsScreen extends StatefulWidget {
  const DiscountProductsScreen({super.key});

  @override
  State<DiscountProductsScreen> createState() => _DiscountProductsScreenState();
}

class _DiscountProductsScreenState extends State<DiscountProductsScreen> {
  final _repository = ProductsRepository();
  final _searchController = TextEditingController();
  final _companyCache = <int, CompanyModel>{};
  Timer? _searchDebounce;
  List<_DiscountProductEntry> _entries = const [];
  bool _discountOnly = false;
  bool _isLoading = true;
  String _searchQuery = '';
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final requestId = ++_requestId;
    setState(() => _isLoading = true);

    try {
      final products = await _repository.getProducts(
        limit: 300,
        query: _searchQuery,
        discountedOnly: _discountOnly,
      );
      final entries = <_DiscountProductEntry>[];

      for (final product in products) {
        try {
          if (_discountOnly && !product.isOnDiscountAd) continue;
          final company =
              _companyCache[product.companyId] ??
              await _repository.getProductCompany(product.companyId);
          _companyCache[product.companyId] = company;

          if (!company.isActive || !_matchesQuery(product, company)) continue;
          entries.add(
            _DiscountProductEntry(product: product, company: company),
          );
        } catch (_) {
          continue;
        }
      }

      entries.shuffle(Random(DateTime.now().microsecondsSinceEpoch));
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _entries = const [];
        _isLoading = false;
      });
    }
  }

  bool _matchesQuery(ProductModel product, CompanyModel company) {
    final query = _searchQuery.toLowerCase();
    if (query.isEmpty) return true;

    return product.title.toLowerCase().contains(query) ||
        product.description.toLowerCase().contains(query) ||
        company.title.toLowerCase().contains(query);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final query = value.trim();
      if (query == _searchQuery) return;
      _searchQuery = query;
      _loadEntries();
    });
  }

  Future<void> _refresh() async {
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final emptyTitle = _discountOnly ? _emptyDiscountTitle : _emptyTitle;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _ProductSearchField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _FiltersBar(
                  discountOnly: _discountOnly,
                  onDiscountToggle: () {
                    setState(() => _discountOnly = !_discountOnly);
                    _loadEntries();
                  },
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        emptyTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  sliver: SliverGrid.builder(
                    itemCount: _entries.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      return _DiscountProductCard(entry: _entries[index]);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 22, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.categoryTitle,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              _screenTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontSize: 17,
                height: 1.16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ProductSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.authGold,
        decoration: InputDecoration(
          hintText: '\u041f\u043e\u0438\u0441\u043a',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.blueGrey.shade500,
            size: 24,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.authGold, width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final bool discountOnly;
  final VoidCallback onDiscountToggle;

  const _FiltersBar({
    required this.discountOnly,
    required this.onDiscountToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        scrollDirection: Axis.horizontal,
        children: [
          _DiscountChip(isSelected: discountOnly, onTap: onDiscountToggle),
        ],
      ),
    );
  }
}

class _DiscountChip extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _DiscountChip({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: isSelected ? 1.04 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.authGold
                  : AppColors.cityFilterInactive,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.authGold : Colors.transparent,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? AppColors.authGold : Colors.black)
                      .withValues(alpha: isSelected ? 0.26 : 0.10),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('selected'),
                          color: Colors.white,
                          size: 16,
                        )
                      : const Icon(
                          Icons.percent_rounded,
                          key: ValueKey('idle'),
                          color: AppColors.categoryTitle,
                          size: 15,
                        ),
                ),
                const SizedBox(width: 6),
                Text(
                  _discountOnlyTitle.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.categoryTitle,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w800,
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

class _DiscountProductCard extends StatefulWidget {
  final _DiscountProductEntry entry;

  const _DiscountProductCard({required this.entry});

  @override
  State<_DiscountProductCard> createState() => _DiscountProductCardState();
}

class _DiscountProductCardState extends State<_DiscountProductCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _openDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DiscountProductDetailsSheet(entry: widget.entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final product = widget.entry.product;
    final company = widget.entry.company;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openDetails(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(imageUrl: product.imageUrl, height: 96),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PriceRow(
                        product: product,
                        priceSize: 14,
                        oldPriceSize: 11,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          product.description.trim().isNotEmpty
                              ? product.description.trim()
                              : company.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            height: 1.18,
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }
}

class _DiscountProductDetailsSheet extends StatelessWidget {
  final _DiscountProductEntry entry;

  const _DiscountProductDetailsSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final product = entry.product;
    final company = entry.company;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: _ProductImage(imageUrl: product.imageUrl, height: 230),
              ),
              const SizedBox(height: 18),
              Text(
                product.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _PriceRow(product: product, priceSize: 22, oldPriceSize: 16),
              if (product.description.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  _descriptionTitle,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Material(
                color: AppColors.detailLightGreen,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CompanyDetailScreen(company: company),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.detailTextGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(
                                color: AppColors.detailTextGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                              children: [
                                const TextSpan(text: _companyLabel),
                                TextSpan(
                                  text: company.title,
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.detailTextGreen,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final double height;

  const _ProductImage({required this.imageUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: AppColors.categoryCardBackground,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: height > 120 ? 54 : 32,
          color: Colors.grey.shade500,
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        cacheKey: imageUrl,
        memCacheWidth: height > 120 ? 900 : 420,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        placeholderFadeInDuration: Duration.zero,
        placeholder: (context, url) =>
            Container(color: AppColors.categoryCardBackground),
        errorWidget: (context, url, error) => Container(
          color: AppColors.categoryCardBackground,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_outlined,
            size: height > 120 ? 54 : 32,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final ProductModel product;
  final double priceSize;
  final double oldPriceSize;

  const _PriceRow({
    required this.product,
    required this.priceSize,
    required this.oldPriceSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            product.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.authGold,
              fontSize: priceSize,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (product.oldPrice.trim().isNotEmpty) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              product.oldPrice,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: oldPriceSize,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.lineThrough,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DiscountProductEntry {
  final ProductModel product;
  final CompanyModel company;

  const _DiscountProductEntry({required this.product, required this.company});
}
