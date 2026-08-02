import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/common/widgets/bottom_nav_bar.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/features/concierge/controller/concierge_controller.dart';
import 'package:tavla/features/concierge/view/concierge_screen.dart';
import 'package:tavla/features/concierge/widgets/concierge_composer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  Future<void> pumpConcierge(WidgetTester tester) async {
    Get.testMode = true;
    Get.put(LocaleController()).syncFromLocale(const Locale('en'));
    Get.put(ConciergeController());

    await tester.pumpWidget(
      GetMaterialApp(
        home: const ConciergeScreen(),
        translations: _EmptyTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      ),
    );
    await tester.pump();
  }

  testWidgets('composer docks above keyboard without empty gap or bottom nav', (
    tester,
  ) async {
    await pumpConcierge(tester);

    expect(find.byType(ConciergeComposer), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);

    // FakeViewPadding is physical pixels; MediaQuery converts via DPR.
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();

    // Bottom nav must hide while typing — otherwise it sits between field
    // and keyboard and recreates the empty gap.
    expect(find.byType(BottomNavBar), findsNothing);
    expect(find.byType(ConciergeComposer), findsOneWidget);

    final BuildContext scaffoldContext = tester.element(find.byType(Scaffold));
    final MediaQueryData mediaQuery = MediaQuery.of(scaffoldContext);
    expect(mediaQuery.viewInsets.bottom, greaterThan(0));

    final Rect scaffoldRect = tester.getRect(find.byType(Scaffold));
    final Rect composerRect = tester.getRect(find.byType(ConciergeComposer));
    final double keyboardTop =
        scaffoldRect.bottom - mediaQuery.viewInsets.bottom;

    // Composer must sit flush on the keyboard top — not floated mid-screen
    // with a large empty gap (the previous double-viewInsets bug).
    expect(
      composerRect.bottom,
      closeTo(keyboardTop, AppDimensions.pagePadding),
      reason:
          'Composer bottom (${composerRect.bottom}) must dock to keyboard '
          'top ($keyboardTop), not leave a white gap above the keyboard',
    );
    expect(
      composerRect.top,
      greaterThan(scaffoldRect.top + AppDimensions.sectionSpacing),
      reason: 'Composer must not be pinned under the header',
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.conciergeMessageHint), findsOneWidget);
  });

  testWidgets('bottom nav returns when keyboard closes', (tester) async {
    await pumpConcierge(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    expect(find.byType(BottomNavBar), findsNothing);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();
    expect(find.byType(BottomNavBar), findsOneWidget);

    final Rect scaffoldRect = tester.getRect(find.byType(Scaffold));
    final Rect composerRect = tester.getRect(find.byType(ConciergeComposer));
    expect(composerRect.bottom, lessThan(scaffoldRect.bottom));
    expect(
      composerRect.top,
      greaterThan(scaffoldRect.height * 0.5),
      reason: 'Composer must stay in the lower half when keyboard is closed',
    );
  });
}

class _EmptyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => <String, Map<String, String>>{
    'en': <String, String>{},
  };
}
