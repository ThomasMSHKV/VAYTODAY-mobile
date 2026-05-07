class CompanyAssortmentItem {
  final String title;
  final String imageUrl;
  final String subtitle;
  final String? price;

  const CompanyAssortmentItem({
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    this.price,
  });
}
