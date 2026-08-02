import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/features/auth/model/customer_login_request_model.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';

/// AuthRepository login Dio → ApiException notification mapping.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String validAePhone = '501234567';
  const String password = 'secret-password';

  late AuthRepository repository;
  late _StatusAdapter adapter;

  setUp(() {
    adapter = _StatusAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = adapter;
    repository = AuthRepository(dio: dio);
  });

  Future<Object?> capture() async {
    try {
      await repository.loginCustomer(
        const CustomerLoginRequestModel(
          countryCode: 'AE',
          phoneNumber: validAePhone,
          password: password,
          deviceName: 'test',
          deviceType: 'ios',
        ),
      );
      return null;
    } catch (error) {
      return error;
    }
  }

  test('preserves server message on 401 JSON body', () async {
    adapter.statusCode = 401;
    adapter.body = <String, dynamic>{
      'success': false,
      'message': 'Invalid phone or password',
    };
    final Object? error = await capture();
    expect(error, isA<ApiException>());
    expect((error! as ApiException).message, 'Invalid phone or password');
    expect((error as ApiException).statusCode, 401);
  });

  test('bare 401 is credentials rejected — not session expired', () async {
    adapter.statusCode = 401;
    adapter.body = null;
    adapter.rawBody = 'Unauthorized';
    final Object? error = await capture();
    expect(error, isA<ApiException>());
    final ApiException api = error! as ApiException;
    expect(api.message, AppStrings.authCredentialsRejected);
    expect(api.message, isNot(AppStrings.networkUnauthorizedError));
    expect(api.statusCode, 401);
  });

  test('preserves server message via error key', () async {
    adapter.statusCode = 401;
    adapter.body = <String, dynamic>{
      'success': false,
      'error': 'Account not found',
    };
    final Object? error = await capture();
    expect((error! as ApiException).message, 'Account not found');
  });

  test('HTTP 400 with message is preserved', () async {
    adapter.statusCode = 400;
    adapter.body = <String, dynamic>{
      'success': false,
      'message': 'Bad request payload',
    };
    final Object? error = await capture();
    expect((error! as ApiException).message, 'Bad request payload');
    expect((error as ApiException).statusCode, 400);
  });

  test('bare 403 uses forbidden fallback', () async {
    adapter.statusCode = 403;
    adapter.body = null;
    adapter.rawBody = 'Forbidden';
    final Object? error = await capture();
    expect((error! as ApiException).message, AppStrings.networkForbiddenError);
    expect((error as ApiException).statusCode, 403);
  });

  test('bare 404 uses not-found fallback', () async {
    adapter.statusCode = 404;
    adapter.body = null;
    adapter.rawBody = 'missing';
    final Object? error = await capture();
    expect((error! as ApiException).message, AppStrings.networkNotFoundError);
  });

  test('HTTP 422 validation details preferred', () async {
    adapter.statusCode = 422;
    adapter.body = <String, dynamic>{
      'success': false,
      'message': 'Validation failed',
      'code': 'VALIDATION_ERROR',
      'errors': <dynamic>[
        <String, dynamic>{'field': 'password', 'message': 'must be longer'},
      ],
    };
    final Object? error = await capture();
    expect((error! as ApiException).message, 'password: must be longer');
    expect((error as ApiException).isValidation, isTrue);
  });

  test('bare 429 uses rate-limit fallback', () async {
    adapter.statusCode = 429;
    adapter.body = null;
    adapter.rawBody = 'slow down';
    final Object? error = await capture();
    expect(
      (error! as ApiException).message,
      AppStrings.networkTooManyRequestsError,
    );
    expect((error as ApiException).statusCode, 429);
  });

  test('bare 500 uses server fallback', () async {
    adapter.statusCode = 500;
    adapter.body = null;
    adapter.rawBody = 'boom';
    final Object? error = await capture();
    expect((error! as ApiException).message, AppStrings.networkServerError);
    expect((error as ApiException).statusCode, 500);
  });

  test('malformed JSON body maps safely', () async {
    adapter.statusCode = 200;
    adapter.body = null;
    adapter.rawBody = '{not-json';
    adapter.forceInvalidJson = true;
    final Object? error = await capture();
    expect(error, isA<ApiException>());
    expect((error! as ApiException).message, isNotEmpty);
  });

  test('offline connection error maps to connection message', () async {
    adapter.throwConnectionError = true;
    final Object? error = await capture();
    expect(error, isA<ApiException>());
    expect((error! as ApiException).message, AppStrings.networkConnectionError);
  });
}

class _StatusAdapter implements HttpClientAdapter {
  int statusCode = 401;
  Map<String, dynamic>? body = <String, dynamic>{};
  String rawBody = '';
  bool forceInvalidJson = false;
  bool throwConnectionError = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (throwConnectionError) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'SocketException',
      );
    }
    if (forceInvalidJson) {
      return ResponseBody.fromString(
        rawBody,
        statusCode,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );
    }
    if (body == null) {
      return ResponseBody.fromString(
        rawBody,
        statusCode,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['text/plain'],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
