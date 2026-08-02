import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/perf/frame_timing_collector.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/favorite_cuisines_preferences.dart';
import 'package:tavla/core/utils/onboarding_preferences.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/auth/view/sign_up_screen.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

/// Profile-mode frame timing for Welcome → Login / Guest / SignUp.
///
/// Run:
/// ```
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/auth_nav_perf_test.dart \
///   --profile -d macos
/// ```
void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets('measure Welcome Login / Guest / SignUp navigation frames', (
    tester,
  ) async {
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
    Get.put<LocationService>(_FakeLocationService(), permanent: true);

    await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
    await tester.pumpAndSettle(AppDimensions.splashDisplayDuration);
    await tester.pump(const Duration(milliseconds: 500));

    Get.offAllNamed(AppRoutes.welcome);
    await tester.pumpAndSettle();
    // Allow Welcome idle warmup + shine animation to settle one vsync budget.
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // ---------- LOGIN ----------
    final FrameTimingCollector loginCollector = FrameTimingCollector()..start();
    await tester.tap(find.text(AppStrings.loginSignUp));
    await tester.pump(); // tap frame
    await tester.pump(AppDimensions.hoverDuration); // transition + hover anim
    await tester.pump(const Duration(milliseconds: 400));
    loginCollector.stop();
    final FrameTimingReport loginReport = loginCollector.report(
      label: 'welcome_to_login',
    );
    loginReport.dump();
    expect(find.byType(LoginScreen), findsOneWidget);

    // ---------- SIGN UP (from Login) ----------
    final FrameTimingCollector signUpCollector = FrameTimingCollector()
      ..start();
    await tester.tap(find.text(AppStrings.signUp));
    await tester.pump();
    await tester.pump(AppDimensions.hoverDuration);
    await tester.pump(const Duration(milliseconds: 400));
    signUpCollector.stop();
    final FrameTimingReport signUpReport = signUpCollector.report(
      label: 'login_to_sign_up',
    );
    signUpReport.dump();
    expect(find.byType(SignUpScreen), findsOneWidget);

    // Back to Welcome for Guest measurement.
    Get.offAllNamed(AppRoutes.welcome);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // ---------- GUEST ----------
    final FrameTimingCollector guestCollector = FrameTimingCollector()..start();
    await tester.tap(find.text(AppStrings.continueAsGuest));
    await tester.pump();
    await tester.pump(AppDimensions.hoverDuration);
    await tester.pump(const Duration(milliseconds: 500));
    guestCollector.stop();
    final FrameTimingReport guestReport = guestCollector.report(
      label: 'welcome_to_home_guest',
    );
    guestReport.dump();
    expect(find.byType(HomeScreen), findsOneWidget);

    // Expose reports to the flutter drive response / timeline.
    binding.reportData = <String, dynamic>{
      'welcome_to_login': loginReport.toJson(),
      'login_to_sign_up': signUpReport.toJson(),
      'welcome_to_home_guest': guestReport.toJson(),
    };
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
