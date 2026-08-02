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
import '../../app/theme/app_theme.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/locale_preferences.dart';

class LocaleController extends GetxController {
  /// Canonical app language codes — the single source for locale literals.
  static const String englishCode = 'en';
  static const String arabicCode = 'ar';

  final RxString languageCode = englishCode.obs;
  final RxBool isSwitchingLanguage = false.obs;

  bool get isArabic => languageCode.value == arabicCode;

  void syncFromLocale(Locale? locale) {
    languageCode.value = locale?.languageCode ?? englishCode;
  }

  Future<void> setArabic(bool enabled) async {
    final Locale locale = Locale(enabled ? arabicCode : englishCode);
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
    bool openedOverlay = false;
    try {
      // Cover the UI first so the locale rebuild is never visible underneath.
      Get.dialog(
        LanguageSwitchOverlay(locale: locale),
        barrierDismissible: false,
        barrierColor: AppColors.scaffold,
        useSafeArea: false,
      );
      openedOverlay = true;

      await _waitUntilOverlayVisible();
      await Future<void>.delayed(AppDimensions.languageSwitchApplyDelay);

      await LocalePreferences.saveLocale(locale);
      await Get.updateLocale(locale);
      // Notify listeners only after Get.locale / .tr are on the new language.
      languageCode.value = locale.languageCode;
      _reloadLocalizedControllers();
      Get.changeTheme(AppTheme.themeFor(locale));

      final Duration remainingDisplay =
          AppDimensions.languageSwitchDisplayDuration -
          AppDimensions.languageSwitchApplyDelay;
      await Future<void>.delayed(remainingDisplay);
    } finally {
      if (openedOverlay) {
        _dismissLanguageOverlay();
      }
      isSwitchingLanguage.value = false;
    }
  }

  Future<void> _waitUntilOverlayVisible() async {
    await SchedulerBinding.instance.endOfFrame;
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(AppDimensions.languageSwitchCoverDelay);
  }

  /// Closes only a still-open GetX dialog.
  ///
  /// Never use `Navigator.pop(rootNavigator: true)` here: after
  /// `Get.changeTheme` / `updateLocale` the dialog route may already be gone
  /// while `isDialogOpen` is briefly stale — a root pop then removes Profile
  /// (or Home) and looks like a crash on en↔ar switch.
  void _dismissLanguageOverlay() {
    try {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (_) {
      // Overlay already gone / navigator mid-transition.
    }
  }

  /// Refreshes live feature controllers after locale/theme swap.
  ///
  /// Skips closed / late-removed route controllers (`putFresh`).
  void _reloadLocalizedControllers() {
    _reloadIfAlive<HomeController>(
      (HomeController controller) => controller.reloadLocalizedData(),
    );
    _reloadIfAlive<ProfileController>(
      (ProfileController controller) => controller.reloadLocalizedData(),
    );
    _reloadIfAlive<FavoritesController>(
      (FavoritesController controller) => controller.reloadLocalizedData(),
    );
    _reloadIfAlive<RestaurantMapController>(
      (RestaurantMapController controller) => controller.reloadLocalizedData(),
    );
    _reloadIfAlive<SelectRestaurantController>(
      (SelectRestaurantController controller) =>
          controller.reloadLocalizedData(),
    );
    _reloadIfAlive<ReservationController>(
      (ReservationController controller) => controller.reloadLocalizedData(),
    );
    _reloadIfAlive<SelectTableController>(
      (SelectTableController controller) => controller.reloadLocalizedData(),
    );
    _reloadIfAlive<DetailsController>(
      (DetailsController controller) => controller.reloadLocalizedData(),
    );
  }

  void _reloadIfAlive<T extends GetxController>(void Function(T) reload) {
    if (!Get.isRegistered<T>()) {
      return;
    }
    final T controller = Get.find<T>();
    if (controller.isClosed) {
      return;
    }
    try {
      reload(controller);
    } catch (_) {
      // Stale GetBuilder listeners / lateRemove races must not abort locale swap.
    }
  }
}
