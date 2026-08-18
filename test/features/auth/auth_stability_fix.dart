import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/navigation/app_navigation.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/api_response.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/network/secure_auth_token_store.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/controller/complete_registration_controller.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/model/customer_auth_otp_route_args.dart';
import 'package:tavla/features/auth/model/customer_auth_response_model.dart';
import 'package:tavla/features/auth/model/customer_login_request_model.dart';
import 'package:tavla/features/auth/model/customer_registration_request_models.dart';
import 'package:tavla/features/auth/model/customer_registration_response_model.dart';
import 'package:tavla/features/auth/model/session_mode.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/session_mode_preferences.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/home/home_progressive_init.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/notifications/controller/notifications_badge_controller.dart';
import 'package:tavla/features/notifications/repository/notifications_repository.dart';
import 'package:tavla/features/taxonomy/model/cuisine_category_model.dart';
import 'package:tavla/features/taxonomy/model/occasion_category_model.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

/// AUTH STABILITY proofs for Guest→Login catch-up, Keychain race, Sign Up
/// recovery, navigation coalesce, and session ownership.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    HomeEntryWarmup.resetForTest();
  });

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets(
    'TEST1 Guest→Login runs authenticated Home catch-up without catalog reload',
    (tester) async {
      Get.testMode = true;
      final _RecordingUsers users = _RecordingUsers();
      await _registerGuestHomeStack(users: users);

      final HomeController home = AppDependency.ensureHomeController();
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
      await _pumpUntil(
        tester,
        () => home.progressiveStage.value >= HomeProgressiveInit.stageComplete,
      );

      expect(home.didSchedulePostFrameLoads, isTrue);
      expect(users.profileLoadCount, 0);
      expect(Get.isRegistered<FavoritesRepository>(), isFalse);

      final int cuisineLoadsBefore = _FakeTaxonomyRepository.cuisineLoadCount;
      // Pre-register a no-network badge so catch-up stage 7 cannot leave Dio timers.
      Get.put<NotificationsRepository>(
        NotificationsRepository(Get.find<ApiClient>()),
        permanent: true,
      );
      Get.put<NotificationsBadgeController>(
        _NoopNotificationsBadge(Get.find<NotificationsRepository>()),
        permanent: true,
      );

      await Get.find<AuthSessionController>().completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          sessionId: 'session-id',
          userId: 'user-id',
          username: 'Yazan',
          phone: '+971501234567',
        ),
      );
      await Get.find<AuthSessionController>().flushPostLoginBootstrap();

      // Catch-up starts only after post-login bootstrap (two Home frames).
      await _pumpUntil(tester, () => home.didStartAuthenticatedBootstrap);
      await _pumpUntil(
        tester,
        () =>
            users.profileLoadCount >= 1 &&
            Get.isRegistered<FavoritesRepository>(),
      );

      expect(users.profileLoadCount, greaterThanOrEqualTo(1));
      expect(
        _FakeTaxonomyRepository.cuisineLoadCount,
        cuisineLoadsBefore,
        reason: 'Guest→Auth must not re-fetch public cuisine catalog',
      );

      home.cancelProgressiveInit();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    },
  );

  test('TEST2/4 completeSignIn does not hang on pending Keychain', () async {
    Get.testMode = true;
    // Starts a hung delete (Guest clear) before Login — must not block sign-in.
    final _HangingVault vault = _HangingVault();
    final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);
    Get.put<AuthTokenReader>(store, permanent: true);
    Get.put(ApiClient(tokenReader: store), permanent: true);
    Get.put(
      UsersRepository(Get.find<ApiClient>(), vault: _MemoryVault()),
      permanent: true,
    );
    Get.put(AuthSessionController(), permanent: true);

    store.scheduleDiskClear();
    final Stopwatch watch = Stopwatch()..start();
    await Get.find<AuthSessionController>().completeSignIn(
      const CustomerAuthResponseModel(
        accessToken: 'a',
        refreshToken: 'r',
        sessionId: 's',
        userId: 'u',
      ),
    );
    watch.stop();

    expect(watch.elapsedMilliseconds, lessThan(250));
    expect(
      Get.find<AuthSessionController>().hasAuthenticatedSession.value,
      isTrue,
    );
    // Drop the store so tearDown does not wait on hung SecItem Completers.
    Get.reset();
  });

  test(
    'TEST3 completeSignIn sets authenticated session for Welcome→Login path',
    () async {
      Get.testMode = true;
      Get.put<AuthTokenReader>(_MemoryTokens(), permanent: true);
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
      Get.put(
        UsersRepository(Get.find<ApiClient>(), vault: _MemoryVault()),
        permanent: true,
      );
      Get.put(AuthSessionController(), permanent: true);

      await Get.find<AuthSessionController>().completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'a',
          refreshToken: 'r',
          sessionId: 's',
          userId: 'u',
          username: 'Yazan',
          phone: '1',
        ),
      );

      expect(
        Get.find<AuthSessionController>().hasAuthenticatedSession.value,
        isTrue,
      );
      expect(Get.find<AuthSessionController>().isGuest.value, isFalse);
    },
  );

  test(
    'TEST5 completeSignIn does not start GET /users/me before Home owns it',
    () async {
      Get.testMode = true;
      final _RecordingUsers users = _RecordingUsers();
      Get.put<AuthTokenReader>(_MemoryTokens(), permanent: true);
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
      Get.put<UsersRepository>(users, permanent: true);
      Get.put(AuthSessionController(), permanent: true);

      await Get.find<AuthSessionController>().completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'a',
          refreshToken: 'r',
          sessionId: 's',
          userId: 'u',
          username: 'Yazan',
          phone: '1',
        ),
      );

      // Identity apply is deferred off the Login critical path.
      expect(users.profileLoadCount, 0);
      expect(users.cachedProfile?.username, isNull);
      await Get.find<AuthSessionController>().flushPostLoginBootstrap();
      expect(users.profileLoadCount, 0);
      expect(users.cachedProfile?.username, 'Yazan');
    },
  );

  testWidgets('TEST6 real session expiry clears tokens and opens Login deps', (
    tester,
  ) async {
    Get.testMode = true;
    final _MemoryTokens tokens = _MemoryTokens()..seed('a', 'r');
    Get.put<AuthTokenReader>(tokens, permanent: true);
    Get.put(ApiClient(tokenReader: tokens));
    Get.put(AuthRepository(), permanent: true);
    Get.put(
      UsersRepository(Get.find<ApiClient>(), vault: _MemoryVault()),
      permanent: true,
    );
    final AuthSessionController session = AuthSessionController();
    Get.put(session, permanent: true);
    session.hasAuthenticatedSession.value = true;

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.home,
        getPages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: AppRoutes.home,
            page: () => const SizedBox.shrink(),
          ),
          GetPage<dynamic>(
            name: AppRoutes.login,
            page: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await session.handleSessionExpired();
    await tester.pump();
    await tester.pump(Duration.zero);

    expect(session.hasAuthenticatedSession.value, isFalse);
    expect(await tokens.readAccessToken(), isNull);
    expect(await tokens.readRefreshToken(), isNull);
    expect(Get.isRegistered<LoginController>(), isTrue);
  });

  test('TEST7/8 Sign Up register-ok login-fail is recoverable', () async {
    Get.testMode = true;
    final _FakeAuthRepository auth = _FakeAuthRepository()..failLogin = true;
    Get.put<AuthRepository>(auth, permanent: true);
    Get.put<AuthTokenReader>(_MemoryTokens(), permanent: true);
    Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
    Get.put(AuthSessionController(), permanent: true);
    Get.put(LoginController(), permanent: true);

    Get.routing.args = const CustomerAuthOtpRouteArgs(
      purpose: CustomerAuthOtpPurpose.registration,
      countryCode: 'AE',
      dialCode: '+971',
      phoneNumber: '501234567',
      username: 'Yazan',
    );
    final CompleteRegistrationController controller =
        CompleteRegistrationController();
    Get.put(controller);
    controller.passwordController.text = 'SecretPass12!';
    controller.confirmPasswordController.text = 'SecretPass12!';
    controller.passwordController.notifyListeners();

    expect(controller.canSubmit.value, isTrue);
    await controller.submit();

    expect(auth.completeRegistrationCalls, 1);
    expect(auth.loginCalls, 1);
    expect(controller.isLoading.value, isFalse);
    expect(
      controller.errorMessage.value,
      AppStrings.authRegistrationComplete,
    );
    expect(
      Get.find<AuthSessionController>().hasAuthenticatedSession.value,
      isFalse,
    );
    expect(Get.find<LoginController>().phoneController.text, '501234567');

    // Account already created — another submit must not invent a second account
    // automatically; user recovers via Login. Re-submit still calls register
    // only if still on this screen — document that UI navigates away.
    expect(auth.completeRegistrationCalls, 1);
  });

  test('TEST7 Sign Up register + login success authenticates', () async {
    Get.testMode = true;
    final _FakeAuthRepository auth = _FakeAuthRepository();
    Get.put<AuthRepository>(auth, permanent: true);
    Get.put<AuthTokenReader>(_MemoryTokens(), permanent: true);
    Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
    Get.put(AuthSessionController(), permanent: true);

    Get.routing.args = const CustomerAuthOtpRouteArgs(
      purpose: CustomerAuthOtpPurpose.registration,
      countryCode: 'AE',
      dialCode: '+971',
      phoneNumber: '501234567',
      username: 'Yazan',
    );
    final CompleteRegistrationController controller =
        CompleteRegistrationController();
    Get.put(controller);
    controller.passwordController.text = 'SecretPass12!';
    controller.confirmPasswordController.text = 'SecretPass12!';
    controller.passwordController.notifyListeners();

    await controller.submit();

    expect(auth.completeRegistrationCalls, 1);
    expect(auth.loginCalls, 1);
    expect(
      Get.find<AuthSessionController>().hasAuthenticatedSession.value,
      isTrue,
    );
    expect(controller.isLoading.value, isFalse);
  });

  testWidgets('TEST9 LoginController double submit fires one request', (
    tester,
  ) async {
    Get.testMode = true;
    final _FakeAuthRepository auth = _FakeAuthRepository()
      ..loginDelay = const Duration(milliseconds: 30);
    Get.put<AuthRepository>(auth, permanent: true);
    Get.put<AuthTokenReader>(_MemoryTokens(), permanent: true);
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        connectTimeout: const Duration(milliseconds: 50),
        receiveTimeout: const Duration(milliseconds: 50),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{'items': <dynamic>[]},
              },
            ),
          );
        },
      ),
    );
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    Get.put(AuthSessionController(), permanent: true);
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.login,
        getPages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: AppRoutes.login,
            page: () => const SizedBox.shrink(),
          ),
          GetPage<dynamic>(
            name: AppRoutes.home,
            page: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
    final LoginController login = LoginController();
    Get.put(login);
    await tester.pump();
    login.phoneController.text = '501234567';
    login.passwordController.text = 'secret-password';
    login.countryCode.value = 'AE';
    login.phoneController.notifyListeners();

    final Future<void> first = login.submit();
    final Future<void> second = login.submit();
    // FakeAsync: advance the repository loginDelay so submit futures complete.
    await tester.pump(const Duration(milliseconds: 40));
    await Future.wait(<Future<void>>[first, second]);
    await tester.pump();
    await tester.pump(Duration.zero);

    expect(auth.loginCalls, 1);
    expect(login.isLoading.value, isFalse);
  });

  testWidgets('TEST10 goShell coalesces concurrent transitions to latest', (
    tester,
  ) async {
    Get.testMode = true;
    final List<String> visited = <String>[];

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.welcome,
        getPages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: AppRoutes.welcome,
            page: () {
              visited.add(AppRoutes.welcome);
              return const SizedBox.shrink();
            },
          ),
          GetPage<dynamic>(
            name: AppRoutes.home,
            page: () {
              visited.add(AppRoutes.home);
              return const SizedBox.shrink();
            },
          ),
          GetPage<dynamic>(
            name: AppRoutes.login,
            page: () {
              visited.add(AppRoutes.login);
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    AppNavigation.goShell(AppRoutes.home);
    AppNavigation.goShell(AppRoutes.login);
    await tester.pump();
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);

    expect(visited.contains(AppRoutes.home), isTrue);
    expect(visited.last, AppRoutes.login);
  });

  testWidgets('TEST11 Guest clears authenticated Home bootstrap gate', (
    tester,
  ) async {
    Get.testMode = true;
    final _RecordingUsers users = _RecordingUsers();
    await _registerGuestHomeStack(users: users, asGuest: false);
    final HomeController home = AppDependency.ensureHomeController();
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    await _pumpUntil(tester, () => home.didSchedulePostFrameLoads);

    await Get.find<AuthSessionController>().completeSignIn(
      const CustomerAuthResponseModel(
        accessToken: 'a',
        refreshToken: 'r',
        sessionId: 's',
        userId: 'u',
      ),
    );
    await Get.find<AuthSessionController>().flushPostLoginBootstrap();
    await _pumpUntil(tester, () => home.didStartAuthenticatedBootstrap);

    await Get.find<AuthSessionController>().enterAsGuest(
      deferSecureStorage: true,
    );
    expect(home.didStartAuthenticatedBootstrap, isFalse);

    await Get.find<AuthSessionController>().completeSignIn(
      const CustomerAuthResponseModel(
        accessToken: 'a2',
        refreshToken: 'r2',
        sessionId: 's2',
        userId: 'u2',
      ),
    );
    await Get.find<AuthSessionController>().flushPostLoginBootstrap();
    await _pumpUntil(tester, () => home.didStartAuthenticatedBootstrap);

    home.cancelProgressiveInit();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  });

  test('TEST12 SessionMode + tokens restore authenticated flags', () async {
    Get.testMode = true;
    final SecureAuthTokenStore store = SecureAuthTokenStore(
      vault: _MemoryVault(),
    );
    Get.put<AuthTokenReader>(store, permanent: true);
    Get.put(ApiClient(tokenReader: store));
    Get.put(AuthSessionController(), permanent: true);

    await store.updateSessionTokens(
      accessToken: 'persisted-access',
      refreshToken: 'persisted-refresh',
    );
    await store.flushPendingDiskWrites();
    await SessionModePreferences.write(SessionMode.authenticated);

    final AuthSessionController session = Get.find<AuthSessionController>();
    session.hasAuthenticatedSession.value = false;
    await session.syncFromStoredTokens();

    expect(session.hasAuthenticatedSession.value, isTrue);
    expect(session.isGuest.value, isFalse);
    expect(await store.readAccessToken(), 'persisted-access');
  });
}

Future<void> _registerGuestHomeStack({
  required _RecordingUsers users,
  bool asGuest = true,
}) async {
  _FakeTaxonomyRepository.cuisineLoadCount = 0;
  Get.put<AuthTokenReader>(_MemoryTokens(), permanent: true);
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost',
      validateStatus: (int? status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: <String, dynamic>{
              'success': true,
              'message': 'ok',
              'data': <String, dynamic>{
                'items': <dynamic>[],
                'page': 1,
                'limit': 20,
                'total': 0,
              },
            },
          ),
        );
      },
    ),
  );
  Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
  Get.put<TaxonomyRepository>(_FakeTaxonomyRepository());
  Get.put(DiscoveryRepository(Get.find<ApiClient>()));
  Get.put<UsersRepository>(users, permanent: true);
  Get.put<LocationService>(_FakeLocationService(), permanent: true);
  final AuthSessionController session = AuthSessionController();
  Get.put(session, permanent: true);
  if (asGuest) {
    // Defer Keychain so widget tests do not leave SecItem timeout timers.
    await session.enterAsGuest(deferSecureStorage: true);
  }
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() done, {
  int maxFrames = 40,
}) async {
  for (int i = 0; i < maxFrames; i++) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    if (done()) {
      return;
    }
  }
}

class _NoopNotificationsBadge extends NotificationsBadgeController {
  _NoopNotificationsBadge(super.repository);

  @override
  void scheduleRefresh() {}

  @override
  Future<void> refreshUnreadCount() async {}
}

class _RecordingUsers extends UsersRepository {
  _RecordingUsers() : super(_UnusedApiClient(), vault: _MemoryVault());

  int profileLoadCount = 0;

  @override
  Future<void> ensureProfileLoaded() async {
    profileLoadCount++;
    await super.ensureProfileLoaded();
  }

  @override
  Future<void> clearCustomerIdentity() async {
    clearSessionCaches();
  }

  @override
  Future<void> flushIdentityToDisk() async {}
}

class _UnusedApiClient extends ApiClient {
  _UnusedApiClient() : super(tokenReader: const EmptyAuthTokenReader());

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? raw) parseData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return ApiResponse<T>(
      success: true,
      message: 'ok',
      data: parseData(<String, dynamic>{
        'id': 'u',
        'username': '',
        'phone': '',
      }),
    );
  }
}

class _FakeTaxonomyRepository extends TaxonomyRepository {
  _FakeTaxonomyRepository() : super(_UnusedApiClient());

  static int cuisineLoadCount = 0;

  @override
  List<CuisineCategoryModel>? get cachedCuisineCategories =>
      const <CuisineCategoryModel>[
        CuisineCategoryModel(
          id: '1',
          slug: 'italian',
          name: 'Italian',
          sortOrder: 1,
        ),
      ];

  @override
  List<OccasionCategoryModel>? get cachedOccasionCategories =>
      const <OccasionCategoryModel>[
        OccasionCategoryModel(
          id: '1',
          slug: 'date',
          name: 'Date night',
          sortOrder: 1,
        ),
      ];

  @override
  Future<List<CuisineCategoryModel>> fetchCuisineCategories({
    bool forceRefresh = false,
  }) async {
    cuisineLoadCount++;
    return cachedCuisineCategories!;
  }

  @override
  Future<List<OccasionCategoryModel>> fetchOccasionCategories({
    bool forceRefresh = false,
  }) async {
    return cachedOccasionCategories!;
  }
}

class _FakeLocationService extends LocationService {
  @override
  Future<bool> isServiceEnabled() async => false;

  @override
  Future<LocationPermissionState> checkPermission() async {
    return LocationPermissionState.serviceDisabled;
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    return LocationPermissionState.serviceDisabled;
  }

  @override
  Future<UserLocationModel> getCurrentLocation() async {
    return const UserLocationModel(
      permissionStatus: LocationPermissionState.serviceDisabled,
      isServiceEnabled: false,
    );
  }

  @override
  Future<bool> openAppSettings() async => false;

  @override
  Future<bool> openLocationSettings() async => false;
}

class _MemoryTokens implements AuthTokenSession {
  String? accessToken;
  String? refreshToken;

  void seed(String access, String refresh) {
    accessToken = access;
    refreshToken = refresh;
  }

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

class _MemoryVault implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}

class _HangingVault implements SecureKeyValueStore {
  @override
  Future<String?> read(String key) => Completer<String?>().future;

  @override
  Future<void> write(String key, String value) => Completer<void>().future;

  @override
  Future<void> delete(String key) => Completer<void>().future;
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super();

  int completeRegistrationCalls = 0;
  int loginCalls = 0;
  bool failLogin = false;
  Duration? loginDelay;

  @override
  Future<CustomerRegistrationResponseModel> completeCustomerRegistration(
    CustomerRegistrationCompleteRequestModel request,
  ) async {
    completeRegistrationCalls++;
    return const CustomerRegistrationResponseModel(userId: 'new-user');
  }

  @override
  Future<CustomerAuthResponseModel> loginCustomer(
    CustomerLoginRequestModel request,
  ) async {
    loginCalls++;
    final Duration? delay = loginDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    if (failLogin) {
      throw const ApiException(message: 'network down');
    }
    return const CustomerAuthResponseModel(
      accessToken: 'a',
      refreshToken: 'r',
      sessionId: 's',
      userId: 'u',
      username: 'Yazan',
      phone: '501234567',
    );
  }
}
