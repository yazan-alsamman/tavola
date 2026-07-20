import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/core/constants/app_fonts.dart';
import 'package:tavla/core/utils/hot_restart_safety.dart';
import 'package:tavla/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('local Cormorant fonts and app boot without google_fonts',
      (tester) async {
    HotRestartSafety.apply();

    expect(AppFonts.cormorantGaramondFamily, 'CormorantGaramond');
    expect(
      AppFonts.cormorantGaramond(fontWeight: FontWeight.w600).fontFamily,
      AppFonts.cormorantGaramondFamily,
    );

    await tester.pumpWidget(
      const TavolaApp(initialLocale: Locale('en')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
