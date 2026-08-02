import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/common/widgets/bottom_nav_bar.dart';
import 'package:tavla/core/constants/app_colors.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/localization/app_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('selected bottom tab icon is filled and primary-colored', (
    tester,
  ) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0,
            onTap: (int index) => tappedIndex = index,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BottomNavigationBar bar = tester.widget(
      find.byType(BottomNavigationBar),
    );
    expect(bar.currentIndex, 0);
    expect(bar.selectedItemColor, AppColors.primary);

    // Active (Home) icon uses filled Material Symbol + selected size.
    final Icon activeHome = tester.widget<Icon>(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is Icon &&
              widget.fill == AppDimensions.selectedNavIconFill &&
              widget.color == AppColors.primary,
        ),
      ),
    );
    expect(activeHome.size, AppDimensions.selectedNavIconSize);

    // Idle icons stay outlined.
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Icon &&
            widget.fill == AppDimensions.unselectedNavIconFill &&
            widget.color == AppColors.textSecondary,
      ),
      findsWidgets,
    );

    await tester.tap(find.text('Map'));
    await tester.pump();
    expect(tappedIndex, 1);
  });
}
