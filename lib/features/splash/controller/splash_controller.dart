import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';

class SplashController extends GetxController {
  Timer? _navigationTimer;

  @override
  void onReady() {
    super.onReady();
    _navigationTimer = Timer(AppDimensions.splashDisplayDuration, () {
      Get.offAllNamed(AppRoutes.welcome);
    });
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    super.onClose();
  }
}
