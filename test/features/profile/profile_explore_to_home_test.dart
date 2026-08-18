import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/favorite_cuisines_preferences.dart';
import 'package:tavla/core/utils/onboarding_preferences.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/controller/user_location_controller.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/profile/controller/profile_controller.dart';
import 'package:tavla/features/profile/view/profile_screen.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Single widget test: GetX reset between cases clears the route tree and
  // breaks subsequent GetMaterialApp navigation in the same isolate.
  testWidgets(
    'Explore from Profile keeps shell controllers and rebuilds Home safely',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      Get.testMode = true;
      Get.reset();
      Get.testMode = true;
      Get.locale = const Locale('en');

      await OnboardingPreferences.markCompleted();
      await FavoriteCuisinesPreferences.markCompleted();

      Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
      Get.put(AuthRepository());
      Get.put(AuthSessionController());
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
      Get.put(LocaleController()).syncFromLocale(const Locale('en'));
      Get.put<LocationService>(_FakeLocationService());
      Get.find<AuthSessionController>().isGuest.value = true;
      Get.find<AuthSessionController>().hasAuthenticatedSession.value = false;

      final List<FlutterErrorDetails> frameworkErrors = <FlutterErrorDetails>[];
      final FlutterExceptionHandler? previousOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        frameworkErrors.add(details);
        previousOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = previousOnError;
        Get.reset();
      });

      await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
      await tester.pump();
      await tester.pump(AppDimensions.splashDisplayDuration);
      await tester.pump(const Duration(milliseconds: 300));

      // --- Path A: Home → Profile → Explore → Home (controllers must survive) ---
      Get.offAllNamed(AppRoutes.home);
      await tester.pump();
      for (int i = 0; i < 20; i++) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));
        if (Get.isRegistered<UserLocationController>()) {
          break;
        }
      }
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(Get.isRegistered<HomeController>(), isTrue);
      expect(Get.find<HomeController>().isClosed, isFalse);

      final HomeController homeBeforeExplore = Get.find<HomeController>();
      final UserLocationController locationBeforeExplore =
          Get.find<UserLocationController>();

      Get.offAllNamed(AppRoutes.profile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(Get.isRegistered<ProfileController>(), isTrue);
      expect(Get.find<ProfileController>().isClosed, isFalse);
      expect(identical(Get.find<HomeController>(), homeBeforeExplore), isTrue);
      expect(Get.find<HomeController>().isClosed, isFalse);

      await tester.ensureVisible(find.text(AppStrings.explore));
      await tester.tap(find.text(AppStrings.explore));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(frameworkErrors, isEmpty, reason: frameworkErrors.toString());
      expect(Get.currentRoute, AppRoutes.home);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(Get.find<HomeController>().isClosed, isFalse);
      expect(
        identical(Get.find<HomeController>(), homeBeforeExplore),
        isTrue,
        reason: 'Explore must not recreate/dispose HomeController',
      );
      expect(
        identical(Get.find<UserLocationController>(), locationBeforeExplore),
        isTrue,
      );
      expect(Get.find<ProfileController>().isClosed, isFalse);

      // --- Path B: controller API (same as banner) ---
      Get.offAllNamed(AppRoutes.profile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ProfileScreen), findsOneWidget);

      Get.find<ProfileController>().exploreHome();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(frameworkErrors, isEmpty, reason: frameworkErrors.toString());
      expect(Get.currentRoute, AppRoutes.home);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(identical(Get.find<HomeController>(), homeBeforeExplore), isTrue);
      expect(Get.find<HomeController>().isClosed, isFalse);

      // --- Path C: Profile first (no prior Home), then Explore ---
      // Drop shell controllers so Home must be created fresh by Binding.
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>(force: true);
      }
      if (Get.isRegistered<UserLocationController>()) {
        Get.delete<UserLocationController>(force: true);
      }

      Get.offAllNamed(AppRoutes.profile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(Get.isRegistered<HomeController>(), isFalse);

      await tester.ensureVisible(find.text(AppStrings.explore));
      await tester.tap(find.text(AppStrings.explore));
      await tester.pump();
      for (int i = 0; i < 20; i++) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));
        if (Get.isRegistered<UserLocationController>()) {
          break;
        }
      }

      expect(tester.takeException(), isNull);
      expect(frameworkErrors, isEmpty, reason: frameworkErrors.toString());
      expect(Get.currentRoute, AppRoutes.home);
      expect(find.byType(HomeScreen), findsWidgets);
      expect(Get.isRegistered<HomeController>(), isTrue);
      expect(Get.find<HomeController>().isClosed, isFalse);
      expect(Get.isRegistered<UserLocationController>(), isTrue);
      expect(Get.find<UserLocationController>().isClosed, isFalse);

      // Flush guest Home Stage 8 Discovery / Dio timers before teardown.
      await tester.pump(AppDimensions.locationServiceCheckTimeout);
      await tester.pump(AppDimensions.apiConnectTimeout);
      await tester.pump(AppDimensions.homeCatalogLoadTimeout);
      await tester.pump();
    },
  );
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
