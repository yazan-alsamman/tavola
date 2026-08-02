class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.username = '',
    this.phone,
    this.language,
    this.preferredCurrency,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  /// Customer signup username (`CustomerLoginUserResponseDto.username`).
  final String username;
  final String? phone;
  final String? language;
  final String? preferredCurrency;
  final String? avatarUrl;
  final String? createdAt;
  final String? updatedAt;

  /// Profile card title: signup username first, then name/email fallbacks.
  String get displayName {
    final String user = username.trim();
    if (user.isNotEmpty) {
      return user;
    }
    final String fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    if (email.trim().isNotEmpty) {
      return email.trim();
    }
    return '';
  }

  UserProfileModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? phone,
    String? language,
    String? preferredCurrency,
    String? avatarUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['userId'] as String?) ?? (json['id'] as String?) ?? '',
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      username: (json['username'] as String?)?.trim() ?? '',
      phone: json['phone'] as String?,
      language: json['language'] as String?,
      preferredCurrency: json['preferredCurrency'] as String?,
      avatarUrl:
          (json['avatarUrl'] as String?) ??
          (json['avatar'] as String?) ??
          (json['imageUrl'] as String?),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
