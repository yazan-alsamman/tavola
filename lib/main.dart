import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/locale_controller.dart';
import 'core/utils/app_dependency.dart';
import 'core/utils/hot_restart_safety.dart';
import 'core/utils/locale_preferences.dart';
import 'features/auth/controller/auth_session_controller.dart';
import 'features/details/repository/restaurant_details_repository.dart';
import 'features/favorites/repository/favorites_repository.dart';
import 'features/home/repository/restaurant_repository.dart';
import 'features/map/repository/restaurant_map_repository.dart';
import 'features/profile/repository/profile_repository.dart';
import 'features/reservation/repository/reservation_availability_repository.dart';
import 'features/reservation/repository/table_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LOCKED: prevents google_fonts isolate crashes on Hot Restart.
  HotRestartSafety.apply();

  final Locale? savedLocale = await LocalePreferences.savedLocale();
  final Locale initialLocale = savedLocale ?? const Locale('en');

  AppDependency.putPermanent(AuthSessionController());
  AppDependency.putPermanent(RestaurantRepository());
  AppDependency.putPermanent(FavoritesRepository());
  AppDependency.putPermanent(RestaurantDetailsRepository());
  AppDependency.putPermanent(RestaurantMapRepository());
  AppDependency.putPermanent(ReservationAvailabilityRepository());
  AppDependency.putPermanent(TableRepository());
  AppDependency.putPermanent(ProfileRepository());
  final LocaleController localeController =
      AppDependency.putPermanent(LocaleController());
  localeController.syncFromLocale(initialLocale);

  runApp(TavolaApp(initialLocale: initialLocale));
}

class TavolaApp extends StatelessWidget {
  const TavolaApp({super.key, required this.initialLocale});

  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en'),
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
    );
  }
}
