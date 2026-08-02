import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../features/auth/model/auth_session_tokens_model.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_urls.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'auth_token_reader.dart';
import 'jwt_payload.dart';
import 'secure_auth_token_store.dart';

/// Shared Dio HTTP client for TAVLA REST API.
///
/// Feature repositories call endpoints through this client.
///
/// When [tokenReader] is an [AuthTokenSession] and [authRepository] is set,
/// access tokens refresh automatically via `POST /auth/refresh`:
/// - proactively before JWT expiry (see [AppDimensions.accessTokenRefreshSkew])
/// - reactively on HTTP 401 (single retry)
///
/// Failed refresh on a 401 calls [onSessionExpired].
class ApiClient {
  ApiClient({
    Dio? dio,
    AuthTokenReader? tokenReader,
    this._authRepository,
    this._onSessionExpired,
    String? baseUrl,
  }) : _tokenReader = tokenReader ?? const EmptyAuthTokenReader(),
       _dio =
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
    // Physical iOS can hang in DNS / TCP connect without firing Dio timeouts.
    // Force dart:io HttpClient deadlines and a Future ceiling in [_request].
    if (dio == null) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final HttpClient client = HttpClient();
          client.connectionTimeout = AppDimensions.apiConnectTimeout;
          return client;
        },
      );
    }
    if (const bool.fromEnvironment('HTTP_TRACE', defaultValue: false)) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                // ignore: avoid_print — opt-in HTTP lifecycle tracing only.
                print('[HTTP_TRACE] ${options.method} ${options.uri}');
                handler.next(options);
              },
          onResponse:
              (Response<dynamic> response, ResponseInterceptorHandler handler) {
                // ignore: avoid_print
                print(
                  '[HTTP_TRACE] ← ${response.statusCode} ${response.requestOptions.uri}',
                );
                handler.next(response);
              },
          onError: (DioException error, ErrorInterceptorHandler handler) {
            // ignore: avoid_print
            print('[HTTP_TRACE] ✕ ${error.type} ${error.requestOptions.uri}');
            handler.next(error);
          },
        ),
      );
    }
    _dio.interceptors.add(
      // Non-queued: public taxonomy (`skipAuth`) must never wait behind a
      // hanging Keychain read / refresh / protected HTTP call. Refresh races
      // are already serialized by [_refreshInFlight] + bare-Dio 401 retry.
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              try {
                if (options.extra[_skipAuthExtraKey] != true) {
                  await _ensureFreshAccessToken();
                  if (handler.isCompleted) {
                    return;
                  }
                  final String? token = await _tokenReader.readAccessToken();
                  if (token != null && token.isNotEmpty) {
                    options.headers['Authorization'] = 'Bearer $token';
                  } else {
                    options.headers.remove('Authorization');
                  }
                }
                if (!handler.isCompleted) {
                  handler.next(options);
                }
              } catch (error) {
                if (handler.isCompleted) {
                  return;
                }
                handler.reject(
                  error is DioException
                      ? error
                      : DioException(
                          requestOptions: options,
                          error: error,
                          type: DioExceptionType.unknown,
                        ),
                );
              }
            },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          void passError([DioException? nextError]) {
            if (!handler.isCompleted) {
              handler.next(nextError ?? error);
            }
          }

          void passResponse(Response<dynamic> response) {
            if (!handler.isCompleted) {
              handler.resolve(response);
            }
          }

          final RequestOptions requestOptions = error.requestOptions;
          final bool alreadyRetried =
              requestOptions.extra[_retriedAfterRefreshExtraKey] == true;
          final bool skipRefresh =
              requestOptions.extra[_skipAuthExtraKey] == true;
          final bool isUnauthorized = error.response?.statusCode == 401;

          if (!isUnauthorized || alreadyRetried || skipRefresh) {
            passError();
            return;
          }

          // Sibling requests may already have rotated tokens while this 401
          // still carries the pre-rotation Bearer. Refreshing again with the
          // new refresh token would rotate (and risk family revoke) needlessly.
          final bool refreshed;
          final bool expireSessionOnFailure;
          if (await _requestBearerIsStale(requestOptions)) {
            refreshed = true;
            expireSessionOnFailure = false;
          } else {
            final _RefreshOutcome outcome = await _tryRefreshSession();
            refreshed = outcome == _RefreshOutcome.success;
            expireSessionOnFailure = outcome == _RefreshOutcome.unauthorized;
          }
          if (handler.isCompleted) {
            return;
          }
          if (!refreshed) {
            // Expire only on invalid/revoked refresh — never on network blips.
            if (expireSessionOnFailure) {
              final String? refresh = await _session?.readRefreshToken();
              if (refresh != null && refresh.trim().isNotEmpty) {
                await _notifySessionExpired();
                passError();
                return;
              }
              // No refresh token: guest or wiped memory session — not "expired".
              passError(
                DioException(
                  requestOptions: requestOptions,
                  response: error.response,
                  type: error.type,
                  error: ApiException.authRequired(),
                ),
              );
              return;
            }
            passError();
            return;
          }

          try {
            final String? token = await _tokenReader.readAccessToken();
            if (token != null && token.isNotEmpty) {
              requestOptions.headers['Authorization'] = 'Bearer $token';
            }
            requestOptions.extra[_retriedAfterRefreshExtraKey] = true;
            // Retry on a bare Dio (same adapter/options, no interceptors).
            // Re-entering this interceptor on retry failure used to deadlock
            // under QueuedInterceptorsWrapper; bare fetch stays the safe path.
            final Response<dynamic> response = await _fetchWithoutInterceptors(
              requestOptions,
            );
            passResponse(response);
          } on DioException catch (retryError) {
            passError(retryError);
          } catch (_) {
            passError();
          }
        },
      ),
    );
  }

  static const String _skipAuthExtraKey = 'skipAuth';
  static const String _retriedAfterRefreshExtraKey = 'retriedAfterRefresh';

  /// Public endpoints (`/cuisine-categories`, `/occasion-categories`, …)
  /// must not wait on the auth refresh queue.
  static Options skipAuthOptions([Options? base]) {
    final Options options = base ?? Options();
    return options.copyWith(
      extra: <String, dynamic>{...?options.extra, _skipAuthExtraKey: true},
    );
  }

  final Dio _dio;
  final AuthTokenReader _tokenReader;
  final AuthRepository? _authRepository;
  final FutureOr<void> Function()? _onSessionExpired;

  Future<void>? _refreshInFlight;
  _RefreshOutcome? _lastRefreshOutcome;
  DateTime? _proactiveRefreshCooldownUntil;

  Dio get dio => _dio;

  /// HTTP fetch that bypasses auth interceptors (used for 401 retry).
  Future<Response<dynamic>> _fetchWithoutInterceptors(
    RequestOptions requestOptions,
  ) {
    final Dio bare = Dio()
      ..options = _dio.options
      ..httpClientAdapter = _dio.httpClientAdapter;
    return bare.fetch<dynamic>(requestOptions);
  }

  /// True when the session access token is newer than this request's Bearer.
  Future<bool> _requestBearerIsStale(RequestOptions options) async {
    final String? current = await _tokenReader.readAccessToken();
    if (current == null || current.isEmpty) {
      return false;
    }
    final Object? header = options.headers['Authorization'];
    if (header is! String || !header.startsWith('Bearer ')) {
      return false;
    }
    final String used = header.substring('Bearer '.length).trim();
    return used.isNotEmpty && used != current;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? raw) parseData,
    Options? options,
  }) {
    return _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
      parseData: parseData,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? raw) parseData,
    Options? options,
  }) {
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parseData: parseData,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? raw) parseData,
    Options? options,
  }) {
    return _request(
      () => _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parseData: parseData,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? raw) parseData,
    Options? options,
  }) {
    return _request(
      () => _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parseData: parseData,
    );
  }

  /// DELETE that accepts empty success bodies (e.g. HTTP 204).
  Future<void> deleteNoContent(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response<dynamic> response = await _dio
          .delete<dynamic>(
            path,
            queryParameters: queryParameters,
            options: options,
          )
          .timeout(AppDimensions.apiHardRequestTimeout);
      final int? status = response.statusCode;
      if (status != null && status >= 200 && status < 300) {
        return;
      }
      throw ApiException.unexpected();
    } on TimeoutException {
      throw ApiException.timeout();
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw ApiException.unexpected();
    }
  }

  /// POST that accepts empty or non-envelope success bodies (e.g. 201 favorites).
  Future<void> postNoContent(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response<dynamic> response = await _dio
          .post<dynamic>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          )
          .timeout(AppDimensions.apiHardRequestTimeout);
      final int? status = response.statusCode;
      if (status != null && status >= 200 && status < 300) {
        return;
      }
      throw ApiException.unexpected();
    } on TimeoutException {
      throw ApiException.timeout();
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw ApiException.unexpected();
    }
  }

  /// Multipart POST (e.g. avatar upload). Clears default JSON content-type.
  Future<ApiResponse<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? raw) parseData,
    Options? options,
  }) {
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          contentType: Headers.multipartFormDataContentType,
        ),
      ),
      parseData: parseData,
    );
  }

  Future<void> _ensureFreshAccessToken() async {
    final AuthTokenSession? session = _session;
    if (session == null || _authRepository == null) {
      return;
    }

    final String? accessToken = await session.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    if (!JwtPayload.needsRefresh(
      accessToken,
      skew: AppDimensions.accessTokenRefreshSkew,
    )) {
      return;
    }

    final DateTime? cooldownUntil = _proactiveRefreshCooldownUntil;
    if (cooldownUntil != null && DateTime.now().isBefore(cooldownUntil)) {
      // Dead-host refresh already failed recently — do not stall every API.
      return;
    }

    // Best-effort only. Session expiry is owned by the 401 path so a failed
    // proactive refresh cannot clear tokens while a reactive refresh succeeds.
    final _RefreshOutcome outcome = await _tryRefreshSession();
    if (outcome == _RefreshOutcome.transient) {
      _proactiveRefreshCooldownUntil = DateTime.now().add(
        AppDimensions.accessTokenRefreshFailureCooldown,
      );
    } else if (outcome == _RefreshOutcome.success) {
      _proactiveRefreshCooldownUntil = null;
    }
  }

  Future<_RefreshOutcome> _tryRefreshSession() async {
    final AuthTokenSession? session = _session;
    final AuthRepository? authRepository = _authRepository;
    if (session == null || authRepository == null) {
      return _RefreshOutcome.transient;
    }

    final Future<void>? inFlight = _refreshInFlight;
    if (inFlight != null) {
      await inFlight;
      return _lastRefreshOutcome ?? _RefreshOutcome.transient;
    }

    // Claim the lock synchronously before any await. Starting an async IIFE
    // first allowed concurrent `/auth/refresh` calls; reusing a rotated refresh
    // token revokes the whole token family on the API.
    final Completer<void> completer = Completer<void>();
    _refreshInFlight = completer.future;

    try {
      final String? refreshToken = await session.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw ApiException(
          message: AppStrings.authRefreshTokenMissing,
          statusCode: 401,
        );
      }

      final AuthSessionTokensModel tokens = await authRepository
          .refreshSession(refreshToken)
          .timeout(AppDimensions.authRefreshTimeout);
      // Refresh ALWAYS rotates the refresh token on the API. Never fall back
      // to the pre-rotation token — reuse revokes the whole token family.
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        throw ApiException(
          message: AppStrings.invalidAuthSessionPayload,
          statusCode: 401,
        );
      }
      await session.updateSessionTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      if (session is SecureAuthTokenStore) {
        // Refresh is not on the Login→Home critical path; persist soon.
        session.scheduleDiskPersist();
      }
      _lastRefreshOutcome = _RefreshOutcome.success;
      return _RefreshOutcome.success;
    } on TimeoutException {
      _lastRefreshOutcome = _RefreshOutcome.transient;
      return _RefreshOutcome.transient;
    } catch (error) {
      final _RefreshOutcome outcome = _classifyRefreshFailure(error);
      _lastRefreshOutcome = outcome;
      return outcome;
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      _refreshInFlight = null;
    }
  }

  static _RefreshOutcome _classifyRefreshFailure(Object error) {
    if (error is ApiException) {
      if (error.isUnauthorized || error.isForbidden) {
        return _RefreshOutcome.unauthorized;
      }
      if (error.message == AppStrings.authRefreshTokenMissing) {
        return _RefreshOutcome.unauthorized;
      }
    }
    return _RefreshOutcome.transient;
  }

  Future<void> _notifySessionExpired() async {
    final FutureOr<void> Function()? callback = _onSessionExpired;
    if (callback == null) {
      return;
    }
    await callback();
  }

  AuthTokenSession? get _session {
    final AuthTokenReader reader = _tokenReader;
    if (reader is AuthTokenSession) {
      return reader;
    }
    return null;
  }

  Future<ApiResponse<T>> _request<T>(
    Future<Response<dynamic>> Function() send, {
    required T Function(Object? raw) parseData,
  }) async {
    try {
      // Physical iOS can stall in DNS/connect such that Dio's own timeouts
      // never complete. This ceiling always unblocks Home / auth callers.
      final Response<dynamic> response = await send().timeout(
        AppDimensions.apiHardRequestTimeout,
      );
      final Map<String, dynamic>? body = _asStringKeyedMap(response.data);

      if (body == null) {
        throw ApiException.unexpected();
      }

      final ApiResponse<T> parsed = ApiResponse<T>.fromJson(
        body,
        parseData: parseData,
      );

      if (!parsed.success) {
        throw ApiException.fromErrorBody(body, statusCode: response.statusCode);
      }

      return parsed;
    } on TimeoutException {
      throw ApiException.timeout();
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
    } catch (_) {
      throw ApiException.unexpected();
    }
  }

  ApiException _mapDioException(DioException error) {
    final Object? nested = error.error;
    if (nested is ApiException) {
      return nested;
    }
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
        final int? status = response?.statusCode;
        if (status == 401) {
          return ApiException.unauthorized();
        }
        if (status != null && status >= 500) {
          return ApiException.server(statusCode: status);
        }
        return ApiException.unexpected();
      case DioExceptionType.cancel:
        return ApiException.unexpected();
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return ApiException.connection();
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

/// Outcome of `POST /auth/refresh` for 401 recovery.
enum _RefreshOutcome { success, unauthorized, transient }
