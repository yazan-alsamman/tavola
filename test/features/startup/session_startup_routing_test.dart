import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/controller/sign_up_controller.dart';
import 'package:tavla/features/auth/model/customer_auth_response_model.dart';
import 'package:tavla/features/auth/model/session_mode.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/session_mode_preferences.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/splash/controller/splash_controller.dart';
import 'package:tavla/features/splash/splash_assets.dart';
import 'package:tavla/features/splash/view/splash_screen.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

/// Startup routing for persisted [SessionMode] (Hot Restart / reboot / Logout).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets('first launch (no session mode) shows Welcome', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.onboardingCompletedKey: true,
      AppStrings.favoriteCuisinesCompletedKey: true,
    });
    Get.testMode = true;
    Get.reset();
    Get.locale = const Locale('en');

    await tester.runAsync(SplashAssets.precacheLavender);
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(AuthRepository());
    Get.put(AuthSessionController());
    Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
    Get.put(LocaleController()).syncFromLocale(const Locale('en'));
    AppDependency.putIfAbsent(SplashController.new);

    await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(AppDimensions.splashReadyDuration);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(AppDimensions.splashNavigationPrepGrace);
    await tester.pump();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(Get.currentRoute, AppRoutes.welcome);
  });

  test('first launch resolver selects Welcome', () async {
    await _withSessionGraph(
      preferences: <String, Object>{
        AppStrings.onboardingCompletedKey: true,
        AppStrings.favoriteCuisinesCompletedKey: true,
      },
      tokens: const EmptyAuthTokenReader(),
      run: () async {
        expect(
          await SplashController.resolveDestination(),
          AppRoutes.welcome,
        );
        expect(Get.find<AuthSessionController>().isGuest.value, isFalse);
      },
    );
  });

  test('persisted guest survives Hot Restart / full restart → Home', () async {
    await _withSessionGraph(
      preferences: <String, Object>{
        AppStrings.onboardingCompletedKey: true,
        AppStrings.favoriteCuisinesCompletedKey: true,
        AppStrings.sessionModeKey: AppStrings.sessionModeGuestValue,
      },
      tokens: const EmptyAuthTokenReader(),
      run: () async {
        expect(await SplashController.resolveDestination(), AppRoutes.home);
        final AuthSessionController session = Get.find<AuthSessionController>();
        expect(session.isAnonymousGuest, isTrue);
        expect(session.hasAuthenticatedSession.value, isFalse);
        expect(await SessionModePreferences.read(), SessionMode.guest);
      },
    );
  });

  test('persisted guest survives device reboot simulation → Home', () async {
    // Reboot: SharedPreferences survives; Keychain has no guest tokens.
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.onboardingCompletedKey: true,
      AppStrings.favoriteCuisinesCompletedKey: true,
    });
    await SessionModePreferences.write(SessionMode.guest);

    await _withSessionGraph(
      preferences: null,
      tokens: const EmptyAuthTokenReader(),
      reuseExistingPreferences: true,
      run: () async {
        expect(await SplashController.resolveDestination(), AppRoutes.home);
        expect(Get.find<AuthSessionController>().isAnonymousGuest, isTrue);
      },
    );
  });

  test('authenticated session with tokens → Home', () async {
    await _withSessionGraph(
      preferences: <String, Object>{
        AppStrings.onboardingCompletedKey: true,
        AppStrings.favoriteCuisinesCompletedKey: true,
        AppStrings.sessionModeKey: AppStrings.sessionModeAuthenticatedValue,
      },
      tokens: _MemoryTokens(accessToken: 'access', refreshToken: 'refresh'),
      run: () async {
        expect(await SplashController.resolveDestination(), AppRoutes.home);
        final AuthSessionController session = Get.find<AuthSessionController>();
        expect(session.hasAuthenticatedSession.value, isTrue);
        expect(session.isGuest.value, isFalse);
      },
    );
  });

  test(
    'Login survives Hot Restart: SessionMode.authenticated + disk tokens → Home',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppStrings.onboardingCompletedKey: true,
        AppStrings.favoriteCuisinesCompletedKey: true,
      });
      Get.testMode = true;
      Get.reset();
      final _MemoryTokens tokens = _MemoryTokens();
      Get.put<AuthTokenReader>(tokens);
      Get.put(ApiClient(tokenReader: tokens));
      final AuthSessionController session = AuthSessionController();
      Get.put(session);

      await session.completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'hot-access',
          refreshToken: 'hot-refresh',
          sessionId: 's',
          userId: 'u',
        ),
      );

      await session.flushPostLoginBootstrap();

      expect(await SessionModePreferences.read(), SessionMode.authenticated);
      expect(tokens.accessToken, 'hot-access');
      expect(tokens.refreshToken, 'hot-refresh');

      // Hot Restart: new AuthSessionController, same prefs + token store disk.
      Get.reset();
      Get.put<AuthTokenReader>(
        _MemoryTokens(accessToken: 'hot-access', refreshToken: 'hot-refresh'),
      );
      Get.put(AuthRepository());
      Get.put(AuthSessionController());
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));

      expect(await SplashController.resolveDestination(), AppRoutes.home);
      final AuthSessionController restored = Get.find<AuthSessionController>();
      expect(restored.hasAuthenticatedSession.value, isTrue);
      expect(restored.isGuest.value, isFalse);
      expect(await SessionModePreferences.read(), SessionMode.authenticated);
    },
  );

  test(
    'Login survives full restart / reboot: mode authenticated even if tokens slow → Home',
    () async {
      // Simulates reboot where SessionMode survived and Keychain is empty for
      // one tick — must NOT clear mode or open Welcome.
      await _withSessionGraph(
        preferences: <String, Object>{
          AppStrings.onboardingCompletedKey: true,
          AppStrings.favoriteCuisinesCompletedKey: true,
          AppStrings.sessionModeKey: AppStrings.sessionModeAuthenticatedValue,
        },
        tokens: const EmptyAuthTokenReader(),
        run: () async {
          expect(await SplashController.resolveDestination(), AppRoutes.home);
          final AuthSessionController session =
              Get.find<AuthSessionController>();
          expect(session.hasAuthenticatedSession.value, isTrue);
          expect(session.isGuest.value, isFalse);
          expect(
            await SessionModePreferences.read(),
            SessionMode.authenticated,
          );
        },
      );
    },
  );

  test(
    'completeSignIn schedules SessionMode.authenticated without blocking',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      Get.testMode = true;
      Get.reset();
      final _MemoryTokens tokens = _MemoryTokens();
      Get.put<AuthTokenReader>(tokens);
      Get.put(ApiClient(tokenReader: tokens));
      final AuthSessionController session = AuthSessionController();

      await session.completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'a',
          refreshToken: 'r',
          sessionId: 's',
          userId: 'u',
        ),
      );

      // Memory session is authoritative immediately; disk mode waits for bootstrap.
      expect(session.hasAuthenticatedSession.value, isTrue);
      expect(tokens.updateCalled, isTrue);

      await session.flushPostLoginBootstrap();

      expect(await SessionModePreferences.read(), SessionMode.authenticated);
    },
  );

  test('enterAsGuest persists guest and never writes tokens', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    final _MemoryTokens tokens = _MemoryTokens();
    Get.put<AuthTokenReader>(tokens);
    final AuthSessionController session = AuthSessionController();

    await session.enterAsGuest();
    await Future<void>.delayed(Duration.zero);

    expect(session.isGuest.value, isTrue);
    expect(session.hasAuthenticatedSession.value, isFalse);
    expect(tokens.accessToken, isNull);
    expect(tokens.refreshToken, isNull);
    expect(tokens.updateCalled, isFalse);
    expect(await SessionModePreferences.read(), SessionMode.guest);
  });

  test('completeSignIn persists authenticated mode', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.sessionModeKey: AppStrings.sessionModeGuestValue,
    });
    Get.testMode = true;
    Get.reset();
    final _MemoryTokens tokens = _MemoryTokens();
    Get.put<AuthTokenReader>(tokens);
    Get.put(ApiClient(tokenReader: tokens));
    final AuthSessionController session = AuthSessionController();
    session.isGuest.value = true;

    await session.completeSignIn(
      const CustomerAuthResponseModel(
        accessToken: 'a',
        refreshToken: 'r',
        sessionId: 's',
        userId: 'u',
        username: 'user',
        phone: '1',
      ),
    );

    await session.flushPostLoginBootstrap();

    expect(session.hasAuthenticatedSession.value, isTrue);
    expect(session.isGuest.value, isFalse);
    expect(tokens.accessToken, 'a');
    expect(tokens.refreshToken, 'r');
    expect(await SessionModePreferences.read(), SessionMode.authenticated);
  });

  testWidgets('logOut clears session and next resolve is Welcome', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.onboardingCompletedKey: true,
      AppStrings.favoriteCuisinesCompletedKey: true,
      AppStrings.sessionModeKey: AppStrings.sessionModeAuthenticatedValue,
    });
    Get.testMode = true;
    Get.reset();
    Get.locale = const Locale('en');

    final _MemoryTokens tokens = _MemoryTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    Get.put<AuthTokenReader>(tokens, permanent: true);
    Get.put(AuthRepository(), permanent: true);
    Get.put(ApiClient(tokenReader: tokens), permanent: true);
    Get.put(AuthSessionController(), permanent: true);
    final AuthSessionController session = Get.find<AuthSessionController>();
    session.hasAuthenticatedSession.value = true;

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
            name: AppRoutes.logoutTransition,
            page: () => const Scaffold(body: Text('logout-bridge-stub')),
          ),
          GetPage<void>(
            name: AppRoutes.welcome,
            page: () => const Scaffold(body: Text('welcome-stub')),
          ),
        ],
        home: const Scaffold(body: Text('home')),
      ),
    );
    await tester.pump();

    // logOut awaits remote revoke with authLogoutTimeout; under FakeAsync the
    // Dio timer only fires when the test clock advances.
    final Future<void> logout = session.logOut();
    await tester.pump(AppDimensions.authLogoutTimeout);
    await tester.pump();
    await logout;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(session.hasAuthenticatedSession.value, isFalse);
    expect(session.isGuest.value, isFalse);
    expect(tokens.accessToken, isNull);
    expect(tokens.refreshToken, isNull);
    expect(await SessionModePreferences.read(), SessionMode.none);
    expect(find.text('logout-bridge-stub'), findsOneWidget);
    expect(Get.isRegistered<LoginController>(), isTrue);
    expect(Get.isRegistered<SignUpController>(), isTrue);

    // Next cold start after Logout → Welcome (not Home).
    HomeEntryWarmup.resetForTest();
    Get.reset();
    await _withSessionGraph(
      preferences: <String, Object>{
        AppStrings.onboardingCompletedKey: true,
        AppStrings.favoriteCuisinesCompletedKey: true,
      },
      tokens: const EmptyAuthTokenReader(),
      run: () async {
        expect(await SplashController.resolveDestination(), AppRoutes.welcome);
      },
    );
  });
}

Future<void> _withSessionGraph({
  required Map<String, Object>? preferences,
  required AuthTokenReader tokens,
  required Future<void> Function() run,
  bool reuseExistingPreferences = false,
}) async {
  if (!reuseExistingPreferences) {
    SharedPreferences.setMockInitialValues(preferences ?? <String, Object>{});
  }
  Get.testMode = true;
  Get.reset();
  Get.put<AuthTokenReader>(tokens);
  Get.put(AuthRepository());
  Get.put(AuthSessionController());
  Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
  await run();
}

class _MemoryTokens implements AuthTokenSession {
  _MemoryTokens({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;
  bool updateCalled = false;

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
    updateCalled = true;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearSessionTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}
