import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/onboarding_preferences.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../reservation/controller/select_table_controller.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _ensurePreviewControllers();
  }

  void _ensurePreviewControllers() {
    final ReservationController reservation = Get.isRegistered<ReservationController>()
        ? Get.find<ReservationController>()
        : Get.put(ReservationController());
    final SelectTableController selectTable = Get.isRegistered<SelectTableController>()
        ? Get.find<SelectTableController>()
        : Get.put(SelectTableController());

    reservation.selectTimeSlot(1);
    selectTable.selectTable(
      selectTable.floorPlanTables.firstWhere(
        (table) => table.id == AppStrings.tableIdW1,
      ),
    );
  }

  ReservationController get previewReservationController =>
      Get.find<ReservationController>();

  SelectTableController get previewSelectTableController =>
      Get.find<SelectTableController>();

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> copyConfirmationCode() async {
    await Clipboard.setData(
      const ClipboardData(text: AppStrings.confirmationReferenceCode),
    );
  }

  Future<void> completeOnboarding() async {
    await OnboardingPreferences.markCompleted();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(AppRoutes.favoriteCuisines);
    });
  }

  bool get isLastPage =>
      currentPage.value == AppDimensions.onboardingPageCount - 1;

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
