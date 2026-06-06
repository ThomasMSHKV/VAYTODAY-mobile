class AuthUserModel {
  final int id;
  final String username;
  final String email;
  final bool isEmailVerified;

  const AuthUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isEmailVerified: json['is_email_verified'] == true ||
          json['is_email_verified']?.toString().toLowerCase() == 'true',
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
