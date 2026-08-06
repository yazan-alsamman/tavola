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
    final String? avatar = _readAvatarUrl(json);
    return UserProfileModel(
      id: _readString(json['userId']) ?? _readString(json['id']) ?? '',
      firstName: _readString(json['firstName']) ?? '',
      lastName: _readString(json['lastName']) ?? '',
      email: _readString(json['email']) ?? '',
      username: _readUsername(json),
      phone: _readPhone(json),
      language: _readString(json['language']),
      preferredCurrency: _readString(json['preferredCurrency']),
      avatarUrl: avatar,
      createdAt: _readString(json['createdAt']),
      updatedAt: _readString(json['updatedAt']),
    );
  }

  static String _readUsername(Map<String, dynamic> json) {
    for (final String key in <String>[
      'username',
      'userName',
      'name',
      'displayName',
      'preferredUsername',
    ]) {
      final String? value = _readString(json[key])?.trim();
      if (value != null && value.isNotEmpty && !_looksLikeUuid(value)) {
        return value;
      }
    }
    return '';
  }

  static String? _readPhone(Map<String, dynamic> json) {
    final String? direct = _readString(json['phone'])?.trim();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }
    final String? countryCode =
        (_readString(json['countryCode']) ?? _readString(json['dialCode']))
            ?.trim();
    final String? national = (_readString(json['phoneNumber']) ??
            _readString(json['nationalNumber']) ??
            _readString(json['mobile']))
        ?.trim();
    if (countryCode != null &&
        countryCode.isNotEmpty &&
        national != null &&
        national.isNotEmpty) {
      final String dial =
          countryCode.startsWith('+') ? countryCode : '+$countryCode';
      final String digits = national.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        return '$dial$digits';
      }
    }
    if (national != null && national.isNotEmpty) {
      return national;
    }
    return null;
  }

  static String? _readString(Object? raw) {
    if (raw is String) {
      return raw;
    }
    if (raw is num || raw is bool) {
      return '$raw';
    }
    return null;
  }

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool _looksLikeUuid(String value) => _uuidPattern.hasMatch(value);

  static String? _readAvatarUrl(Map<String, dynamic> json) {
    final String parsed = _extractAvatarUrl(json).trim();
    return parsed.isEmpty ? null : parsed;
  }

  static String _extractAvatarUrl(Map<String, dynamic> payload) {
    const List<String> preferredKeys = <String>[
      'avatarUrl',
      'avatar_url',
      'avatar',
      'imageUrl',
      'url',
      'path',
      'avatarPath',
      'profileImage',
      'secure_url',
    ];
    for (final String key in preferredKeys) {
      final Object? value = payload[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is Map<String, dynamic>) {
        final String nested = _extractAvatarUrl(value).trim();
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
    for (final Object? value in payload.values) {
      if (value is Map<String, dynamic>) {
        final String nested = _extractAvatarUrl(value).trim();
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
    return '';
  }
}
