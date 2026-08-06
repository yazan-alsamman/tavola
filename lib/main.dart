import 'dart:async';

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
import 'core/utils/locale_preferences.dart';
import 'features/auth/controller/auth_session_controller.dart';
import 'features/auth/repository/auth_repository.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_token_reader.dart';
import 'core/network/secure_auth_token_store.dart';
import 'features/splash/controller/splash_controller.dart';
import 'features/splash/splash_assets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Locale? savedLocale = await LocalePreferences.savedLocale();
  final Locale initialLocale = savedLocale ?? const Locale('en');

  final SecureAuthTokenStore tokenStore = SecureAuthTokenStore();
  // Never await Keychain before runApp on physical iOS — SecItem* can hang
  // the platform main thread so the Dart VM Service never connects and Login
  // never becomes reachable. Splash still syncs tokens before routing.
  unawaited(tokenStore.hydrate());
  await SplashAssets.precacheLavender();

  AppDependency.putPermanent(AuthRepository());
  AppDependency.putPermanent<AuthTokenReader>(tokenStore);
  final AuthSessionController authSession = AppDependency.putPermanent(
    AuthSessionController(),
  );
  AppDependency.putPermanent<GuestModeReader>(authSession);
  AppDependency.putPermanent(
    ApiClient(
      tokenReader: tokenStore,
      guestModeReader: authSession,
      authRepository: Get.find<AuthRepository>(),
      onSessionExpired: () async {
        await Get.find<AuthSessionController>().handleSessionExpired();
      },
    ),
  );
  final LocaleController localeController = AppDependency.putPermanent(
    LocaleController(),
  );
  localeController.syncFromLocale(initialLocale);

  // Splash must be ready before the first paint — not deferred to Binding.
  AppDependency.putIfAbsent(SplashController.new);

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
      theme: AppTheme.themeFor(initialLocale),
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
      supportedLocales: const [Locale('en'), Locale('ar')],
    );
  }
}
