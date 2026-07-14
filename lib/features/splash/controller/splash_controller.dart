import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/favorite_cuisines_preferences.dart';
import '../../../core/utils/onboarding_preferences.dart';

class SplashController extends GetxController {
  Timer? _navigationTimer;

  @override
  void onReady() {
    super.onReady();
    _navigationTimer = Timer(AppDimensions.splashDisplayDuration, () {
      _navigateAfterSplash();
    });
  }

  Future<void> _navigateAfterSplash() async {
    final bool onboardingCompleted = await OnboardingPreferences.isCompleted();
    if (!onboardingCompleted) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final bool cuisinesCompleted =
        await FavoriteCuisinesPreferences.isCompleted();
    if (!cuisinesCompleted) {
      Get.offAllNamed(AppRoutes.favoriteCuisines);
      return;
    }

    Get.offAllNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    super.onClose();
  }
}
