/// Shared helpers for customer login / `/users/me` identity payloads.
///
/// Backend envelopes often split fields across sibling maps (`user`,
/// `customer`, `profile`) — reading only the first nested object drops
/// `username` when it lives on another sibling.
class CustomerIdentityPayload {
  CustomerIdentityPayload._();

  static const List<String> nestedIdentityKeys = <String>[
    'user',
    'profile',
    'customer',
    'account',
    'customerProfile',
  ];

  static const List<String> usernameKeys = <String>[
    'username',
    'userName',
    'name',
    'displayName',
    'preferredUsername',
    'preferred_username',
  ];

  /// Flattens root + known nested identity maps into one field bag.
  static Map<String, dynamic> flatten(Object? raw) {
    if (raw is! Map) {
      return <String, dynamic>{};
    }
    final Map<String, dynamic> root = Map<String, dynamic>.from(raw);
    final List<Map<String, dynamic>> layers = <Map<String, dynamic>>[root];
    for (final String key in nestedIdentityKeys) {
      final Object? nested = root[key];
      if (nested is Map) {
        layers.add(Map<String, dynamic>.from(nested));
      }
    }

    final Map<String, dynamic> merged = <String, dynamic>{};
    for (final Map<String, dynamic> layer in layers) {
      layer.forEach((String key, Object? value) {
        if (value == null) {
          return;
        }
        // Empty strings must not wipe a better sibling (e.g. user.username=""
        // after customer.username="Yazan").
        if (value is String &&
            value.trim().isEmpty &&
            merged.containsKey(key)) {
          return;
        }
        merged[key] = value;
      });
    }

    final String username = readUsername(raw);
    if (username.isNotEmpty) {
      merged['username'] = username;
    }
    return merged;
  }

  /// Finds a non-UUID username anywhere in the payload tree.
  static String readUsername(Object? raw) {
    final String found = _readUsernameDeep(raw);
    if (found.isNotEmpty) {
      return found;
    }
    return '';
  }

  static String _readUsernameDeep(Object? raw) {
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      for (final String key in usernameKeys) {
        final String value = _asScalar(map[key]);
        if (value.isNotEmpty && !_looksLikeUuid(value)) {
          return value;
        }
      }
      for (final Object? value in map.values) {
        final String nested = _readUsernameDeep(value);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    } else if (raw is List) {
      for (final Object? value in raw) {
        final String nested = _readUsernameDeep(value);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
    return '';
  }

  static String _asScalar(Object? raw) {
    if (raw is String) {
      return raw.trim();
    }
    if (raw is num || raw is bool) {
      return '$raw'.trim();
    }
    return '';
  }

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool _looksLikeUuid(String value) => _uuidPattern.hasMatch(value);
}
