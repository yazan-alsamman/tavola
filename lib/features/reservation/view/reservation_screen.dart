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
                          Icons.arrow_back_ios_new_rounded,
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
                child: HoverableButton(
                  child: ElevatedButton(
                    onPressed: controller.proceedToSelectTable,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppStrings.nextSelectTable),
                        const SizedBox(width: AppDimensions.smallSpacing),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textLight,
                          size: AppDimensions.smallIconSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
