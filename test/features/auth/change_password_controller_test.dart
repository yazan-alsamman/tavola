import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/change_password_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingAdapter adapter;
  late _MemoryTokens tokens;
  late ChangePasswordController controller;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    adapter = _RecordingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = adapter;
    Get.put(AuthRepository(dio: dio), permanent: true);
    tokens = _MemoryTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
    Get.put<AuthTokenReader>(tokens, permanent: true);
    controller = ChangePasswordController();
    Get.put(controller);
  });

  tearDown(Get.reset);

  test('canSubmit requires valid current, new, and confirm passwords', () {
    expect(controller.canSubmit.value, isFalse);

    controller.currentPasswordController.text = 'OldPass123!ab';
    controller.passwordController.text = 'BrandNewPass1!';
    controller.confirmPasswordController.text = 'BrandNewPass1!';

    expect(controller.canSubmit.value, isTrue);
  });

  test('submit sets mismatch when new and confirm differ', () async {
    controller.currentPasswordController.text = 'OldPass123!ab';
    controller.passwordController.text = 'BrandNewPass1!';
    controller.confirmPasswordController.text = 'DifferentPass1!';

    await controller.submit();

    expect(controller.showPasswordMismatch.value, isTrue);
    expect(adapter.lastPath, isNull);
  });

  test('submit applies rotated tokens on success', () async {
    adapter.statusCode = 200;
    adapter.body = <String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'accessToken': 'new-access',
        'refreshToken': 'new-refresh',
      },
    };

    controller.currentPasswordController.text = 'OldPass123!ab';
    controller.passwordController.text = 'BrandNewPass1!';
    controller.confirmPasswordController.text = 'BrandNewPass1!';

    await controller.submit();

    expect(adapter.lastMethod, 'POST');
    expect(adapter.lastPath, AppUrls.authChangePasswordPath);
    expect(adapter.lastAuthorization, 'Bearer access-token');
    expect(adapter.lastBody?['currentPassword'], 'OldPass123!ab');
    expect(adapter.lastBody?['newPassword'], 'BrandNewPass1!');
    expect(tokens.accessToken, 'new-access');
    expect(tokens.refreshToken, 'new-refresh');
    expect(controller.errorMessage.value, isNull);
    expect(controller.isLoading.value, isFalse);
  });

  test('submit surfaces ApiException message', () async {
    adapter.statusCode = 400;
    adapter.body = <String, dynamic>{
      'success': false,
      'message': 'Current password is incorrect',
    };
    adapter.throwAsBadResponse = true;

    controller.currentPasswordController.text = 'OldPass123!ab';
    controller.passwordController.text = 'BrandNewPass1!';
    controller.confirmPasswordController.text = 'BrandNewPass1!';

    await controller.submit();

    expect(controller.errorMessage.value, isNotNull);
    expect(controller.isLoading.value, isFalse);
  });

  test('submit fails when access token missing', () async {
    tokens.accessToken = null;
    controller.currentPasswordController.text = 'OldPass123!ab';
    controller.passwordController.text = 'BrandNewPass1!';
    controller.confirmPasswordController.text = 'BrandNewPass1!';

    await controller.submit();

    expect(controller.errorMessage.value, AppStrings.authRefreshTokenMissing);
    expect(adapter.lastPath, isNull);
  });
}

class _MemoryTokens implements AuthTokenSession {
  _MemoryTokens({
    required String this.accessToken,
    required String this.refreshToken,
  });

  String? accessToken;
  String? refreshToken;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
    bool persistToDisk = true,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearSessionTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

class _RecordingAdapter implements HttpClientAdapter {
  int statusCode = 200;
  Map<String, dynamic>? body = <String, dynamic>{'success': true};
  bool throwAsBadResponse = false;
  String? lastMethod;
  String? lastPath;
  String? lastAuthorization;
  Map<String, dynamic>? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastMethod = options.method;
    lastPath = options.path;
    lastAuthorization =
        options.headers[AppStrings.authorizationHeaderKey]?.toString();
    if (options.data is Map) {
      lastBody = Map<String, dynamic>.from(options.data as Map);
    } else {
      lastBody = null;
    }

    if (throwAsBadResponse) {
      throw DioException(
        requestOptions: options,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: statusCode,
          data: body,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    if (body == null) {
      return ResponseBody.fromString('', statusCode);
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
