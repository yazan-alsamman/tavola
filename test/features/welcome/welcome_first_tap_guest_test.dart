import 'dart:async';

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
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/welcome/view/guest_transition_screen.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
    Get.testMode = true;
  });

  testWidgets(
    'first CONTINUE AS GUEST tap reaches Home before Keychain clear',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      Get.testMode = true;
      Get.reset();
      Get.locale = const Locale('en');

      await OnboardingPreferences.markCompleted();
      await FavoriteCuisinesPreferences.markCompleted();

      final Completer<void> clearGate = Completer<void>();
      Get.put<AuthTokenReader>(_GatedAuthTokenSession(clearGate));
      Get.put(AuthRepository());
      Get.put(AuthSessionController());
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
      Get.put(LocaleController()).syncFromLocale(const Locale('en'));
      Get.put<LocationService>(_FakeLocationService(), permanent: true);

      await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
      await tester.pump();

      Get.offAllNamed(AppRoutes.welcome);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(WelcomeScreen), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(Get.isRegistered<FavoritesRepository>(), isFalse);
      expect(Get.isRegistered<TaxonomyRepository>(), isTrue);

      await tester.tap(find.text(AppStrings.continueAsGuest));
      await tester.pump();
      await tester.pump(AppDimensions.welcomeTransitionEnterDuration);
      expect(
        find.byType(GuestTransitionScreen).evaluate().isNotEmpty ||
            find.byType(HomeScreen).evaluate().isNotEmpty,
        isTrue,
      );
      await tester.pump(AppDimensions.welcomeTransitionMinDisplayDuration);
      await tester.pump(AppDimensions.welcomeTransitionFadeDuration);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(GuestTransitionScreen), findsNothing);
      expect(Get.isRegistered<HomeController>(), isTrue);
      expect(Get.find<AuthSessionController>().isGuest.value, isTrue);
      expect(clearGate.isCompleted, isFalse);

      clearGate.complete();
      await tester.pump(AppDimensions.secureStorageTimeout);
      await tester.pump(AppDimensions.apiConnectTimeout);
      await tester.pump();
      for (int i = 0; i < 20; i++) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));
      }
      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );
}

class _GatedAuthTokenSession implements AuthTokenSession {
  _GatedAuthTokenSession(this._clearGate);

  final Completer<void> _clearGate;

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}

  @override
  Future<void> clearSessionTokens() => _clearGate.future;
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
