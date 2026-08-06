import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/model/session_mode.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/session_mode_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
  });

  tearDown(Get.reset);

  test(
    'logOut calls POST /auth/logout with Bearer then clears local session',
    () async {
      final _RecordingAdapter adapter = _RecordingAdapter();
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = adapter;
      final _MemoryTokens tokens = _MemoryTokens(
        accessToken: 'live-access',
        refreshToken: 'live-refresh',
      );
      Get.put<AuthTokenReader>(tokens);
      Get.put(AuthRepository(dio: dio));
      final AuthSessionController session = AuthSessionController();
      Get.put(session);
      session.hasAuthenticatedSession.value = true;
      await SessionModePreferences.write(SessionMode.authenticated);

      // Navigation may no-op without GetMaterialApp pages — persistence is the
      // contract under test.
      try {
        await session.logOut();
      } catch (_) {}

      expect(adapter.lastMethod, 'POST');
      expect(adapter.lastPath, AppUrls.authLogoutPath);
      expect(adapter.lastAuthorization, 'Bearer live-access');
      expect(tokens.accessToken, isNull);
      expect(tokens.refreshToken, isNull);
      expect(session.hasAuthenticatedSession.value, isFalse);
      expect(session.isGuest.value, isFalse);
      expect(await SessionModePreferences.read(), SessionMode.none);
    },
  );

  test('logOut still clears locally when remote logout fails', () async {
    final _RecordingAdapter adapter = _RecordingAdapter()
      ..statusCode = 500
      ..body = <String, dynamic>{
        'success': false,
        'message': 'server down',
      };
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = adapter;
    final _MemoryTokens tokens = _MemoryTokens(
      accessToken: 'live-access',
      refreshToken: 'live-refresh',
    );
    Get.put<AuthTokenReader>(tokens);
    Get.put(AuthRepository(dio: dio));
    final AuthSessionController session = AuthSessionController();
    Get.put(session);
    session.hasAuthenticatedSession.value = true;

    try {
      await session.logOut();
    } catch (_) {}

    expect(adapter.lastPath, AppUrls.authLogoutPath);
    expect(tokens.accessToken, isNull);
    expect(session.hasAuthenticatedSession.value, isFalse);
    expect(await SessionModePreferences.read(), SessionMode.none);
  });

  test('logOut skips remote call when guest has no access token', () async {
    final _RecordingAdapter adapter = _RecordingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = adapter;
    final _MemoryTokens tokens = _MemoryTokens();
    Get.put<AuthTokenReader>(tokens);
    Get.put(AuthRepository(dio: dio));
    final AuthSessionController session = AuthSessionController();
    Get.put(session);
    session.isGuest.value = true;

    try {
      await session.logOut();
    } catch (_) {}

    expect(adapter.lastPath, isNull);
    expect(session.isGuest.value, isFalse);
    expect(await SessionModePreferences.read(), SessionMode.none);
  });
}

class _MemoryTokens implements AuthTokenSession {
  _MemoryTokens({this.accessToken, this.refreshToken});

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
