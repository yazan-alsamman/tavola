import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/core/utils/favorite_cuisines_preferences.dart';
import 'package:tavla/core/utils/onboarding_preferences.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/home/home_progressive_init.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/notifications/controller/notifications_badge_controller.dart';
import 'package:tavla/features/users/repository/users_repository.dart';
import 'package:tavla/main.dart';

/// Captured HTTP row for the Guest-mode audit report.
class _HttpHit {
  _HttpHit({
    required this.method,
    required this.url,
    required this.statusCode,
    required this.hasAuthorization,
    required this.classification,
  });

  final String method;
  final String url;
  final int statusCode;
  final bool hasAuthorization;
  final String classification;

  @override
  String toString() =>
      '$method $url | status=$statusCode | Authorization=$hasAuthorization | $classification';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets(
    'Continue as Guest: public-only HTTP, no Bearer, no login/refresh',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      Get.testMode = true;
      Get.reset();
      Get.locale = const Locale('en');

      await OnboardingPreferences.markCompleted();
      await FavoriteCuisinesPreferences.markCompleted();

      final List<_HttpHit> hits = <_HttpHit>[];
      final _MemoryAuthTokenStore tokens = _MemoryAuthTokenStore(
        accessToken: 'stale-access',
        refreshToken: 'stale-refresh',
      );

      final Dio dio = Dio(
        BaseOptions(
          baseUrl: AppUrls.apiBaseUrl,
          validateStatus: (int? status) =>
              status != null && status >= 200 && status < 500,
        ),
      );

      Get.put<AuthTokenReader>(tokens, permanent: true);
      Get.put(AuthRepository(), permanent: true);
      final AuthSessionController session = Get.put(
        AuthSessionController(),
        permanent: true,
      );
      Get.put<GuestModeReader>(session, permanent: true);
      Get.put(
        ApiClient(
          dio: dio,
          tokenReader: tokens,
          guestModeReader: session,
          authRepository: Get.find<AuthRepository>(),
          onSessionExpired: () async {
            await session.handleSessionExpired();
          },
        ),
        permanent: true,
      );

      // Capture AFTER ApiClient auth interceptor so Authorization reflects
      // guest stripping, then resolve so no real network / fake-async hang.
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                final String path = options.path;
                final Object? authHeader = options.headers['Authorization'];
                final bool hasAuth =
                    authHeader != null &&
                    authHeader.toString().trim().isNotEmpty;
                final int status = _statusForPath(path);
                hits.add(
                  _HttpHit(
                    method: options.method,
                    url: path,
                    statusCode: status,
                    hasAuthorization: hasAuth,
                    classification: _classify(path),
                  ),
                );
                handler.resolve(
                  Response<dynamic>(
                    requestOptions: options,
                    statusCode: status,
                    data: _bodyForPath(path),
                  ),
                );
              },
        ),
      );

      Get.put(LocaleController()).syncFromLocale(const Locale('en'));
      Get.put<LocationService>(_FakeLocationService(), permanent: true);

      await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
      await tester.pump();

      await session.prepareGuestHomeEntry();
      expect(session.isAnonymousGuest, isTrue);
      expect(await tokens.readAccessToken(), isNull);
      expect(await tokens.readRefreshToken(), isNull);

      Get.offAllNamed(AppRoutes.home);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(HomeScreen), findsOneWidget);

      for (int i = 0; i < 40; i++) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));
        if (Get.isRegistered<HomeController>() &&
            Get.find<HomeController>().progressiveStage.value >=
                HomeProgressiveInit.stageComplete &&
            Get.find<HomeController>().restaurants.isNotEmpty) {
          break;
        }
      }

      expect(
        Get.find<HomeController>().progressiveStage.value,
        HomeProgressiveInit.stageComplete,
      );
      expect(Get.isRegistered<UsersRepository>(), isFalse);
      expect(Get.isRegistered<FavoritesRepository>(), isFalse);
      expect(Get.isRegistered<NotificationsBadgeController>(), isFalse);

      final HomeController home = Get.find<HomeController>();
      expect(home.restaurants, isNotEmpty);
      home.updateSearch('Sakura');
      expect(home.filteredRestaurants, isNotEmpty);
      // Flush Home search debounce so no Timer remains after dispose.
      await tester.pump(AppDimensions.homeSearchDebounce);
      await tester.pump();

      final DiscoveryRepository discovery = Get.find<DiscoveryRepository>();
      // Dio interceptor completions need a real async zone under WidgetTester.
      await tester.runAsync(() async {
        final restaurant = await discovery.getRestaurantById('rest-1');
        expect(restaurant.id, 'rest-1');
        expect(await discovery.listBranches('rest-1'), isNotEmpty);
        expect(
          await discovery.listNearbyRestaurants(
            latitude: 25.2,
            longitude: 55.3,
          ),
          isNotEmpty,
        );
        expect(await discovery.listOffers('rest-1'), isNotEmpty);
      });

      // ignore: avoid_print — required Guest HTTP audit report.
      print('GUEST_HTTP_AUDIT (${hits.length}):');
      for (final _HttpHit hit in hits) {
        // ignore: avoid_print
        print('  $hit');
      }

      expect(
        hits.any((h) => h.url.contains('/auth/customer/login')),
        isFalse,
        reason: 'Guest must never call login. Hits: $hits',
      );
      expect(
        hits.any((h) => h.url.contains('/auth/refresh')),
        isFalse,
        reason: 'Guest must never call refresh. Hits: $hits',
      );
      expect(
        hits.any((h) => h.hasAuthorization),
        isFalse,
        reason: 'Guest must never send Authorization. Hits: $hits',
      );
      expect(
        hits.any((h) => h.classification == 'Authenticated'),
        isFalse,
        reason: 'Guest must never hit authenticated endpoints. Hits: $hits',
      );
      expect(
        hits.any((h) => h.url.contains('/discovery/restaurants')),
        isTrue,
      );
      expect(hits.any((h) => h.url.contains('/cuisine-categories')), isTrue);
      expect(hits.any((h) => h.url.contains('/occasion-categories')), isTrue);
      expect(
        hits.any((h) => h.url.contains('/discovery/restaurants/nearby')),
        isTrue,
      );
      expect(hits.any((h) => h.url.contains('/offers')), isTrue);
      expect(hits.any((h) => h.url.contains('/branches')), isTrue);
    },
  );

  test('ApiClient guest mode never attaches Bearer or refreshes', () async {
    Get.testMode = true;
    Get.reset();

    final _MemoryAuthTokenStore tokens = _MemoryAuthTokenStore(
      accessToken: 'should-not-send',
      refreshToken: 'should-not-refresh',
    );
    final AuthSessionController session = AuthSessionController();
    session.isGuest.value = true;
    session.hasAuthenticatedSession.value = false;

    bool refreshHit = false;
    bool sessionExpiredCalled = false;
    String? authorization;
    final Dio apiDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    final Dio authDio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    authDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          refreshHit = true;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{
                  'accessToken': 'new',
                  'refreshToken': 'new',
                },
              },
            ),
          );
        },
      ),
    );

    final ApiClient client = ApiClient(
      dio: apiDio,
      tokenReader: tokens,
      guestModeReader: session,
      authRepository: AuthRepository(dio: authDio),
      onSessionExpired: () async {
        sessionExpiredCalled = true;
      },
    );

    apiDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          authorization = options.headers['Authorization']?.toString();
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 401,
                data: <String, dynamic>{
                  'success': false,
                  'message': 'unauthorized',
                },
              ),
            ),
          );
        },
      ),
    );

    await expectLater(
      client.get<Map<String, dynamic>>(
        '/users/me',
        parseData: (Object? raw) =>
            Map<String, dynamic>.from(raw as Map<String, dynamic>),
      ),
      throwsA(isA<Exception>()),
    );

    expect(authorization, isNull);
    expect(refreshHit, isFalse);
    expect(sessionExpiredCalled, isFalse);
  });

  testWidgets('guest progressive init skips auth dependency registration', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    Get.reset();

    final List<String> paths = <String>[];
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    final AuthSessionController session = Get.put(AuthSessionController());
    Get.put<GuestModeReader>(session);
    await session.enterAsGuest();
    Get.put(
      ApiClient(
        dio: dio,
        tokenReader: Get.find<AuthTokenReader>(),
        guestModeReader: session,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          paths.add(options.path);
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
    Get.put<LocationService>(_FakeLocationService(), permanent: true);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            AppDependency.ensureHomeController();
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    for (int i = 0; i < 40; i++) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      if (Get.find<HomeController>().progressiveStage.value >=
          HomeProgressiveInit.stageComplete) {
        break;
      }
    }

    // Flush Special Offer nearby/offers Dio work (fake-async zone).
    for (int i = 0; i < 60; i++) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      final HomeController home = Get.find<HomeController>();
      if (!home.isLoadingSpecialOffer.value &&
          (home.featuredOffer.value != null ||
              home.specialOfferError.value != null ||
              paths.any((String p) => p.contains('/nearby')))) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 50));

    expect(Get.isRegistered<UsersRepository>(), isFalse);
    expect(Get.isRegistered<FavoritesRepository>(), isFalse);
    expect(Get.isRegistered<NotificationsBadgeController>(), isFalse);
    expect(
      paths.any((String p) => p.contains('/users/me')),
      isFalse,
      reason: 'paths=$paths',
    );
    expect(
      paths.any((String p) => p.contains('/notifications')),
      isFalse,
      reason: 'paths=$paths',
    );
    expect(
      paths.any((String p) => p.contains('/favorites')),
      isFalse,
      reason: 'paths=$paths',
    );
  });
}

String _classify(String path) {
  final String lower = path.toLowerCase();
  if (lower.contains('/auth/customer/login') ||
      lower.contains('/auth/refresh') ||
      lower.contains('/users/me') ||
      lower.contains('/favorites') ||
      lower.contains('/notifications') ||
      lower.contains('/reservations/my') ||
      lower.contains('/profile')) {
    return 'Authenticated';
  }
  if (lower.contains('/discovery/') ||
      lower.contains('/cuisine-categories') ||
      lower.contains('/occasion-categories') ||
      lower.contains('/health')) {
    return 'Public';
  }
  return 'Unknown';
}

int _statusForPath(String path) {
  if (_classify(path) == 'Authenticated') {
    return 401;
  }
  return 200;
}

Map<String, dynamic> _bodyForPath(String path) {
  final String lower = path.toLowerCase();
  if (lower.contains('/branches')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{
        'items': <dynamic>[
          <String, dynamic>{
            'branchId': 'b1',
            'city': 'Dubai',
            'district': 'JBR',
            'address': '1 Marina',
            'phone': '+971500000000',
          },
        ],
        'count': 1,
      },
    };
  }
  if (lower.contains('/offers')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{
        'items': <dynamic>[
          <String, dynamic>{
            'offerId': 'o1',
            'restaurantId': 'rest-1',
            'type': 'Promotion',
            'title': 'Guest Offer',
            'description': '20% off for guests',
            'discountType': 'Percentage',
            'discountValue': 20,
            'status': 'Published',
          },
        ],
        'count': 1,
      },
    };
  }
  if (lower.contains('/discovery/restaurants/') &&
      !lower.contains('nearby') &&
      !lower.contains('branches') &&
      !lower.contains('offers')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{
        'restaurantId': 'rest-1',
        'name': 'Sakura Sushi House',
        'status': 'Active',
        'description': 'Japanese',
      },
    };
  }
  return <String, dynamic>{
    'success': true,
    'message': 'ok',
    'data': <String, dynamic>{
      'items': <dynamic>[
        <String, dynamic>{
          'restaurantId': 'rest-1',
          'name': 'Sakura Sushi House',
          'status': 'Active',
          'description': 'Japanese',
          'hasActiveOffer': true,
        },
      ],
      'count': 1,
      'page': 1,
      'limit': 20,
      'total': 1,
    },
  };
}

class _MemoryAuthTokenStore implements AuthTokenSession {
  _MemoryAuthTokenStore({String? accessToken, String? refreshToken})
    : _access = accessToken,
      _refresh = refreshToken;

  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
    bool persistToDisk = true,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> clearSessionTokens() async {
    _access = null;
    _refresh = null;
  }
}

class _FakeLocationService extends LocationService {
  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<LocationPermissionState> checkPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<LocationPermissionState> requestPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<UserLocationModel> getCurrentLocation() async {
    return const UserLocationModel(
      permissionStatus: LocationPermissionState.granted,
      isServiceEnabled: true,
      latitude: 25.2,
      longitude: 55.3,
    );
  }

  @override
  Future<bool> openAppSettings() async => false;

  @override
  Future<bool> openLocationSettings() async => false;
}
