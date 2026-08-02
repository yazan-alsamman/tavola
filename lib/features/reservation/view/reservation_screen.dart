import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/reservation_controller.dart';
import '../widgets/reservation_calendar_panel.dart';
import '../widgets/reservation_diners_panel.dart';
import '../widgets/reservation_duration_panel.dart';
import '../widgets/reservation_time_slots_panel.dart';
import 'package:material_symbols_icons/symbols.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReservationController controller = Get.find<ReservationController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.pagePadding),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: Get.back,
                        icon: const Icon(
                          Symbols.arrow_back_ios_new,
                          color: AppColors.primary,
                          size: AppDimensions.mediumIconSize,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.smallSpacing),
                    Text(
                      AppStrings.reservationPreferences,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.reservationPreferencesTitle,
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    Text(
                      AppStrings.reservationPreferencesSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.reservationPreferencesSubtitle,
                    ),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    ReservationDinersPanel(controller: controller),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    ReservationTimeSlotsPanel(controller: controller),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    ReservationDurationPanel(controller: controller),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    ReservationCalendarPanel(controller: controller),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppDimensions.pagePadding,
                0,
                AppDimensions.pagePadding,
                AppDimensions.pagePadding,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final bool busy =
                      controller.isSearchingAvailability.value ||
                      controller.isResolvingBranch.value;
                  return HoverableButton(
                    child: ElevatedButton(
                      onPressed: busy ? null : controller.proceedToSelectTable,
                      style: AppButtonStyles.filledHover(
                        ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.textLight,
                          textStyle: AppTextStyles.reservationNextButton,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.buttonVerticalPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                        ),
                        idleBackground: AppColors.primaryDark,
                      ),
                      child: busy
                          ? const SizedBox(
                              width: AppDimensions.mediumIconSize,
                              height: AppDimensions.mediumIconSize,
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    AppDimensions.progressIndicatorStrokeWidth,
                                color: AppColors.textLight,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.nextSelectTable,
                                  style: AppTextStyles.reservationNextButton,
                                ),
                                const SizedBox(
                                  width: AppDimensions.smallSpacing,
                                ),
                                const Icon(
                                  Symbols.arrow_forward_ios,
                                  color: AppColors.textLight,
                                  size: AppDimensions.smallIconSize,
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
