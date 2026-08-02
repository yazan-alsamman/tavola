import 'api_exception.dart';

/// Standard TAVOLA API success envelope:
/// `{ "success": true, "message": "...", "data": {}, "meta": {} }`.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  final bool success;
  final String message;
  final T data;
  final Map<String, dynamic>? meta;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(Object? raw) parseData,
  }) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: ApiException.coerceMessage(json['message']),
      data: parseData(json['data']),
      meta: json['meta'] is Map
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : null,
    );
  }
}
