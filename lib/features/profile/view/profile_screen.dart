import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/favorite_restaurants_panel.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_payments_panel.dart';
import '../widgets/profile_reservation_card.dart';
import '../widgets/profile_settings_panel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HoverableCard(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimensions.cardBorderWidth,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppDimensions.contentPadding),
                    child: Row(
                      children: [
                        Container(
                          width: AppDimensions.avatarSize,
                          height: AppDimensions.avatarSize,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.avatarRadius,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.textLight,
                            size: AppDimensions.avatarIconSize,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.smallSpacing),
                        Expanded(
                          child: Text(
                            AppStrings.profileUserName,
                            style: AppTextStyles.profileName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                HoverableCard(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppDimensions.contentPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.partnerOwnerAccess,
                                style: AppTextStyles.partnerTitle,
                              ),
                              const SizedBox(
                                height: AppDimensions.smallSpacing,
                              ),
                              Text(
                                AppStrings.partnerOwnerDescription,
                                style: AppTextStyles.partnerBody,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.smallSpacing),
                        Flexible(
                          child: HoverableButton(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: AppButtonStyles.filledHover(
                                ElevatedButton.styleFrom(
                                  textStyle: AppTextStyles.buttonLabel(context),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppDimensions.buttonHorizontalPadding,
                                    vertical:
                                        AppDimensions.buttonVerticalPadding,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                ),
                                idleBackground: AppColors.success,
                                idleForeground: AppColors.primaryDark,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(AppStrings.launchBoard),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: controller.sections
                        .asMap()
                        .entries
                        .map(
                          (entry) => Expanded(
                            child: HoverableButton(
                              child: GestureDetector(
                                onTap: () =>
                                    controller.selectSection(entry.key),
                                child: Container(
                                  margin: EdgeInsetsDirectional.only(
                                    start: entry.key == 0
                                        ? 0
                                        : AppDimensions.smallSpacing / 2,
                                    end: entry.key ==
                                            controller.sections.length - 1
                                        ? 0
                                        : AppDimensions.smallSpacing / 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppDimensions.tabVerticalPadding,
                                    horizontal:
                                        AppDimensions.tabHorizontalPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        controller.selectedSectionIndex.value ==
                                            entry.key
                                        ? AppColors.primary
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      entry.value,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.tabLabel.copyWith(
                                        color:
                                            controller
                                                    .selectedSectionIndex
                                                    .value ==
                                                entry.key
                                            ? AppColors.textLight
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Obx(() {
                  if (controller.selectedSectionIndex.value ==
                      ProfileController.paymentsSectionIndex) {
                    return ProfilePaymentsPanel(
                      transactions: controller.paymentTransactions,
                    );
                  }

                  if (controller.selectedSectionIndex.value ==
                      ProfileController.favoritesSectionIndex) {
                    final restaurants = controller.favoriteRestaurants;
                    return FavoriteRestaurantsPanel(
                      restaurants: restaurants,
                      favoriteValues: restaurants
                          .map(
                            (restaurant) =>
                                controller.isFavorite(restaurant.id),
                          )
                          .toList(),
                      onFavoritePressed: controller.toggleFavorite,
                      onRestaurantTap: controller.openDetails,
                    );
                  }

                  if (controller.selectedSectionIndex.value ==
                      ProfileController.settingsSectionIndex) {
                    return ProfileSettingsPanel(
                      options: controller.notificationOptions,
                      values: controller.notificationSettings.toList(),
                      onChanged: controller.toggleNotification,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.activeDiningPlacements,
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      ...controller.featuredRestaurants.map(
                        (restaurant) => ProfileReservationCard(
                          restaurant: restaurant,
                          details: controller.reservationDetails,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: ProfileController.profileNavigationIndex,
        onTap: controller.handleBottomNavigation,
      ),
    );
  }
}
