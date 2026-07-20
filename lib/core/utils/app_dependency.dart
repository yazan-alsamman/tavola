import 'package:get/get.dart';

/// Safe GetX registration helpers for hot restart / route re-entry.
class AppDependency {
  AppDependency._();

  /// Registers a long-lived app service, replacing any stale Hot Restart leftover.
  static T putPermanent<T extends Object>(T dependency) {
    if (Get.isRegistered<T>()) {
      try {
        Get.delete<T>(force: true);
      } catch (_) {
        // Ignore dispose races during Hot Restart.
      }
    }
    return Get.put<T>(dependency, permanent: true);
  }

  /// Deletes any existing instance, then puts a fresh one (route controllers).
  static T putFresh<T extends Object>(T Function() create) {
    if (Get.isRegistered<T>()) {
      try {
        Get.delete<T>(force: true);
      } catch (_) {
        // Ignore dispose races during Hot Restart / rapid navigation.
      }
    }
    return Get.put<T>(create());
  }
}
