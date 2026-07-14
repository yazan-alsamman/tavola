import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/onboarding_preferences.dart';
import '../model/onboarding_date_chip.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  static const List<OnboardingDateChip> dateChips = [
    OnboardingDateChip(
      weekday: AppStrings.onboardingDayOneWeekday,
      dayNumber: AppStrings.onboardingDayOneNumber,
      label: AppStrings.onboardingToday,
    ),
    OnboardingDateChip(
      weekday: AppStrings.onboardingDayTwoWeekday,
      dayNumber: AppStrings.onboardingDayTwoNumber,
      label: AppStrings.onboardingTomorrow,
    ),
    OnboardingDateChip(
      weekday: AppStrings.onboardingDayThreeWeekday,
      dayNumber: AppStrings.onboardingDayThreeNumber,
      label: AppStrings.onboardingMonthAug,
    ),
    OnboardingDateChip(
      weekday: AppStrings.onboardingDayFourWeekday,
      dayNumber: AppStrings.onboardingDayFourNumber,
      label: AppStrings.onboardingMonthAug,
    ),
  ];

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
    super.onClose();
  }
}
