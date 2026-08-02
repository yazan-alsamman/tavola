import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/cuisine_preferences/view/favorite_cuisines_screen.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/onboarding/view/onboarding_screen.dart';
import 'package:tavla/features/onboarding/widgets/onboarding_welcome_page.dart';
import 'package:tavla/features/splash/view/splash_screen.dart';
import 'package:tavla/main.dart';

/// Full onboarding journey for English + Arabic.
///
/// Regression: confirmation page crashed with
/// `BoxConstraints forces an infinite height` in ProfileReservationCard.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('onboarding instructions complete for EN and AR', (
    WidgetTester tester,
  ) async {
    await _runJourney(tester, locale: const Locale('en'));
    await _runJourney(tester, locale: const Locale('ar'));
  });
}

Future<void> _runJourney(WidgetTester tester, {required Locale locale}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  Get.reset();
  Get.testMode = true;
  Get.locale = locale;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  _registerAppDependencies(locale: locale);

  await tester.pumpWidget(TavolaApp(initialLocale: locale));
  await tester.pump();
  expect(find.byType(SplashScreen), findsOneWidget);

  await tester.pump(AppDimensions.splashDisplayDuration);
  await tester.pump();
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

  expect(find.byType(OnboardingScreen), findsOneWidget);
  expect(find.byType(OnboardingWelcomePage), findsOneWidget);
  expect(tester.takeException(), isNull);

  final PageController pageController = tester
      .widget<PageView>(find.byType(PageView))
      .controller!;

  final List<String> pageMarkers = <String>[
    AppStrings.onboardingWelcomeTo,
    AppStrings.onboardingBookHeadline,
    AppStrings.confirmed,
    AppStrings.onboardingLoyaltyRewards,
    AppStrings.onboardingDinemateTitle,
  ];

  for (int page = 0; page < pageMarkers.length; page++) {
    pageController.jumpToPage(page);
    for (int i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(
      find.text(pageMarkers[page]),
      findsWidgets,
      reason: 'marker "${pageMarkers[page]}" missing on page $page ($locale)',
    );
    expect(tester.takeException(), isNull, reason: 'page $page ($locale)');
  }

  expect(find.text(AppStrings.onboardingGetStarted), findsOneWidget);
  await tester.ensureVisible(find.text(AppStrings.onboardingGetStarted));
  await tester.tap(find.text(AppStrings.onboardingGetStarted));
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

  expect(find.byType(FavoriteCuisinesScreen), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void _registerAppDependencies({required Locale locale}) {
  Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
  Get.put(AuthRepository());
  Get.put(AuthSessionController());
  Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
  Get.put<LocationService>(_FakeLocationService());
  Get.put(LocaleController()).syncFromLocale(locale);
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
