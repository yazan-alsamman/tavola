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
import 'package:tavla/core/utils/favorite_cuisines_preferences.dart';
import 'package:tavla/core/utils/onboarding_preferences.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/profile/controller/profile_controller.dart';
import 'package:tavla/features/profile/view/profile_screen.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('profile binding instantiates controller and survives re-entry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
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

    await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
    await tester.pump();
    await tester.pump(AppDimensions.splashDisplayDuration);
    await tester.pump(const Duration(milliseconds: 300));

    expect(Get.isRegistered<ProfileController>(), isFalse);

    Get.offAllNamed(AppRoutes.home);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(Get.isRegistered<HomeController>(), isTrue);
    expect(Get.isRegistered<ProfileController>(), isFalse);

    final HomeController homeBeforeProfile = Get.find<HomeController>();

    Get.offAllNamed(AppRoutes.profile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(Get.currentRoute, AppRoutes.profile);
    expect(Get.isRegistered<ProfileController>(), isTrue);
    expect(Get.find<ProfileController>().isClosed, isFalse);
    expect(find.byType(ProfileScreen), findsOneWidget);
    // Shell tabs must keep Home alive across Profile (no HomeController delete).
    expect(Get.isRegistered<HomeController>(), isTrue);
    expect(Get.find<HomeController>().isClosed, isFalse);
    expect(identical(Get.find<HomeController>(), homeBeforeProfile), isTrue);

    final ProfileController controller = Get.find<ProfileController>();
    expect(controller.sections, isNotEmpty);
    expect(controller.isLoadingProfile.value, isFalse);

    controller.selectSection(ProfileController.settingsSectionIndex);
    await tester.pump();
    expect(tester.takeException(), isNull);

    controller.selectSection(ProfileController.favoritesSectionIndex);
    await tester.pump();
    expect(tester.takeException(), isNull);

    Get.offAllNamed(AppRoutes.home);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    Get.offAllNamed(AppRoutes.profile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(Get.currentRoute, AppRoutes.profile);
    expect(Get.isRegistered<ProfileController>(), isTrue);
    expect(Get.find<ProfileController>().isClosed, isFalse);
    expect(find.byType(ProfileScreen), findsWidgets);
  });
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
