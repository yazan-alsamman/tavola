import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/locale_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (Get.isRegistered<LocaleController>()) {
        Get.find<LocaleController>().languageCode.value;
      }
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark10,
              blurRadius: AppDimensions.bottomNavShadowBlur,
              offset: const Offset(0, AppDimensions.bottomNavShadowOffsetY),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedIconTheme: const IconThemeData(
            color: AppColors.primary,
            size: AppDimensions.selectedNavIconSize,
          ),
          unselectedIconTheme: const IconThemeData(
            color: AppColors.textSecondary,
            size: AppDimensions.unselectedNavIconSize,
          ),
          selectedFontSize: AppDimensions.selectedNavFontSize,
          unselectedFontSize: AppDimensions.unselectedNavFontSize,
          selectedLabelStyle: AppTextStyles.tabLabel.copyWith(
            fontSize: AppDimensions.selectedNavFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          unselectedLabelStyle: AppTextStyles.tabLabel.copyWith(
            fontSize: AppDimensions.unselectedNavFontSize,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _navIcon(Symbols.home, selected: false),
              activeIcon: _navIcon(Symbols.home, selected: true),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Symbols.map, selected: false),
              activeIcon: _navIcon(Symbols.map, selected: true),
              label: AppStrings.map,
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Symbols.calendar_month, selected: false),
              activeIcon: _navIcon(Symbols.calendar_month, selected: true),
              label: AppStrings.booking,
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Symbols.chat_bubble, selected: false),
              activeIcon: _navIcon(Symbols.chat_bubble, selected: true),
              label: AppStrings.chat,
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Symbols.person, selected: false),
              activeIcon: _navIcon(Symbols.person, selected: true),
              label: AppStrings.profile,
            ),
          ],
        ),
      );
    });
  }

  /// Selected tabs use a filled Material Symbol so the pressed state reads
  /// clearly against the outlined idle icons.
  static Widget _navIcon(IconData icon, {required bool selected}) {
    return Icon(
      icon,
      size: selected
          ? AppDimensions.selectedNavIconSize
          : AppDimensions.unselectedNavIconSize,
      fill: selected
          ? AppDimensions.selectedNavIconFill
          : AppDimensions.unselectedNavIconFill,
      color: selected ? AppColors.primary : AppColors.textSecondary,
    );
  }
}
