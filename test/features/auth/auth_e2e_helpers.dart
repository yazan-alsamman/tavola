import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/controller/otp_controller.dart';
import 'package:tavla/features/auth/controller/sign_up_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/auth/view/otp_screen.dart';
import 'package:tavla/features/auth/view/sign_up_screen.dart';

/// Shared harness for auth end-to-end widget tests.
///
/// Real screens, routes, bindings, and controllers — only the HTTP layer is
/// faked. GetX keeps app-wide static state (root controller, navigator key),
/// so each test file must run a single continuous journey inside one
/// [GetMaterialApp] session.
class AuthE2eHarness {
  AuthE2eHarness() {
    Get.testMode = true;
    Get.reset();

    tokenStore = MemoryAuthTokenStore();
    adapter = RoutedAdapter();

    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.httpClientAdapter = adapter;

    Get.put<AuthTokenReader>(tokenStore, permanent: true);
    Get.put<AuthRepository>(AuthRepository(dio: dio), permanent: true);
    Get.put<AuthSessionController>(AuthSessionController(), permanent: true);
  }

  late final MemoryAuthTokenStore tokenStore;
  late final RoutedAdapter adapter;

  Widget buildApp({required String initialRoute, Locale? locale}) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: locale ?? const Locale('en'),
      fallbackLocale: const Locale('en'),
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
          binding: BindingsBuilder(() {
            AppDependency.putFresh(LoginController.new);
          }),
        ),
        GetPage(
          name: AppRoutes.signUp,
          page: () => const SignUpScreen(),
          binding: BindingsBuilder(() {
            AppDependency.putFresh(SignUpController.new);
          }),
        ),
        GetPage(
          name: AppRoutes.otp,
          page: () => const OtpScreen(),
          binding: BindingsBuilder(() {
            AppDependency.putFresh(OtpController.new);
          }),
        ),
        // Home stub: post-login shell destination without home-feature deps.
        GetPage(
          name: AppRoutes.home,
          page: () => const Scaffold(key: Key('home-stub')),
        ),
      ],
    );
  }
}

/// Bounded pumps instead of pumpAndSettle: the OTP screen owns a periodic
/// resend timer that never settles.
Future<void> settleAuth(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class MemoryAuthTokenStore implements AuthTokenSession {
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
    bool persistToDisk = true,
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

/// Serves canned responses per path; unknown paths return a 404 envelope.
class RoutedAdapter implements HttpClientAdapter {
  final Map<String, ResponseBody Function()> responses =
      <String, ResponseBody Function()>{};
  int requestCount = 0;

  /// When set, [fetch] waits this long before serving (or hanging).
  Duration? responseDelay;

  /// When true, [fetch] never completes (simulates unreachable API host).
  bool hangForever = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    if (hangForever) {
      final Completer<ResponseBody> completer = Completer<ResponseBody>();
      if (cancelFuture != null) {
        unawaited(
          cancelFuture.then((_) {
            if (!completer.isCompleted) {
              completer.completeError(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.cancel,
                ),
              );
            }
          }),
        );
      }
      return completer.future;
    }
    final Duration? delay = responseDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    final ResponseBody Function()? handler = responses[options.path];
    if (handler != null) {
      return handler();
    }
    return jsonResponseBody(
      statusCode: 404,
      body: <String, dynamic>{'success': false, 'message': 'not found'},
    );
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponseBody({
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
