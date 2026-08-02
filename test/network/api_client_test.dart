import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/api_response.dart';
import 'package:tavla/core/network/auth_token_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiClient DI + AppUrls', () {
    setUp(() {
      Get.reset();
      Get.put<AuthTokenReader>(const EmptyAuthTokenReader(), permanent: true);
      Get.put<ApiClient>(
        ApiClient(tokenReader: Get.find<AuthTokenReader>()),
        permanent: true,
      );
    });

    tearDown(Get.reset);

    test('registers AuthTokenReader and ApiClient', () {
      expect(Get.isRegistered<AuthTokenReader>(), isTrue);
      expect(Get.isRegistered<ApiClient>(), isTrue);
      expect(Get.find<AuthTokenReader>(), isA<EmptyAuthTokenReader>());
      expect(AppUrls.apiBaseUrl.endsWith('/api/v1'), isTrue);
    });
  });

  group('ApiClient request mapping', () {
    test('parses success envelope and maps HTTP/timeout errors', () async {
      final Dio mockDio = Dio(
        BaseOptions(
          baseUrl: AppUrls.apiBaseUrl,
          validateStatus: (int? status) =>
              status != null && status >= 200 && status < 300,
        ),
      );

      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                if (options.path.endsWith('/mock-success')) {
                  handler.resolve(
                    Response<dynamic>(
                      requestOptions: options,
                      statusCode: 200,
                      data: <String, dynamic>{
                        'success': true,
                        'message': 'ok',
                        'data': <String, dynamic>{'status': 'up'},
                        'meta': <String, dynamic>{'page': 1},
                      },
                    ),
                  );
                  return;
                }
                if (options.path.endsWith('/mock-http-error')) {
                  handler.reject(
                    DioException(
                      requestOptions: options,
                      type: DioExceptionType.badResponse,
                      response: Response<dynamic>(
                        requestOptions: options,
                        statusCode: 500,
                        data: <String, dynamic>{
                          'success': false,
                          'message': 'boom',
                          'code': 'INTERNAL_ERROR',
                          'errors': <dynamic>[],
                          'path': '/mock-http-error',
                        },
                      ),
                    ),
                  );
                  return;
                }
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.connectionTimeout,
                  ),
                );
              },
        ),
      );

      final ApiClient mockClient = ApiClient(
        dio: mockDio,
        tokenReader: const EmptyAuthTokenReader(),
      );

      final ApiResponse<Map<String, dynamic>> ok = await mockClient
          .get<Map<String, dynamic>>(
            '/mock-success',
            parseData: (Object? raw) => raw as Map<String, dynamic>,
          );
      expect(ok.success, isTrue);
      expect(ok.data['status'], 'up');
      expect(ok.meta?['page'], 1);

      await expectLater(
        () => mockClient.get<Object?>(
          '/mock-http-error',
          parseData: (Object? raw) => raw,
        ),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'status', 500)
              .having((ApiException e) => e.code, 'code', 'INTERNAL_ERROR')
              .having((ApiException e) => e.message, 'message', 'boom'),
        ),
      );

      await expectLater(
        () => mockClient.get<Object?>(
          '/mock-timeout',
          parseData: (Object? raw) => raw,
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('does not attach Authorization without a token', () async {
      String? authorization;
      final Dio dio = Dio(
        BaseOptions(
          baseUrl: AppUrls.apiBaseUrl,
          validateStatus: (int? status) => true,
        ),
      );
      final ApiClient client = ApiClient(
        dio: dio,
        tokenReader: const EmptyAuthTokenReader(),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                authorization = options.headers['Authorization'] as String?;
                handler.resolve(
                  Response<dynamic>(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{
                      'success': true,
                      'message': 'ok',
                      'data': <String, dynamic>{},
                    },
                  ),
                );
              },
        ),
      );

      await client.get<Map<String, dynamic>>(
        '/auth-header-check',
        parseData: (Object? raw) =>
            (raw as Map<String, dynamic>?) ?? <String, dynamic>{},
      );

      expect(authorization, isNull);
    });

    test(
      'attaches Authorization Bearer when token reader returns a token',
      () async {
        const String probeToken = 'unit-test-access-token';
        String? authorization;
        final Dio dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.apiBaseUrl,
            validateStatus: (int? status) =>
                status != null && status >= 200 && status < 500,
          ),
        );
        final ApiClient client = ApiClient(
          dio: dio,
          tokenReader: const _StaticAuthTokenReader(probeToken),
        );

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest:
                (RequestOptions options, RequestInterceptorHandler handler) {
                  authorization = options.headers['Authorization']?.toString();
                  handler.resolve(
                    Response<dynamic>(
                      requestOptions: options,
                      statusCode: 200,
                      data: <String, dynamic>{
                        'success': true,
                        'message': 'ok',
                        'data': <String, dynamic>{'ok': true},
                      },
                    ),
                  );
                },
          ),
        );

        await client.get<Map<String, dynamic>>(
          '/auth-header-check',
          parseData: (Object? raw) =>
              Map<String, dynamic>.from(raw as Map<String, dynamic>),
        );

        expect(authorization, 'Bearer $probeToken');
      },
    );

    test(
      'skipAuth cuisine-categories is not blocked by hanging auth token read',
      () async {
        final Completer<String?> tokenHang = Completer<String?>();
        var cuisineHits = 0;

        final Dio dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.apiBaseUrl,
            validateStatus: (int? status) =>
                status != null && status >= 200 && status < 300,
          ),
        );
        final ApiClient client = ApiClient(
          dio: dio,
          tokenReader: _HangingAuthTokenReader(tokenHang),
        );

        dio.httpClientAdapter = _CallbackHttpAdapter((RequestOptions options) {
          if (options.path.contains('cuisine-categories')) {
            cuisineHits += 1;
            return ResponseBody.fromString(
              '{"success":true,"message":"ok","data":{"items":[]},"meta":{}}',
              200,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>[Headers.jsonContentType],
              },
            );
          }
          // Protected path should not need to complete for this test.
          return ResponseBody.fromString(
            '{"success":true,"message":"ok","data":{},"meta":{}}',
            200,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        });

        // Start a protected call that holds the auth interceptor on Keychain.
        final Future<ApiResponse<Object?>> protected = client.get<Object?>(
          '/users/me',
          parseData: (Object? raw) => raw,
        );

        await Future<void>.delayed(const Duration(milliseconds: 20));

        final ApiResponse<List<dynamic>> cuisine = await client
            .get<List<dynamic>>(
              '/cuisine-categories',
              options: ApiClient.skipAuthOptions(),
              parseData: (Object? raw) {
                if (raw is Map && raw['items'] is List) {
                  return List<dynamic>.from(raw['items'] as List);
                }
                return const <dynamic>[];
              },
            )
            .timeout(const Duration(seconds: 2));

        expect(cuisine.success, isTrue);
        expect(cuisineHits, 1);

        // Release the hung protected call (null token → proceeds without Bearer).
        tokenHang.complete(null);
        await protected;
      },
    );
  });
}

class _StaticAuthTokenReader implements AuthTokenReader {
  const _StaticAuthTokenReader(this._token);

  final String _token;

  @override
  Future<String?> readAccessToken() async => _token;
}

class _HangingAuthTokenReader implements AuthTokenReader {
  _HangingAuthTokenReader(this._gate);

  final Completer<String?> _gate;

  @override
  Future<String?> readAccessToken() => _gate.future;
}

class _CallbackHttpAdapter implements HttpClientAdapter {
  _CallbackHttpAdapter(this._onFetch);

  final ResponseBody Function(RequestOptions options) _onFetch;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _onFetch(options);
  }
}
