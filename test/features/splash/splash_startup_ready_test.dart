import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/core/utils/favorite_cuisines_preferences.dart';
import 'package:tavla/core/utils/onboarding_preferences.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/controller/sign_up_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/auth/view/sign_up_screen.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/splash/controller/splash_controller.dart';
import 'package:tavla/features/splash/splash_assets.dart';
import 'package:tavla/features/splash/view/splash_screen.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('splash login signup controllers ready at welcome route open', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    Get.locale = const Locale('en');

    await OnboardingPreferences.markCompleted();
    await FavoriteCuisinesPreferences.markCompleted();
    await tester.runAsync(SplashAssets.precacheLavender);

    _registerMinimalStartup();
    AppDependency.putIfAbsent(SplashController.new);

    expect(Get.isRegistered<SplashController>(), isTrue);
    expect(Get.find<SplashController>().isClosed, isFalse);

    await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    final SplashController splash = Get.find<SplashController>();
    await tester.pump(const Duration(milliseconds: 50));
    expect(identical(splash, Get.find<SplashController>()), isTrue);
    expect(tester.takeException(), isNull);

    // Leave splash without waiting on the display timer.
    Get.delete<SplashController>(force: true);
    Get.offAllNamed(AppRoutes.welcome);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(Get.isRegistered<LoginController>(), isTrue);
    expect(Get.isRegistered<SignUpController>(), isTrue);

    Get.toNamed(AppRoutes.login);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(Get.isRegistered<LoginController>(), isTrue);
    expect(Get.find<LoginController>().isClosed, isFalse);

    Get.back();
    await tester.pump();
    Get.toNamed(AppRoutes.signUp);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(Get.isRegistered<SignUpController>(), isTrue);
    expect(Get.find<SignUpController>().isClosed, isFalse);
  });
}

void _registerMinimalStartup() {
  Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
  Get.put(AuthRepository());
  Get.put(AuthSessionController());
  Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
  Get.put(LocaleController()).syncFromLocale(const Locale('en'));
  Get.put<LocationService>(_FakeLocationService());
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
