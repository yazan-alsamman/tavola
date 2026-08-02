import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/core/utils/favorite_cuisines_preferences.dart';
import 'package:tavla/core/utils/onboarding_preferences.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/controller/sign_up_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/splash/controller/splash_controller.dart';
import 'package:tavla/features/splash/splash_assets.dart';
import 'package:tavla/features/splash/view/splash_screen.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  test(
    'splash ready duration covers brand draw plus destination prep lead',
    () {
      final Duration brandDrawEnd =
          AppDimensions.splashBrandDrawDelay +
          AppDimensions.splashBrandDrawDuration;
      expect(
        AppDimensions.splashReadyDuration,
        greaterThanOrEqualTo(
          brandDrawEnd + AppDimensions.splashDestinationPrepLead,
        ),
      );
      expect(
        AppDimensions.splashDestinationPrepLead,
        const Duration(seconds: 2),
      );
    },
  );

  testWidgets(
    'splash warms Welcome before navigation and leaves after prep lead',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      Get.testMode = true;
      Get.reset();
      Get.locale = const Locale('en');

      await OnboardingPreferences.markCompleted();
      await FavoriteCuisinesPreferences.markCompleted();
      await tester.runAsync(SplashAssets.precacheLavender);

      Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
      Get.put(AuthRepository());
      Get.put(AuthSessionController());
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
      Get.put(LocaleController()).syncFromLocale(const Locale('en'));
      AppDependency.putIfAbsent(SplashController.new);

      await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      final Duration ready = AppDimensions.splashReadyDuration;
      final Duration prepLead = AppDimensions.splashDestinationPrepLead;
      final Duration beforePrep =
          ready - prepLead - const Duration(milliseconds: 1);

      await tester.pump(beforePrep);
      expect(find.byType(SplashScreen), findsOneWidget);
      // Prep has not fired yet — Welcome deps stay cold.
      expect(Get.isRegistered<LoginController>(), isFalse);
      expect(Get.isRegistered<SignUpController>(), isFalse);

      // Cross the prep-lead boundary; destination warm-up should start.
      await tester.pump(const Duration(milliseconds: 2));
      await tester.pump(); // flush microtasks / post-frame warm work
      await tester.pump(const Duration(milliseconds: 50));

      expect(Get.isRegistered<LoginController>(), isTrue);
      expect(Get.isRegistered<SignUpController>(), isTrue);
      expect(Get.isRegistered<TaxonomyRepository>(), isTrue);

      // Finish the remaining Splash hold + any prep await.
      await tester.pump(prepLead);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(Get.currentRoute, AppRoutes.welcome);
      expect(tester.takeException(), isNull);
    },
  );
}
