import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/select_table_controller.dart';
import '../widgets/restaurant_floor_map.dart';
import '../widgets/reservation_confirmation_overlay.dart';
import '../widgets/restaurant_table_detail_panel.dart';

class SelectTableScreen extends StatelessWidget {
  const SelectTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SelectTableController controller = Get.find<SelectTableController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Obx(
        () => Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.pagePadding),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
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
                          const Text(
                            AppStrings.selectYourTable,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.selectTableTitle,
                          ),
                          const SizedBox(height: AppDimensions.regularSpacing),
                          const Text(
                            AppStrings.selectTableSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.selectTableSubtitle,
                          ),
                          const SizedBox(height: AppDimensions.sectionSpacing),
                          Container(
                            width: double.infinity,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.cardRadius,
                              ),
                              border: Border.all(
                                color: AppColors.border,
                                width: AppDimensions.cardBorderWidth,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.primaryDark10,
                                  blurRadius: AppDimensions.shadowBlur,
                                  offset: Offset(0, AppDimensions.shadowOffsetY),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppDimensions.contentPadding,
                                    AppDimensions.contentPadding,
                                    AppDimensions.contentPadding,
                                    AppDimensions.smallSpacing,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        AppStrings.floorPlan,
                                        style:
                                            AppTextStyles.reservationSectionLabel,
                                      ),
                                      const SizedBox(
                                        width: AppDimensions.smallSpacing,
                                      ),
                                      Expanded(
                                        child: Text(
                                          AppStrings.restaurantMapHint,
                                          textAlign: TextAlign.end,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.floorPlanMapHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppDimensions.smallSpacing,
                                    0,
                                    AppDimensions.smallSpacing,
                                    AppDimensions.smallSpacing,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.regularSpacing,
                                    ),
                                    child: SizedBox(
                                      height:
                                          AppDimensions.floorPlanContainerHeight,
                                      width: double.infinity,
                                      child: RestaurantFloorMap(
                                        controller: controller,
                                      ),
                                    ),
                                  ),
                                ),
                                RestaurantTableDetailPanel(controller: controller),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sectionSpacing),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pagePadding,
                      0,
                      AppDimensions.pagePadding,
                      AppDimensions.pagePadding,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: HoverableButton(
                        child: ElevatedButton(
                          onPressed: controller.confirmReservation,
                          style: AppButtonStyles.filledHover(
                            ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: AppColors.textLight,
                              textStyle: AppTextStyles.confirmReservationButton,
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
                          child: const Text(AppStrings.confirmReservation),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.showConfirmation.value &&
                controller.confirmation.value != null)
              ReservationConfirmationOverlay(
                confirmation: controller.confirmation.value!,
                onDismiss: controller.dismissConfirmation,
              ),
          ],
        ),
      ),
    );
  }
}
