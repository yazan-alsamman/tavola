import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/onboarding/view/onboarding_screen.dart';
import 'package:tavla/features/splash/view/splash_screen.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke: splash reaches onboarding', (tester) async {
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

    await tester.pump(AppDimensions.splashReadyDuration);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(OnboardingScreen), findsOneWidget);
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
