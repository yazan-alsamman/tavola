import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/network/jwt_payload.dart';
import 'package:tavla/features/auth/model/auth_session_tokens_model.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthSessionTokensModel', () {
    test('isValid requires both access and refresh (rotation)', () {
      expect(
        const AuthSessionTokensModel(
          accessToken: 'a',
          refreshToken: 'r',
        ).isValid,
        isTrue,
      );
      expect(
        const AuthSessionTokensModel(
          accessToken: 'a',
          refreshToken: '',
        ).isValid,
        isFalse,
      );
    });

    test('fromJson accepts snake_case token keys', () {
      final AuthSessionTokensModel tokens = AuthSessionTokensModel.fromJson(
        <String, dynamic>{'access_token': 'access', 'refresh_token': 'refresh'},
      );
      expect(tokens.accessToken, 'access');
      expect(tokens.refreshToken, 'refresh');
      expect(tokens.isValid, isTrue);
    });
  });

  group('JwtPayload', () {
    test('needsRefresh is false when expiry is far away', () {
      final String token = _jwtWithExpiry(
        DateTime.now().add(const Duration(hours: 1)),
      );
      expect(
        JwtPayload.needsRefresh(token, skew: const Duration(minutes: 2)),
        isFalse,
      );
    });

    test('needsRefresh is true when expiry is within skew', () {
      final String token = _jwtWithExpiry(
        DateTime.now().add(const Duration(seconds: 30)),
      );
      expect(
        JwtPayload.needsRefresh(token, skew: const Duration(minutes: 2)),
        isTrue,
      );
    });

    test('needsRefresh is false for opaque tokens without exp', () {
      expect(
        JwtPayload.needsRefresh('not-a-jwt', skew: const Duration(minutes: 2)),
        isFalse,
      );
    });
  });

  group('ApiClient token + refresh', () {
    test('attaches Bearer from AuthTokenSession', () async {
      final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
        accessToken: 'access-abc',
        refreshToken: 'refresh-abc',
      );
      String? authorization;

      final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      final ApiClient client = ApiClient(dio: dio, tokenReader: session);
      dio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
        authorization = options.headers['Authorization']?.toString();
        return _jsonResponse(
          statusCode: 200,
          body: <String, dynamic>{
            'success': true,
            'message': 'ok',
            'data': <String, dynamic>{'ok': true},
          },
        );
      });

      await client.get<Map<String, dynamic>>(
        '/secure',
        parseData: (Object? raw) =>
            Map<String, dynamic>.from(raw as Map<String, dynamic>),
      );

      expect(authorization, 'Bearer access-abc');
    });

    test(
      'on 401 refreshes tokens, saves them, and retries with new Bearer',
      () async {
        final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        );
        bool sessionExpiredCalled = false;
        int protectedHits = 0;
        final List<String?> authorizationHeaders = <String?>[];

        final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
        final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));

        authDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          expect(options.path, '/auth/refresh');
          final Object? data = options.data;
          expect(data, isA<Map<String, dynamic>>());
          expect((data as Map<String, dynamic>)['refreshToken'], 'old-refresh');
          return _jsonResponse(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'refreshed',
              'data': <String, dynamic>{
                'accessToken': 'new-access',
                'refreshToken': 'new-refresh',
              },
            },
          );
        });

        final ApiClient client = ApiClient(
          dio: apiDio,
          tokenReader: session,
          authRepository: AuthRepository(dio: authDio),
          onSessionExpired: () {
            sessionExpiredCalled = true;
          },
        );

        apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          authorizationHeaders.add(
            options.headers['Authorization']?.toString(),
          );
          protectedHits += 1;
          if (protectedHits == 1) {
            return _jsonResponse(
              statusCode: 401,
              body: <String, dynamic>{
                'success': false,
                'message': 'unauthorized',
                'code': 'UNAUTHORIZED',
              },
            );
          }
          return _jsonResponse(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'ok',
              'data': <String, dynamic>{'ok': true},
            },
          );
        });

        final response = await client.get<Map<String, dynamic>>(
          '/users/me',
          parseData: (Object? raw) =>
              Map<String, dynamic>.from(raw as Map<String, dynamic>),
        );

        expect(response.data['ok'], isTrue);
        expect(protectedHits, 2);
        expect(authorizationHeaders, <String>[
          'Bearer old-access',
          'Bearer new-access',
        ]);
        expect(await session.readAccessToken(), 'new-access');
        expect(await session.readRefreshToken(), 'new-refresh');
        expect(sessionExpiredCalled, isFalse);
      },
    );

    test('proactively refreshes when access JWT is near expiry', () async {
      final String expiringAccess = _jwtWithExpiry(
        DateTime.now().add(const Duration(seconds: 30)),
      );
      final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
        accessToken: expiringAccess,
        refreshToken: 'refresh-live',
      );
      int refreshHits = 0;
      String? authorization;

      final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));

      authDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
        refreshHits += 1;
        expect(options.path, '/auth/refresh');
        return _jsonResponse(
          statusCode: 200,
          body: <String, dynamic>{
            'success': true,
            'message': 'refreshed',
            'data': <String, dynamic>{
              'accessToken': 'fresh-access',
              'refreshToken': 'fresh-refresh',
            },
          },
        );
      });

      final ApiClient client = ApiClient(
        dio: apiDio,
        tokenReader: session,
        authRepository: AuthRepository(dio: authDio),
      );

      apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
        authorization = options.headers['Authorization']?.toString();
        return _jsonResponse(
          statusCode: 200,
          body: <String, dynamic>{
            'success': true,
            'message': 'ok',
            'data': <String, dynamic>{'ok': true},
          },
        );
      });

      await client.get<Map<String, dynamic>>(
        '/users/me',
        parseData: (Object? raw) =>
            Map<String, dynamic>.from(raw as Map<String, dynamic>),
      );

      expect(refreshHits, 1);
      expect(authorization, 'Bearer fresh-access');
      expect(await session.readAccessToken(), 'fresh-access');
      expect(await session.readRefreshToken(), 'fresh-refresh');
    });

    test('calls onSessionExpired when refresh fails after 401', () async {
      final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
        accessToken: 'dead-access',
        refreshToken: 'dead-refresh',
      );
      bool sessionExpiredCalled = false;

      final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));

      authDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
        return _jsonResponse(
          statusCode: 401,
          body: <String, dynamic>{
            'success': false,
            'message': 'invalid refresh',
          },
        );
      });

      final ApiClient client = ApiClient(
        dio: apiDio,
        tokenReader: session,
        authRepository: AuthRepository(dio: authDio),
        onSessionExpired: () {
          sessionExpiredCalled = true;
        },
      );

      apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
        return _jsonResponse(
          statusCode: 401,
          body: <String, dynamic>{'success': false, 'message': 'unauthorized'},
        );
      });

      await expectLater(
        () => client.get<Object?>('/users/me', parseData: (Object? raw) => raw),
        throwsA(isA<ApiException>()),
      );
      expect(sessionExpiredCalled, isTrue);
    });

    test(
      '401 without refresh token is authRequired, not session-expired',
      () async {
        final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
          accessToken: 'stale-access',
          refreshToken: '',
        );

        final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
        final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
        var refreshHits = 0;
        authDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          refreshHits += 1;
          return _jsonResponse(
            statusCode: 401,
            body: <String, dynamic>{'success': false, 'message': 'no refresh'},
          );
        });

        final ApiClient client = ApiClient(
          dio: apiDio,
          tokenReader: session,
          authRepository: AuthRepository(dio: authDio),
        );

        apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          return ResponseBody.fromString(
            'Unauthorized',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['text/plain'],
            },
          );
        });

        await expectLater(
          () => client.get<Object?>(
            '/reservations/availability',
            parseData: (Object? raw) => raw,
          ),
          throwsA(
            isA<ApiException>()
                .having((ApiException e) => e.statusCode, 'status', 401)
                .having(
                  (ApiException e) => e.message,
                  'message',
                  AppStrings.authSignInRequired,
                ),
          ),
        );
        expect(refreshHits, 0);
      },
    );

    test(
      'proactive refresh cooldown skips repeat refresh after transient failure',
      () async {
        final String expiringAccess = _jwtWithExpiry(
          DateTime.now().add(const Duration(seconds: 30)),
        );
        final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
          accessToken: expiringAccess,
          refreshToken: 'refresh-live',
        );
        int refreshHits = 0;

        final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
        final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));

        authDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          refreshHits += 1;
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        });

        final ApiClient client = ApiClient(
          dio: apiDio,
          tokenReader: session,
          authRepository: AuthRepository(dio: authDio),
        );

        apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          return _jsonResponse(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'ok',
              'data': <String, dynamic>{'ok': true},
            },
          );
        });

        await client.get<Map<String, dynamic>>(
          '/users/me',
          parseData: (Object? raw) =>
              Map<String, dynamic>.from(raw as Map<String, dynamic>),
        );
        await client.get<Map<String, dynamic>>(
          '/users/me',
          parseData: (Object? raw) =>
              Map<String, dynamic>.from(raw as Map<String, dynamic>),
        );

        // First proactive attempt fails transiently; second call is cooled down.
        expect(refreshHits, 1);
        expect(await session.readRefreshToken(), 'refresh-live');
      },
    );

    test('does not expire session when refresh fails due to network', () async {
      final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
        accessToken: 'dead-access',
        refreshToken: 'still-valid-refresh',
      );
      bool sessionExpiredCalled = false;

      final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));

      authDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      final ApiClient client = ApiClient(
        dio: apiDio,
        tokenReader: session,
        authRepository: AuthRepository(dio: authDio),
        onSessionExpired: () {
          sessionExpiredCalled = true;
        },
      );

      apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
        return _jsonResponse(
          statusCode: 401,
          body: <String, dynamic>{'success': false, 'message': 'unauthorized'},
        );
      });

      await expectLater(
        () => client.get<Object?>('/users/me', parseData: (Object? raw) => raw),
        throwsA(isA<ApiException>()),
      );
      expect(sessionExpiredCalled, isFalse);
      expect(await session.readRefreshToken(), 'still-valid-refresh');
    });

    test(
      'rejects refresh that returns access without rotated refresh (no stale reuse)',
      () async {
        final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        );
        bool sessionExpiredCalled = false;

        final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
        final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));

        // API rotated server-side but client must not keep pre-rotation refresh.
        authDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          return _jsonResponse(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'refreshed',
              'data': <String, dynamic>{
                'accessToken': 'new-access-only',
                // missing refreshToken — old client kept old-refresh (family revoke)
              },
            },
          );
        });

        final ApiClient client = ApiClient(
          dio: apiDio,
          tokenReader: session,
          authRepository: AuthRepository(dio: authDio),
          onSessionExpired: () {
            sessionExpiredCalled = true;
          },
        );

        apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          return _jsonResponse(
            statusCode: 401,
            body: <String, dynamic>{
              'success': false,
              'message': 'unauthorized',
            },
          );
        });

        await expectLater(
          () =>
              client.get<Object?>('/users/me', parseData: (Object? raw) => raw),
          throwsA(isA<ApiException>()),
        );

        // Must not persist new access + revoked old refresh.
        expect(await session.readAccessToken(), 'old-access');
        expect(await session.readRefreshToken(), 'old-refresh');
        expect(sessionExpiredCalled, isTrue);
      },
    );

    test('concurrent 401s trigger a single refresh call', () async {
      final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
      );
      int refreshHits = 0;
      int protectedHits = 0;

      final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));

      authDio.httpClientAdapter = _CallbackAdapter((
        RequestOptions options,
      ) async {
        refreshHits += 1;
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return _jsonResponse(
          statusCode: 200,
          body: <String, dynamic>{
            'success': true,
            'message': 'refreshed',
            'data': <String, dynamic>{
              'accessToken': 'new-access',
              'refreshToken': 'new-refresh',
            },
          },
        );
      });

      final ApiClient client = ApiClient(
        dio: apiDio,
        tokenReader: session,
        authRepository: AuthRepository(dio: authDio),
      );

      apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
        protectedHits += 1;
        final Object? auth = options.headers['Authorization'];
        if (auth == 'Bearer new-access') {
          return _jsonResponse(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'ok',
              'data': <String, dynamic>{'ok': true},
            },
          );
        }
        return _jsonResponse(
          statusCode: 401,
          body: <String, dynamic>{'success': false, 'message': 'unauthorized'},
        );
      });

      await Future.wait(<Future<void>>[
        client.get<Map<String, dynamic>>(
          '/a',
          parseData: (Object? raw) => Map<String, dynamic>.from(raw as Map),
        ),
        client.get<Map<String, dynamic>>(
          '/b',
          parseData: (Object? raw) => Map<String, dynamic>.from(raw as Map),
        ),
        client.get<Map<String, dynamic>>(
          '/c',
          parseData: (Object? raw) => Map<String, dynamic>.from(raw as Map),
        ),
      ]);

      expect(refreshHits, 1);
      expect(protectedHits, greaterThanOrEqualTo(4));
      expect(await session.readAccessToken(), 'new-access');
      expect(await session.readRefreshToken(), 'new-refresh');
    });

    test(
      '401 refresh success + failed retry completes (no auth interceptor deadlock)',
      () async {
        final _MemoryAuthTokenStore session = _MemoryAuthTokenStore(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        );
        int protectedHits = 0;

        final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
        final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));

        authDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          return _jsonResponse(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'refreshed',
              'data': <String, dynamic>{
                'accessToken': 'new-access',
                'refreshToken': 'new-refresh',
              },
            },
          );
        });

        final ApiClient client = ApiClient(
          dio: apiDio,
          tokenReader: session,
          authRepository: AuthRepository(dio: authDio),
        );

        apiDio.httpClientAdapter = _CallbackAdapter((RequestOptions options) {
          protectedHits += 1;
          if (protectedHits == 1) {
            return _jsonResponse(
              statusCode: 401,
              body: <String, dynamic>{
                'success': false,
                'message': 'unauthorized',
              },
            );
          }
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'retry failed',
          );
        });

        // Before the fix this hung forever (auth interceptor error-queue deadlock).
        await expectLater(
          () => client
              .get<Object?>('/users/me', parseData: (Object? raw) => raw)
              .timeout(const Duration(seconds: 3)),
          throwsA(isA<ApiException>()),
        );
        expect(protectedHits, 2);
        expect(await session.readAccessToken(), 'new-access');
      },
    );
  });
}

class _MemoryAuthTokenStore implements AuthTokenSession {
  _MemoryAuthTokenStore({
    required String this._accessToken,
    required String this._refreshToken,
  });

  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearSessionTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this._onFetch);

  final FutureOr<ResponseBody> Function(RequestOptions options) _onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return await _onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse({
  required int statusCode,
  required Map<String, dynamic> body,
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

String _jwtWithExpiry(DateTime expiresAt) {
  final String header = base64Url.encode(
    utf8.encode('{"alg":"none","typ":"JWT"}'),
  );
  final String payload = base64Url.encode(
    utf8.encode(
      jsonEncode(<String, Object>{
        'exp': expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000,
      }),
    ),
  );
  return '$header.$payload.sig';
}
