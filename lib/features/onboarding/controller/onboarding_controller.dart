import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/onboarding_preferences.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../reservation/controller/select_table_controller.dart';

/// Owns onboarding page state, preview-table seed, and completion routing.
class OnboardingController extends GetxController {
  late final PageController pageController;
  final RxInt currentPage = 0.obs;

  bool get isLastPage =>
      currentPage.value == AppDimensions.onboardingPageCount - 1;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _ensurePreviewControllers();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> completeOnboarding() async {
    await OnboardingPreferences.markCompleted();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(AppRoutes.favoriteCuisines);
    });
  }

  void _ensurePreviewControllers() {
    final ReservationController reservation =
        Get.isRegistered<ReservationController>()
        ? Get.find<ReservationController>()
        : Get.put(ReservationController());
    final SelectTableController selectTable =
        Get.isRegistered<SelectTableController>()
        ? Get.find<SelectTableController>()
        : Get.put(SelectTableController());

    reservation.selectTimeSlot(1);
    _selectOnboardingPreviewTable(selectTable);
    if (selectTable.floorPlanTables.isEmpty) {
      selectTable.loadTables().then((_) {
        if (isClosed) {
          return;
        }
        _selectOnboardingPreviewTable(selectTable);
      });
    }
  }

  void _selectOnboardingPreviewTable(SelectTableController selectTable) {
    if (selectTable.floorPlanTables.isEmpty) {
      return;
    }
    final preferred = selectTable.floorPlanTables.firstWhereOrNull(
      (table) => table.id == AppStrings.tableIdW1,
    );
    selectTable.selectTable(preferred ?? selectTable.floorPlanTables.first);
  }

  @override
  void onClose() {
    pageController.dispose();
    if (Get.isRegistered<SelectTableController>()) {
      Get.delete<SelectTableController>(force: true);
    }
    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }
    super.onClose();
  }
}
