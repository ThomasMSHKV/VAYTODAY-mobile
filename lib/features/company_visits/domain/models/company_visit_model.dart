class CompanyVisitModel {
  final int id;
  final int companyId;
  final int? userId;
  final String ipAddress;
  final DateTime? createdAt;

  const CompanyVisitModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.ipAddress,
    required this.createdAt,
  });

  factory CompanyVisitModel.fromJson(Map<String, dynamic> json) {
    return CompanyVisitModel(
      id: _parseInt(json['id']),
      companyId: _parseRelationId(json['company']),
      userId: _parseNullableRelationId(json['user']),
      ipAddress: json['ip_address']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _parseRelationId(dynamic value) {
  if (value is Map<String, dynamic>) {
    return _parseInt(value['id']);
  }

  return _parseInt(value);
}

int? _parseNullableRelationId(dynamic value) {
  if (value == null) return null;
  return _parseRelationId(value);
}
