import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/auth_token_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late ApiClient client;

  setUp(() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.apiBaseUrl,
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    client = ApiClient(dio: dio, tokenReader: const EmptyAuthTokenReader());
  });

  Future<void> expectMapped({
    required int status,
    Object? data,
    required void Function(ApiException error) verify,
  }) async {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: status,
                data: data,
              ),
            ),
          );
        },
      ),
    );

    try {
      await client.get<Object?>(
        '/error-probe',
        parseData: (Object? raw) => raw,
      );
      fail('expected ApiException');
    } on ApiException catch (error) {
      verify(error);
    }
  }

  test('maps validation 400 using the Backend message', () async {
    await expectMapped(
      status: 400,
      data: <String, dynamic>{
        'success': false,
        'message': 'partySize must be at least 1',
        'code': 'VALIDATION_ERROR',
      },
      verify: (ApiException error) {
        expect(error.statusCode, 400);
        expect(error.isBadRequest, isTrue);
        expect(error.isValidation, isTrue);
        expect(error.message, 'partySize must be at least 1');
      },
    );
  });

  test('maps 401/403/404/409/422/429/503 from JSON bodies', () async {
    await expectMapped(
      status: 401,
      data: <String, dynamic>{
        'success': false,
        'message': 'Access token is required.',
      },
      verify: (ApiException error) {
        expect(error.isUnauthorized, isTrue);
        expect(error.message, 'Access token is required.');
      },
    );
    await expectMapped(
      status: 403,
      data: <String, dynamic>{
        'success': false,
        'message': 'Forbidden action',
      },
      verify: (ApiException error) {
        expect(error.isForbidden, isTrue);
        expect(error.message, 'Forbidden action');
      },
    );
    await expectMapped(
      status: 404,
      data: <String, dynamic>{
        'success': false,
        'message': 'Table not found',
      },
      verify: (ApiException error) {
        expect(error.isNotFound, isTrue);
        expect(error.message, 'Table not found');
      },
    );
    await expectMapped(
      status: 409,
      data: <String, dynamic>{
        'success': false,
        'message': 'Table is no longer available.',
        'code': 'TABLE_CONFLICT',
      },
      verify: (ApiException error) {
        expect(error.isConflict, isTrue);
        expect(error.message, 'Table is no longer available.');
        expect(error.code, 'TABLE_CONFLICT');
      },
    );
    await expectMapped(
      status: 422,
      data: <String, dynamic>{
        'success': false,
        'message': 'Unprocessable',
      },
      verify: (ApiException error) {
        expect(error.isValidation, isTrue);
        expect(error.message, 'Unprocessable');
      },
    );
    await expectMapped(
      status: 429,
      data: <String, dynamic>{},
      verify: (ApiException error) {
        expect(error.statusCode, 429);
        expect(error.message, AppStrings.networkTooManyRequestsError);
      },
    );
    await expectMapped(
      status: 503,
      data: <String, dynamic>{},
      verify: (ApiException error) {
        expect(error.statusCode, 503);
        expect(error.message, AppStrings.networkServerError);
      },
    );
  });

  test('maps bare 409 and plain-text bodies without inventing success', () async {
    await expectMapped(
      status: 409,
      data: 'Table already reserved',
      verify: (ApiException error) {
        expect(error.isConflict, isTrue);
        expect(error.message, 'Table already reserved');
      },
    );
  });

  test('maps timeout, connection, and cancellation', () async {
    Future<void> expectType(
      DioExceptionType type,
      void Function(ApiException error) verify,
    ) async {
      dio.interceptors.clear();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
            handler.reject(
              DioException(requestOptions: options, type: type),
            );
          },
        ),
      );
      try {
        await client.get<Object?>(
          '/error-probe',
          parseData: (Object? raw) => raw,
        );
        fail('expected ApiException');
      } on ApiException catch (error) {
        verify(error);
      }
    }

    await expectType(DioExceptionType.receiveTimeout, (ApiException error) {
      expect(error.message, AppStrings.networkTimeoutError);
    });
    await expectType(DioExceptionType.connectionError, (ApiException error) {
      expect(error.message, AppStrings.networkConnectionError);
    });
    await expectType(DioExceptionType.cancel, (ApiException error) {
      expect(error.isCancelled, isTrue);
      expect(error.message, isEmpty);
    });
  });
}
