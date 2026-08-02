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
import 'package:tavla/core/utils/favorite_cuisines_preferences.dart';
import 'package:tavla/core/utils/onboarding_preferences.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/map/view/restaurant_map_screen.dart';
import 'package:tavla/features/profile/view/profile_screen.dart';
import 'package:tavla/main.dart';

/// Captures every Dio request path during Splash → Guest Home → Map → Profile.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets('guest lifecycle never contacts /restaurants', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    Get.locale = const Locale('en');

    await OnboardingPreferences.markCompleted();
    await FavoriteCuisinesPreferences.markCompleted();

    final List<String> hits = <String>[];
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.apiBaseUrl,
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          hits.add('${options.method} ${options.path}');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{'items': <dynamic>[], 'count': 0},
              },
            ),
          );
        },
      ),
    );

    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(AuthRepository());
    Get.put(AuthSessionController());
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    Get.put(LocaleController()).syncFromLocale(const Locale('en'));
    Get.put<LocationService>(_FakeLocationService(), permanent: true);

    await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
    await tester.pump();
    await tester.pump(AppDimensions.splashDisplayDuration);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    Get.find<AuthSessionController>().isGuest.value = true;
    Get.offAllNamed(AppRoutes.home);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(HomeScreen), findsOneWidget);

    Get.offAllNamed(AppRoutes.map);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(RestaurantMapScreen), findsOneWidget);

    Get.offAllNamed(AppRoutes.profile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.pump(AppDimensions.apiConnectTimeout);
    await tester.pump();

    // ignore: avoid_print — verification report for restaurant HTTP audit.
    print('HTTP_LIFECYCLE_HITS (${hits.length}):');
    for (final String hit in hits) {
      // ignore: avoid_print
      print('  $hit');
    }

    // Admin tenant `/restaurants` is forbidden; customer Discovery is allowed.
    final List<String> adminRestaurantHits = hits.where((String hit) {
      final String lower = hit.toLowerCase();
      return lower.contains('/restaurants') &&
          !lower.contains('/discovery/restaurants');
    }).toList();
    expect(adminRestaurantHits, isEmpty, reason: 'Observed hits: $hits');
    expect(
      hits.any((String hit) => hit.contains('/discovery/restaurants')),
      isTrue,
      reason: 'Home should load Discovery catalog. Hits: $hits',
    );
  });
}

class _FakeLocationService extends LocationService {
  @override
  Future<bool> isServiceEnabled() async => false;

  @override
  Future<LocationPermissionState> checkPermission() async =>
      LocationPermissionState.serviceDisabled;

  @override
  Future<LocationPermissionState> requestPermission() async =>
      LocationPermissionState.serviceDisabled;

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
