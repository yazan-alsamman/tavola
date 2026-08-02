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
import 'package:tavla/features/auth/controller/sign_up_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets(
    'welcome route auto-loads Login SignUp and guest session',
    (tester) async {
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
      Get.put<LocationService>(_FakeLocationService(), permanent: true);

      expect(Get.isRegistered<LoginController>(), isFalse);
      expect(Get.isRegistered<SignUpController>(), isFalse);

      await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
      await tester.pump();

      Get.offAllNamed(AppRoutes.welcome);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Entry controllers must exist before any button tap.
      expect(Get.isRegistered<LoginController>(), isTrue);
      expect(Get.find<LoginController>().isClosed, isFalse);

      expect(Get.isRegistered<SignUpController>(), isTrue);
      expect(Get.find<SignUpController>().isClosed, isFalse);

      // Guest session controller (permanent) is ready for Continue as Guest.
      expect(Get.isRegistered<AuthSessionController>(), isTrue);
      expect(Get.find<AuthSessionController>().isClosed, isFalse);

      // Opening login reuses the warmed LoginController instance.
      final LoginController warmedLogin = Get.find<LoginController>();
      Get.toNamed(AppRoutes.login);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(identical(warmedLogin, Get.find<LoginController>()), isTrue);

      // Flush idle HomeEntryWarmup (taxonomy/promo) timers.
      await tester.pump(AppDimensions.homeAssetPrecacheTimeout);
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
