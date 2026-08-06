import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/model/session_mode.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/session_mode_preferences.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });


  testWidgets(
    'requireSignInForProtectedAction opens Login when token missing',
    (tester) async {
      Get.testMode = true;
      Get.put<AuthTokenReader>(const EmptyAuthTokenReader(), permanent: true);
      Get.put(
        ApiClient(tokenReader: Get.find<AuthTokenReader>()),
        permanent: true,
      );
      Get.put(AuthSessionController(), permanent: true);
      Get.find<AuthSessionController>().hasAuthenticatedSession.value = true;

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          getPages: <GetPage<dynamic>>[
            GetPage<void>(
              name: '/home-stub',
              page: () => const Scaffold(body: Text('home')),
            ),
            GetPage<void>(
              name: AppRoutes.login,
              page: () => const Scaffold(body: Text('login-stub')),
            ),
          ],
          home: const Scaffold(body: Text('home')),
        ),
      );
      await tester.pump();

      final bool allowed = await Get.find<AuthSessionController>()
          .requireSignInForProtectedAction();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(allowed, isFalse);
      expect(
        Get.find<AuthSessionController>().hasAuthenticatedSession.value,
        isFalse,
      );
      expect(find.text('login-stub'), findsOneWidget);
    },
  );

  test('requireSignInForProtectedAction allows when token present', () async {
    Get.testMode = true;
    final _MemoryTokens tokens = _MemoryTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    Get.put<AuthTokenReader>(tokens, permanent: true);
    Get.put(AuthSessionController(), permanent: true);

    final bool allowed = await Get.find<AuthSessionController>()
        .requireSignInForProtectedAction();
    expect(allowed, isTrue);
    expect(
      Get.find<AuthSessionController>().hasAuthenticatedSession.value,
      isTrue,
    );
  });

  test('logOut clears session flags and SessionMode (bridge covered elsewhere)',
      () async {
    Get.testMode = true;
    Get.reset();
    final _MemoryTokens tokens = _MemoryTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = _OkLogoutAdapter();
    Get.put<AuthTokenReader>(tokens);
    Get.put(AuthRepository(dio: dio));
    final AuthSessionController session = AuthSessionController();
    Get.put(session);
    session.hasAuthenticatedSession.value = true;
    session.isGuest.value = false;

    try {
      await session.logOut();
    } catch (_) {
      // Navigation shell optional without GetMaterialApp.
    }

    expect(session.hasAuthenticatedSession.value, isFalse);
    expect(session.isGuest.value, isFalse);
    expect(tokens.accessToken, isNull);
    expect(tokens.refreshToken, isNull);
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

class _OkLogoutAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'success': true}),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
