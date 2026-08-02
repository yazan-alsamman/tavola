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
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/cuisine_preferences/view/favorite_cuisines_screen.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/home_progressive_init.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/onboarding/view/onboarding_screen.dart';
import 'package:tavla/features/splash/view/splash_screen.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

/// Startup path through Home. Taxonomy/network errors on later screens are
/// tolerated — the goal is that navigation and guest entry do not freeze.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('first four screens reach Home as guest', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    Get.locale = const Locale('en');

    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(AuthRepository());
    Get.put(AuthSessionController());
    Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
    Get.put<LocationService>(_FakeLocationService());
    Get.put(LocaleController()).syncFromLocale(const Locale('en'));

    await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(AppDimensions.splashDisplayDuration);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await OnboardingPreferences.markCompleted();
    Get.offAllNamed(AppRoutes.favoriteCuisines);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(FavoriteCuisinesScreen), findsOneWidget);

    await FavoriteCuisinesPreferences.markCompleted();
    Get.offAllNamed(AppRoutes.welcome);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WelcomeScreen), findsOneWidget);

    Get.toNamed(AppRoutes.login);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LoginScreen), findsOneWidget);

    final LoginController login = Get.find<LoginController>();
    login.phoneController.text = '554244748';
    login.passwordController.text = 'short';
    login.phoneController.notifyListeners();
    login.passwordController.notifyListeners();
    await tester.pump();
    expect(login.canSubmit.value, isFalse);
    expect(login.isLoading.value, isFalse);

    final AuthSessionController session = Get.find<AuthSessionController>();
    session.isGuest.value = true;
    session.hasAuthenticatedSession.value = false;
    Get.offAllNamed(AppRoutes.home);
    await tester.pump();
    for (int i = 0; i < 20; i++) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      if (Get.isRegistered<HomeController>() &&
          Get.find<HomeController>().progressiveStage.value >=
              HomeProgressiveInit.stageComplete) {
        break;
      }
    }

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(session.isGuest.value, isTrue);
    expect(tester.takeException(), isNull);
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
