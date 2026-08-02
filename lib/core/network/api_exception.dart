import '../constants/app_strings.dart';

/// Normalized API / transport failure for repositories and controllers.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors = const <dynamic>[],
    this.path,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final List<dynamic> errors;
  final String? path;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidation => code == 'VALIDATION_ERROR' || statusCode == 422;

  factory ApiException.fromErrorBody(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    final Object? rawErrors = json['errors'];
    final List<dynamic> errors = rawErrors is List
        ? List<dynamic>.from(rawErrors)
        : const <dynamic>[];
    // NestJS and similar APIs may return `message` as String or List<String>.
    // Never use `as String?` here — a failed cast escapes Dio catch clauses.
    final String rootMessage = coerceMessage(
      json['message'] ?? json['error'] ?? json['detail'],
    );
    final String details = _formatErrorDetails(errors);
    final String message;
    if (details.isNotEmpty) {
      // Prefer field-level details over a generic "Validation failed" banner.
      message = details;
    } else if (rootMessage.isNotEmpty) {
      message = rootMessage;
    } else {
      message = AppStrings.networkUnexpectedError;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      code: _coerceOptionalString(json['code']),
      errors: errors,
      path: _coerceOptionalString(json['path']),
    );
  }

  /// Coerces API `message` fields that may be String, List, or other.
  static String coerceMessage(Object? raw) {
    if (raw == null) {
      return '';
    }
    if (raw is String) {
      return raw.trim();
    }
    if (raw is List) {
      final List<String> parts = <String>[];
      for (final dynamic item in raw) {
        final String part = coerceMessage(item);
        if (part.isNotEmpty) {
          parts.add(part);
        }
      }
      return parts.join('\n');
    }
    if (raw is Map) {
      final Object? nested =
          raw['message'] ?? raw['msg'] ?? raw['error'] ?? raw['detail'];
      final String fromNested = coerceMessage(nested);
      if (fromNested.isNotEmpty) {
        return fromNested;
      }
    }
    return '$raw'.trim();
  }

  /// Safe string field read — never use `as String?` on API JSON.
  static String coerceString(Object? raw, {String fallback = ''}) {
    return coerceOptionalString(raw) ?? fallback;
  }

  /// Safe optional string — never use `as String?` on API JSON.
  static String? coerceOptionalString(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is String) {
      final String trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (raw is num || raw is bool) {
      return '$raw';
    }
    return null;
  }

  /// Safe int field read — APIs sometimes send sortOrder as a string.
  static int coerceInt(Object? raw, {int fallback = 0}) {
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim()) ?? fallback;
    }
    return fallback;
  }

  static String? _coerceOptionalString(Object? raw) =>
      coerceOptionalString(raw);

  static String _formatErrorDetails(List<dynamic> errors) {
    if (errors.isEmpty) {
      return '';
    }

    final List<String> parts = <String>[];
    for (final dynamic item in errors) {
      if (item is String) {
        final String trimmed = item.trim();
        if (trimmed.isNotEmpty) {
          parts.add(trimmed);
        }
        continue;
      }
      if (item is! Map) {
        continue;
      }
      final Map<Object?, Object?> map = item;
      final String field = '${map['field'] ?? map['path'] ?? ''}'.trim();
      final String detail =
          '${map['message'] ?? map['msg'] ?? map['error'] ?? ''}'.trim();
      if (field.isNotEmpty && detail.isNotEmpty) {
        parts.add('$field: $detail');
      } else if (detail.isNotEmpty) {
        parts.add(detail);
      } else if (field.isNotEmpty) {
        parts.add(field);
      }
    }
    return parts.join('\n');
  }

  factory ApiException.connection() {
    return ApiException(message: AppStrings.networkConnectionError);
  }

  factory ApiException.timeout() {
    return ApiException(message: AppStrings.networkTimeoutError);
  }

  factory ApiException.unauthorized() {
    return ApiException(
      message: AppStrings.networkUnauthorizedError,
      statusCode: 401,
    );
  }

  /// No access token for an action that requires sign-in (guest gate).
  factory ApiException.authRequired() {
    return ApiException(
      message: AppStrings.authSignInRequired,
      statusCode: 401,
    );
  }

  /// Public login/register credential rejection (not session expiry).
  factory ApiException.credentialsRejected() {
    return ApiException(
      message: AppStrings.authCredentialsRejected,
      statusCode: 401,
    );
  }

  factory ApiException.forbidden() {
    return ApiException(
      message: AppStrings.networkForbiddenError,
      statusCode: 403,
    );
  }

  factory ApiException.notFound() {
    return ApiException(
      message: AppStrings.networkNotFoundError,
      statusCode: 404,
    );
  }

  factory ApiException.tooManyRequests() {
    return ApiException(
      message: AppStrings.networkTooManyRequestsError,
      statusCode: 429,
    );
  }

  factory ApiException.server({int? statusCode}) {
    return ApiException(
      message: AppStrings.networkServerError,
      statusCode: statusCode,
    );
  }

  factory ApiException.unexpected([String? message]) {
    return ApiException(
      message: (message != null && message.trim().isNotEmpty)
          ? message
          : AppStrings.networkUnexpectedError,
    );
  }

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}
