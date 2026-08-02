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
import 'package:material_symbols_icons/symbols.dart';

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
                            AppStrings.selectYourTable,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.selectTableTitle,
                          ),
                          const SizedBox(height: AppDimensions.regularSpacing),
                          Text(
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
                                  offset: Offset(
                                    0,
                                    AppDimensions.shadowOffsetY,
                                  ),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    AppDimensions.contentPadding,
                                    AppDimensions.contentPadding,
                                    AppDimensions.contentPadding,
                                    AppDimensions.smallSpacing,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        AppStrings.floorPlan,
                                        style: AppTextStyles
                                            .reservationSectionLabel,
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
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
                                      height: AppDimensions
                                          .floorPlanContainerHeight,
                                      width: double.infinity,
                                      child: Obx(() {
                                        if (controller.isLoadingTables.value) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: AppDimensions
                                                  .progressIndicatorStrokeWidth,
                                            ),
                                          );
                                        }

                                        final String? tablesError =
                                            controller.tablesError.value;
                                        if (tablesError != null) {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                AppDimensions.contentPadding,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    tablesError,
                                                    textAlign: TextAlign.center,
                                                    style: AppTextStyles
                                                        .selectTableSubtitle,
                                                  ),
                                                  const SizedBox(
                                                    height: AppDimensions
                                                        .regularSpacing,
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        controller.loadTables,
                                                    style: TextButton.styleFrom(
                                                      textStyle: AppTextStyles
                                                          .authLinkEmphasis,
                                                    ),
                                                    child: Text(
                                                      AppStrings.retry,
                                                      style: AppTextStyles
                                                          .authLinkEmphasis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        if (controller
                                            .floorPlanTables
                                            .isEmpty) {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                AppDimensions.contentPadding,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    AppStrings.tablesEmpty,
                                                    textAlign: TextAlign.center,
                                                    style: AppTextStyles
                                                        .selectTableSubtitle,
                                                  ),
                                                  if (controller
                                                      .canJoinWaitlist) ...[
                                                    const SizedBox(
                                                      height: AppDimensions
                                                          .regularSpacing,
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          controller
                                                              .isJoiningWaitlist
                                                              .value
                                                          ? null
                                                          : controller
                                                                .joinWaitlist,
                                                      style: TextButton.styleFrom(
                                                        textStyle: AppTextStyles
                                                            .authLinkEmphasis,
                                                      ),
                                                      child: Text(
                                                        AppStrings.waitlistJoin,
                                                        style: AppTextStyles
                                                            .authLinkEmphasis,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        return RestaurantFloorMap(
                                          controller: controller,
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                RestaurantTableDetailPanel(
                                  controller: controller,
                                ),
                              ],
                            ),
                          ),
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
                    child: Obx(() {
                      final bool busy = controller.isCreatingReservation.value;
                      final bool waitlistBusy =
                          controller.isJoiningWaitlist.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (controller.canJoinWaitlist ||
                              controller.canCancelWaitlist) ...[
                            HoverableButton(
                              child: OutlinedButton(
                                onPressed: waitlistBusy
                                    ? null
                                    : (controller.canCancelWaitlist
                                          ? controller.cancelWaitlist
                                          : controller.joinWaitlist),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryDark,
                                  side: const BorderSide(
                                    color: AppColors.border,
                                    width: AppDimensions.cardBorderWidth,
                                  ),
                                  textStyle:
                                      AppTextStyles.confirmReservationButton,
                                  padding: const EdgeInsets.symmetric(
                                    vertical:
                                        AppDimensions.buttonVerticalPadding,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                ),
                                child: waitlistBusy
                                    ? const SizedBox(
                                        width: AppDimensions.mediumIconSize,
                                        height: AppDimensions.mediumIconSize,
                                        child: CircularProgressIndicator(
                                          strokeWidth: AppDimensions
                                              .progressIndicatorStrokeWidth,
                                        ),
                                      )
                                    : Text(
                                        controller.canCancelWaitlist
                                            ? AppStrings.waitlistCancel
                                            : AppStrings.waitlistJoin,
                                        style: AppTextStyles
                                            .confirmReservationButton,
                                      ),
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.regularSpacing,
                            ),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: HoverableButton(
                              child: ElevatedButton(
                                onPressed: busy
                                    ? null
                                    : controller.confirmReservation,
                                style: AppButtonStyles.filledHover(
                                  ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: AppColors.textLight,
                                    textStyle:
                                        AppTextStyles.confirmReservationButton,
                                    padding: const EdgeInsets.symmetric(
                                      vertical:
                                          AppDimensions.buttonVerticalPadding,
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
                                          strokeWidth: AppDimensions
                                              .progressIndicatorStrokeWidth,
                                          color: AppColors.textLight,
                                        ),
                                      )
                                    : Text(
                                        AppStrings.confirmReservation,
                                        style: AppTextStyles
                                            .confirmReservationButton,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
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
