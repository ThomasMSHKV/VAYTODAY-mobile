class CompanyReviewModel {
  final int id;
  final int companyId;
  final String text;
  final String reply;
  final int rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyReviewModel({
    required this.id,
    required this.companyId,
    required this.text,
    required this.reply,
    required this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyReviewModel.fromJson(Map<String, dynamic> json) {
    return CompanyReviewModel(
      id: _parseInt(json['id']),
      companyId: _parseInt(json['company']),
      text: json['text']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      rating: _parseRating(json['rating']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _parseRating(dynamic value) {
    final rating = _parseInt(value);
    if (rating < 1) return 1;
    if (rating > 5) return 5;
    return rating;
  }
}
