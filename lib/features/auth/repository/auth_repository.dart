import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_exception.dart';
import '../model/auth_session_tokens_model.dart';
import '../model/customer_auth_response_model.dart';
import '../model/customer_login_request_model.dart';
import '../model/customer_password_reset_request_models.dart';
import '../model/customer_registration_request_models.dart';
import '../model/customer_registration_response_model.dart';

/// Public customer authentication and session endpoints under `/auth`.
///
/// Uses a dedicated Dio instance (no Bearer interceptor) because login,
/// registration, password reset, and refresh are public (`noauth`) and must
/// not recurse through [ApiClient] auth refresh.
class AuthRepository {
  AuthRepository({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? AppUrls.apiBaseUrl,
              connectTimeout: AppDimensions.apiConnectTimeout,
              receiveTimeout: AppDimensions.apiReceiveTimeout,
              sendTimeout: AppDimensions.apiSendTimeout,
              headers: const <String, dynamic>{
                Headers.acceptHeader: Headers.jsonContentType,
                Headers.contentTypeHeader: Headers.jsonContentType,
              },
              responseType: ResponseType.json,
              validateStatus: (int? status) =>
                  status != null && status >= 200 && status < 300,
            ),
          ) {
    if (dio == null) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final HttpClient client = HttpClient();
          client.connectionTimeout = AppDimensions.apiConnectTimeout;
          return client;
        },
      );
    }
  }

  final Dio _dio;

  static const String refreshPath = '/auth/refresh';
  static const String customerLoginPath = '/auth/customer/login';
  static const String customerRegisterStartPath =
      '/auth/customer/register/start';
  static const String customerRegisterResendPath =
      '/auth/customer/register/resend';
  static const String customerRegisterVerifyPath =
      '/auth/customer/register/verify';
  static const String customerRegisterCompletePath =
      '/auth/customer/register/complete';
  static const String customerPasswordResetStartPath =
      '/auth/customer/password-reset/start';
  static const String customerPasswordResetResendPath =
      '/auth/customer/password-reset/resend';
  static const String customerPasswordResetVerifyPath =
      '/auth/customer/password-reset/verify';
  static const String customerPasswordResetCompletePath =
      '/auth/customer/password-reset/complete';

  /// `POST /auth/customer/login`
  Future<CustomerAuthResponseModel> loginCustomer(
    CustomerLoginRequestModel request,
  ) async {
    final ({CustomerAuthResponseModel data, String message}) result =
        await _post<CustomerAuthResponseModel>(
          customerLoginPath,
          data: request.toJson(),
          parseData: (Object? raw) {
            return CustomerAuthResponseModel.fromJson(
              _requireStringKeyedMap(raw),
            );
          },
        );
    if (!result.data.isValid) {
      throw ApiException(message: AppStrings.invalidAuthSessionPayload);
    }
    return result.data;
  }

  /// `POST /auth/customer/register/start`
  Future<AuthOperationResponseModel> startCustomerRegistration(
    CustomerRegistrationStartRequestModel request,
  ) async {
    final ({Object? data, String message}) result = await _post<Object?>(
      customerRegisterStartPath,
      data: request.toJson(),
      parseData: (Object? raw) => raw,
    );
    return AuthOperationResponseModel(message: result.message);
  }

  /// `POST /auth/customer/register/resend`
  Future<AuthOperationResponseModel> resendCustomerRegistrationCode(
    CustomerRegistrationResendRequestModel request,
  ) async {
    final ({Object? data, String message}) result = await _post<Object?>(
      customerRegisterResendPath,
      data: request.toJson(),
      parseData: (Object? raw) => raw,
    );
    return AuthOperationResponseModel(message: result.message);
  }

  /// `POST /auth/customer/register/verify`
  Future<AuthOperationResponseModel> verifyCustomerRegistration(
    CustomerRegistrationVerifyRequestModel request,
  ) async {
    final ({Object? data, String message}) result = await _post<Object?>(
      customerRegisterVerifyPath,
      data: request.toJson(),
      parseData: (Object? raw) => raw,
    );
    return AuthOperationResponseModel(message: result.message);
  }

  /// `POST /auth/customer/register/complete`
  Future<CustomerRegistrationResponseModel> completeCustomerRegistration(
    CustomerRegistrationCompleteRequestModel request,
  ) async {
    final ({CustomerRegistrationResponseModel data, String message}) result =
        await _post<CustomerRegistrationResponseModel>(
          customerRegisterCompletePath,
          data: request.toJson(),
          parseData: (Object? raw) {
            return CustomerRegistrationResponseModel.fromJson(
              _requireStringKeyedMap(
                raw,
                message: AppStrings.invalidCustomerRegistrationPayload,
              ),
            );
          },
        );
    if (!result.data.isValid) {
      throw ApiException(
        message: AppStrings.invalidCustomerRegistrationPayload,
      );
    }
    return result.data;
  }

  /// `POST /auth/customer/password-reset/start`
  Future<AuthOperationResponseModel> startCustomerPasswordReset(
    CustomerPasswordResetStartRequestModel request,
  ) async {
    final ({Object? data, String message}) result = await _post<Object?>(
      customerPasswordResetStartPath,
      data: request.toJson(),
      parseData: (Object? raw) => raw,
    );
    return AuthOperationResponseModel(message: result.message);
  }

  /// `POST /auth/customer/password-reset/resend`
  Future<AuthOperationResponseModel> resendCustomerPasswordResetCode(
    CustomerPasswordResetResendRequestModel request,
  ) async {
    final ({Object? data, String message}) result = await _post<Object?>(
      customerPasswordResetResendPath,
      data: request.toJson(),
      parseData: (Object? raw) => raw,
    );
    return AuthOperationResponseModel(message: result.message);
  }

  /// `POST /auth/customer/password-reset/verify`
  Future<AuthOperationResponseModel> verifyCustomerPasswordReset(
    CustomerPasswordResetVerifyRequestModel request,
  ) async {
    final ({Object? data, String message}) result = await _post<Object?>(
      customerPasswordResetVerifyPath,
      data: request.toJson(),
      parseData: (Object? raw) => raw,
    );
    return AuthOperationResponseModel(message: result.message);
  }

  /// `POST /auth/customer/password-reset/complete`
  Future<AuthOperationResponseModel> completeCustomerPasswordReset(
    CustomerPasswordResetCompleteRequestModel request,
  ) async {
    final ({Object? data, String message}) result = await _post<Object?>(
      customerPasswordResetCompletePath,
      data: request.toJson(),
      parseData: (Object? raw) => raw,
    );
    return AuthOperationResponseModel(message: result.message);
  }

  /// `POST /auth/refresh` — rotates refresh token and issues a new access token.
  Future<AuthSessionTokensModel> refreshSession(String refreshToken) async {
    final String trimmed = refreshToken.trim();
    if (trimmed.isEmpty) {
      throw ApiException(
        message: AppStrings.authRefreshTokenMissing,
        statusCode: 401,
      );
    }

    final ({AuthSessionTokensModel data, String message}) result =
        await _post<AuthSessionTokensModel>(
          refreshPath,
          data: <String, dynamic>{'refreshToken': trimmed},
          // Shorter than login submit — ApiClient also applies authRefreshTimeout.
          timeout: AppDimensions.authRefreshTimeout,
          parseData: (Object? raw) {
            // Dio may surface `data` as Map (not Map<String, dynamic>).
            // A failed `as` cast used to abort refresh and leave a rotated
            // server-side refresh token unused → token-family revocation.
            return AuthSessionTokensModel.fromJson(_requireStringKeyedMap(raw));
          },
        );
    if (!result.data.isValid) {
      // Rotation responses must include the new refresh token. Reusing the
      // pre-rotation token revokes the entire family on the next call.
      throw ApiException(
        message: AppStrings.invalidAuthSessionPayload,
        statusCode: 401,
      );
    }
    return result.data;
  }

  Future<({T data, String message})> _post<T>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(Object? raw) parseData,
    Duration? timeout,
  }) async {
    final Duration wait = timeout ?? AppDimensions.authSubmitTimeout;
    final CancelToken cancelToken = CancelToken();
    try {
      final Response<dynamic> response = await _dio
          .post<dynamic>(
            path,
            data: data,
            cancelToken: cancelToken,
            options: Options(
              // Auth UX must not spin forever when the host is unreachable.
              sendTimeout: wait,
              receiveTimeout: wait,
            ),
          )
          .timeout(
            wait,
            onTimeout: () {
              if (!cancelToken.isCancelled) {
                cancelToken.cancel(AppStrings.networkTimeoutError);
              }
              throw ApiException.timeout();
            },
          );
      final Object? body = response.data;
      final Map<String, dynamic>? envelope = _asStringKeyedMap(body);
      if (envelope == null) {
        throw ApiException.unexpected();
      }
      if (envelope['success'] != true) {
        throw ApiException.fromErrorBody(
          envelope,
          statusCode: response.statusCode,
        );
      }
      try {
        // Prefer nested `data`; some gateways flatten tokens onto the envelope.
        Object? payload = envelope['data'];
        if (payload == null &&
            (envelope.containsKey('accessToken') ||
                envelope.containsKey('refreshToken'))) {
          payload = envelope;
        }
        return (
          data: parseData(payload),
          message: _coerceEnvelopeMessage(envelope['message']),
        );
      } on ApiException {
        rethrow;
      } catch (_) {
        // Malformed `data` must become ApiException — never a raw TypeError
        // that escapes to the Flutter framework and crashes the app.
        throw ApiException.unexpected();
      }
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      try {
        throw _mapDioException(error);
      } on ApiException {
        rethrow;
      } catch (_) {
        throw ApiException.unexpected();
      }
    } on TimeoutException {
      throw ApiException.timeout();
    } catch (_) {
      throw ApiException.unexpected();
    }
  }

  static Map<String, dynamic> _requireStringKeyedMap(
    Object? raw, {
    String? message,
  }) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    throw ApiException(
      message: message ?? AppStrings.invalidAuthSessionPayload,
    );
  }

  static String _coerceEnvelopeMessage(Object? raw) {
    if (raw is String) {
      return raw.trim();
    }
    if (raw is List) {
      return raw
          .map((dynamic item) => item is String ? item.trim() : '$item')
          .where((String item) => item.isNotEmpty)
          .join('\n');
    }
    if (raw == null) {
      return AppStrings.empty;
    }
    return '$raw'.trim();
  }

  ApiException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout();
      case DioExceptionType.connectionError:
        return ApiException.connection();
      case DioExceptionType.badResponse:
        final Response<dynamic>? response = error.response;
        final Object? data = response?.data;
        final Map<String, dynamic>? errorBody = _asStringKeyedMap(data);
        if (errorBody != null) {
          return ApiException.fromErrorBody(
            errorBody,
            statusCode: response?.statusCode,
          );
        }
        // No JSON envelope — status-based fallbacks for public auth.
        // Never use [ApiException.unauthorized] here: that copy is session
        // expiry for Bearer APIs, not wrong password on Login.
        return _mapBareAuthStatus(response?.statusCode);
      case DioExceptionType.cancel:
        // Auth CancelToken is only cancelled from [authSubmitTimeout].
        return ApiException.timeout();
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return ApiException.connection();
    }
  }

  static ApiException _mapBareAuthStatus(int? status) {
    switch (status) {
      case 401:
        return ApiException.credentialsRejected();
      case 403:
        return ApiException.forbidden();
      case 404:
        return ApiException.notFound();
      case 429:
        return ApiException.tooManyRequests();
      default:
        if (status != null && status >= 500) {
          return ApiException.server(statusCode: status);
        }
        return ApiException(
          message: AppStrings.networkUnexpectedError,
          statusCode: status,
        );
    }
  }

  static Map<String, dynamic>? _asStringKeyedMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
