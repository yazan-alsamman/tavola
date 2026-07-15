import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/controller/auth_session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.cormorantGaramond(),
      GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w500),
      GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600),
      GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w700),
    ]);
  } catch (_) {
    // Fonts fall back to cached/system faces if preload fails (e.g. hot restart).
  }
  Get.put(AuthSessionController());
  runApp(const TavolaApp());
}

class TavolaApp extends StatelessWidget {
  const TavolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: AppTheme.lightTheme,
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
