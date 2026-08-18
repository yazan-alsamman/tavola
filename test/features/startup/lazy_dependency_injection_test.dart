import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/core/utils/favorite_cuisines_preferences.dart';
import 'package:tavla/core/utils/onboarding_preferences.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/branches/repository/branch_repository.dart';
import 'package:tavla/features/details/repository/restaurant_details_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/controller/user_location_controller.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/map/repository/restaurant_map_repository.dart';
import 'package:tavla/features/profile/repository/profile_repository.dart';
import 'package:tavla/features/reservation/repository/reservation_availability_repository.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';
import 'package:tavla/features/reservation/repository/table_repository.dart';
import 'package:tavla/features/splash/view/splash_screen.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  test('ensure helpers create shared repos only when invoked', () {
    Get.testMode = true;
    Get.reset();
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));

    expect(Get.isRegistered<ReservationRepository>(), isFalse);

    AppDependency.ensureReservationFlowDependencies();
    expect(Get.isRegistered<ReservationRepository>(), isTrue);
    expect(Get.isRegistered<TableRepository>(), isTrue);
    expect(Get.isRegistered<BranchRepository>(), isTrue);
    expect(Get.isRegistered<ReservationAvailabilityRepository>(), isTrue);

    AppDependency.ensureHomeDependencies();
    expect(Get.isRegistered<FavoritesRepository>(), isTrue);
    expect(Get.isRegistered<TaxonomyRepository>(), isTrue);
    expect(Get.isRegistered<UserLocationController>(), isTrue);
  });

  testWidgets('feature repositories are not created before their routes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    Get.locale = const Locale('en');

    await OnboardingPreferences.markCompleted();
    await FavoriteCuisinesPreferences.markCompleted();

    _registerMinimalStartupGraph();

    await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    expect(Get.isRegistered<AuthRepository>(), isTrue);
    expect(Get.isRegistered<AuthSessionController>(), isTrue);
    expect(Get.isRegistered<ApiClient>(), isTrue);
    expect(Get.isRegistered<LocaleController>(), isTrue);
    expect(Get.isRegistered<FavoritesRepository>(), isFalse);
    expect(Get.isRegistered<UsersRepository>(), isFalse);
    expect(Get.isRegistered<TaxonomyRepository>(), isFalse);
    expect(Get.isRegistered<BranchRepository>(), isFalse);
    expect(Get.isRegistered<ReservationRepository>(), isFalse);
    expect(Get.isRegistered<TableRepository>(), isFalse);
    expect(Get.isRegistered<ProfileRepository>(), isFalse);
    expect(Get.isRegistered<UserLocationController>(), isFalse);
    expect(Get.isRegistered<RestaurantMapRepository>(), isFalse);
    expect(Get.isRegistered<RestaurantDetailsRepository>(), isFalse);
    expect(Get.isRegistered<ReservationAvailabilityRepository>(), isFalse);
    // Home shell controllers must stay dormant for the whole splash.
    expect(Get.isRegistered<HomeController>(), isFalse);

    await tester.pump(AppDimensions.splashReadyDuration);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    // Welcome Binding warms Login/SignUp only — UsersRepository stays lazy
    // until post-login identity or Home Stage 4.
    // HomeEntryWarmup (post-frame) warms taxonomy/promo only — not Favorites.
    expect(Get.isRegistered<UsersRepository>(), isFalse);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(Get.isRegistered<FavoritesRepository>(), isFalse);
    expect(Get.isRegistered<TaxonomyRepository>(), isTrue);

    Get.toNamed(AppRoutes.login);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(Get.isRegistered<UsersRepository>(), isFalse);
    expect(Get.isRegistered<FavoritesRepository>(), isFalse);

    Get.back();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    Get.find<AuthSessionController>().isGuest.value = true;
    Get.offAllNamed(AppRoutes.home);
    await tester.pump();
    // Progressive init spreads shell deps across frames after first paint.
    for (int i = 0; i < 20; i++) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      if (Get.isRegistered<UserLocationController>()) {
        break;
      }
    }

    expect(find.byType(HomeScreen), findsOneWidget);
    // Guest Home skips auth bands (profile/preferences/favorites/notifications)
    // and jumps to location — Favorites stays unregistered until a real session.
    expect(Get.isRegistered<FavoritesRepository>(), isFalse);
    expect(Get.isRegistered<TaxonomyRepository>(), isTrue);
    expect(Get.isRegistered<UserLocationController>(), isTrue);
    expect(Get.isRegistered<RestaurantMapRepository>(), isFalse);
    expect(Get.isRegistered<ProfileRepository>(), isFalse);

    // Flush deferred Home / location / Dio timers from the first Home frame.
    await tester.pump(AppDimensions.locationServiceCheckTimeout);
    await tester.pump(AppDimensions.apiConnectTimeout);
    await tester.pump(AppDimensions.homeCatalogLoadTimeout);
    await tester.pump();
  });
}

void _registerMinimalStartupGraph() {
  Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
  Get.put(AuthRepository());
  Get.put(AuthSessionController());
  Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
  Get.put(LocaleController()).syncFromLocale(const Locale('en'));
  Get.put<LocationService>(_FakeLocationService(), permanent: true);
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
