import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../auth/controller/auth_session_controller.dart';

class WelcomeController extends GetxController {
  void signIn() {
    Get.toNamed(AppRoutes.login);
  }

  void continueAsGuest() {
    Get.find<AuthSessionController>().enterAsGuest();
    Get.offNamed(AppRoutes.home);
  }
}
