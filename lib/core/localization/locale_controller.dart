import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../common/widgets/language_switch_overlay.dart';
import '../../features/details/controller/details_controller.dart';
import '../../features/favorites/controller/favorites_controller.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/map/controller/restaurant_map_controller.dart';
import '../../features/profile/controller/profile_controller.dart';
import '../../features/reservation/controller/reservation_controller.dart';
import '../../features/reservation/controller/select_restaurant_controller.dart';
import '../../features/reservation/controller/select_table_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/locale_preferences.dart';

class LocaleController extends GetxController {
  final RxString languageCode = 'en'.obs;
  final RxBool isSwitchingLanguage = false.obs;

  bool get isArabic => languageCode.value == 'ar';

  void syncFromLocale(Locale? locale) {
    languageCode.value = locale?.languageCode ?? 'en';
  }

  Future<void> setArabic(bool enabled) async {
    final Locale locale = Locale(enabled ? 'ar' : 'en');
    await applyLocale(locale);
  }

  Future<void> applyLocale(Locale locale) async {
    if (languageCode.value == locale.languageCode) {
      return;
    }
    if (isSwitchingLanguage.value) {
      return;
    }

    isSwitchingLanguage.value = true;
    try {
      // Cover the UI first so the locale rebuild is never visible underneath.
      Get.dialog(
        LanguageSwitchOverlay(locale: locale),
        barrierDismissible: false,
        barrierColor: AppColors.scaffold,
        useSafeArea: false,
      );
      await _waitUntilOverlayVisible();
      await Future<void>.delayed(AppDimensions.languageSwitchApplyDelay);

      languageCode.value = locale.languageCode;
      await LocalePreferences.saveLocale(locale);
      await Get.updateLocale(locale);
      _reloadLocalizedControllers();

      final Duration remainingDisplay =
          AppDimensions.languageSwitchDisplayDuration -
          AppDimensions.languageSwitchApplyDelay;
      await Future<void>.delayed(remainingDisplay);
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } finally {
      isSwitchingLanguage.value = false;
    }
  }

  Future<void> _waitUntilOverlayVisible() async {
    await SchedulerBinding.instance.endOfFrame;
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(AppDimensions.languageSwitchCoverDelay);
  }

  void _reloadLocalizedControllers() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().reloadLocalizedData();
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().reloadLocalizedData();
    }
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().reloadLocalizedData();
    }
    if (Get.isRegistered<RestaurantMapController>()) {
      Get.find<RestaurantMapController>().reloadLocalizedData();
    }
    if (Get.isRegistered<SelectRestaurantController>()) {
      Get.find<SelectRestaurantController>().reloadLocalizedData();
    }
    if (Get.isRegistered<ReservationController>()) {
      Get.find<ReservationController>().reloadLocalizedData();
    }
    if (Get.isRegistered<SelectTableController>()) {
      Get.find<SelectTableController>().reloadLocalizedData();
    }
    if (Get.isRegistered<DetailsController>()) {
      Get.find<DetailsController>().reloadLocalizedData();
    }
  }
}
