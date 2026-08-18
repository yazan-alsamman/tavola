import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/active_sessions_controller.dart';
import 'package:tavla/features/auth/model/auth_device_session_model.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingAdapter adapter;
  late ActiveSessionsController controller;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    adapter = _RecordingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = adapter;
    Get.put(AuthRepository(dio: dio), permanent: true);
    Get.put<AuthTokenReader>(
      _MemoryTokens(accessToken: 'access-token', refreshToken: 'refresh'),
      permanent: true,
    );
  });

  tearDown(Get.reset);

  test('loadSessions populates sessions from repository', () async {
    adapter.statusCode = 200;
    adapter.body = <String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'sessions': <Map<String, dynamic>>[
          <String, dynamic>{
            'sessionId': 'current-id',
            'isCurrentSession': true,
            'deviceName': 'iPhone',
          },
          <String, dynamic>{
            'sessionId': 'other-id',
            'isCurrentSession': false,
            'deviceName': 'iPad',
          },
        ],
      },
    };

    controller = ActiveSessionsController();
    Get.put(controller);
    await Future<void>.delayed(Duration.zero);
    await controller.loadSessions();

    expect(adapter.lastMethod, 'GET');
    expect(adapter.lastPath, AppUrls.authSessionsPath);
    expect(adapter.lastAuthorization, 'Bearer access-token');
    expect(controller.sessions, hasLength(2));
    expect(controller.sessions.first.isCurrentSession, isTrue);
    expect(controller.errorMessage.value, isNull);
    expect(controller.isLoading.value, isFalse);
  });

  test('loadSessions sets error when request fails', () async {
    adapter.throwAsBadResponse = true;
    adapter.statusCode = 500;
    adapter.body = <String, dynamic>{
      'success': false,
      'message': 'Server error',
    };

    controller = ActiveSessionsController();
    Get.put(controller);
    await controller.loadSessions();

    expect(controller.sessions, isEmpty);
    expect(controller.errorMessage.value, isNotNull);
    expect(controller.isLoading.value, isFalse);
  });

  test('deviceLabel falls back to unknownDevice', () {
    controller = ActiveSessionsController();
    Get.put(controller);

    final AuthDeviceSessionModel session = const AuthDeviceSessionModel(
      sessionId: 'id-1',
    );
    expect(controller.deviceLabel(session), AppStrings.unknownDevice);
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
