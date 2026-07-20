import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/common/widgets/app_safe_image.dart';
import 'package:tavla/common/widgets/restaurant_card.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/details/repository/restaurant_details_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/features/home/repository/restaurant_repository.dart';
import 'package:tavla/features/map/repository/restaurant_map_repository.dart';
import 'package:tavla/features/onboarding/view/onboarding_screen.dart';
import 'package:tavla/features/profile/repository/profile_repository.dart';
import 'package:tavla/features/reservation/repository/reservation_availability_repository.dart';
import 'package:tavla/features/reservation/repository/table_repository.dart';
import 'package:tavla/features/splash/view/splash_screen.dart';
import 'package:tavla/features/splash/widgets/splash_tavola_mark.dart';
import 'package:tavla/features/welcome/view/welcome_screen.dart';
import 'package:tavla/main.dart';

void _registerAppDependencies() {
  Get.put(AuthSessionController());
  Get.put(RestaurantRepository());
  Get.put(FavoritesRepository());
  Get.put(RestaurantDetailsRepository());
  Get.put(RestaurantMapRepository());
  Get.put(ReservationAvailabilityRepository());
  Get.put(TableRepository());
  Get.put(ProfileRepository());
  Get.put(LocaleController()).syncFromLocale(const Locale('en'));
}

Future<void> _prepareApp(
  WidgetTester tester, {
  required Map<String, Object> preferences,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();

  Get.reset();
  Get.testMode = true;
  Get.locale = const Locale('en');
  SharedPreferences.setMockInitialValues(preferences);
  _registerAppDependencies();

  await tester.pumpWidget(const TavolaApp(initialLocale: Locale('en')));
  await tester.pump();
}

Future<void> _advancePastSplash(WidgetTester tester) async {
  await tester.pump(AppDimensions.splashDisplayDuration);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets(
    'Splash follows shared-preferences flow and never jumps to home',
    (WidgetTester tester) async {
      // First launch: Splash -> Onboarding
      await _prepareApp(tester, preferences: <String, Object>{});

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(SplashTavolaMark), findsOneWidget);

      await _advancePastSplash(tester);

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text(AppStrings.onboardingWelcomeTo), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
      expect(find.text(AppStrings.home), findsNothing);

      // Returning user: Splash -> Welcome
      await _prepareApp(
        tester,
        preferences: <String, Object>{
          AppStrings.onboardingCompletedKey: true,
          AppStrings.favoriteCuisinesCompletedKey: true,
        },
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      await _advancePastSplash(tester);

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text(AppStrings.loginSignUp), findsOneWidget);
      expect(find.text(AppStrings.continueAsGuest), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text(AppStrings.home), findsNothing);
    },
  );

  testWidgets(
    'Restaurant card shows icon fallback when image URL is invalid',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RestaurantCard(
              restaurant: RestaurantModel(
                id: AppStrings.restaurantIdOne,
                name: AppStrings.saffronHouse,
                cuisine: AppStrings.italian,
                occasion: AppStrings.dinner,
                description: AppStrings.saffronDescription,
                imageUrl: 'assets/images/missing_image.png',
                location: AppStrings.oldTown,
                availabilityLabel: AppStrings.openNow,
                isAvailable: true,
              ),
              isFavorite: false,
              onFavoritePressed: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(AppSafeImage), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
      expect(find.text(AppStrings.saffronHouse), findsOneWidget);
    },
  );
}
