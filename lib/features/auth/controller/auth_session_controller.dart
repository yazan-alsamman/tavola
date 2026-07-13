import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

class AuthSessionController extends GetxController {
  final RxBool isGuest = false.obs;

  void enterAsGuest() {
    isGuest.value = true;
  }

  void completeSignIn() {
    isGuest.value = false;
  }

  void openLogin() {
    Get.toNamed(AppRoutes.login);
  }
}
