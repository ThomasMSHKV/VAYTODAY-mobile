class CompanyReviewModel {
  final int id;
  final int companyId;
  final String text;
  final String reply;
  final String username;
  final int rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyReviewModel({
    required this.id,
    required this.companyId,
    required this.text,
    required this.reply,
    required this.username,
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
      username: _parseUsername(json),
      rating: _parseRating(json['rating']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  CompanyReviewModel copyWith({String? reply}) {
    return CompanyReviewModel(
      id: id,
      companyId: companyId,
      text: text,
      reply: reply ?? this.reply,
      username: username,
      rating: rating,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get displayUsername {
    final value = username.trim();
    if (value.isEmpty || value.contains('@') || _looksLikePhone(value)) {
      return 'Пользователь';
    }

    return value;
  }

  static String _parseUsername(Map<String, dynamic> json) {
    for (final key in ['username', 'user_name', 'author_name']) {
      final value = _readText(json[key]);
      if (value.isNotEmpty) return value;
    }

    for (final key in ['user', 'author', 'created_by']) {
      final value = json[key];
      if (value is Map) {
        final nested = Map<String, dynamic>.from(value);
        for (final nestedKey in ['username', 'user_name', 'name']) {
          final username = _readText(nested[nestedKey]);
          if (username.isNotEmpty) return username;
        }
      } else {
        final username = _readText(value);
        if (username.isNotEmpty && int.tryParse(username) == null) {
          return username;
        }
      }
    }

    return '';
  }

  static String _readText(dynamic value) => value?.toString().trim() ?? '';

  static bool _looksLikePhone(String value) {
    if (!RegExp(r'^[\d\s()+-]+$').hasMatch(value)) return false;

    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7;
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
