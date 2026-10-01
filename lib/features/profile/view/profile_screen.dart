import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/tavola_refresh.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/favorite_restaurants_panel.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_explore_banner.dart';
import '../widgets/profile_identity_header.dart';
import '../widgets/profile_reservation_card.dart';
import '../widgets/profile_reservation_history_panel.dart';
import '../widgets/profile_reservations_empty_state.dart';
import '../widgets/profile_settings_panel.dart';
import '../../reservation/controller/select_restaurant_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final LocaleController localeController = Get.find<LocaleController>();

    return _ProfileReservationsRefresh(
      onOpen: controller.loadReservations,
      child: Scaffold(
        // Keep Profile layout stable while the Write Review sheet keyboard is up.
        // Otherwise the body shrinks and the history list jumps to the top.
        resizeToAvoidBottomInset: false,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Obx(() {
              // Rebuild profile copy (tabs, settings, banners) with the new locale.
              localeController.languageCode.value;
              return TavolaRefresh(
                onRefresh: controller.refreshProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HoverableCard(
                        child: Obx(() {
                          final bool loading =
                              controller.isLoadingProfile.value;
                          final bool hasCachedIdentity =
                              (controller.userProfile.value?.displayName ?? '')
                                  .trim()
                                  .isNotEmpty;
                          // Keep login username visible while `/users/me` loads.
                          if (loading && !hasCachedIdentity) {
                            return const _ProfileIdentityFallback(
                              child: SizedBox(
                                height: AppDimensions.avatarSize,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: AppDimensions
                                        .progressIndicatorStrokeWidth,
                                  ),
                                ),
                              ),
                            );
                          }

                          final String? profileError =
                              controller.profileError.value;
                          if (profileError != null && !hasCachedIdentity) {
                            return _ProfileIdentityFallback(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      profileError,
                                      style: AppTextStyles.body,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: controller.loadUserProfile,
                                    style: TextButton.styleFrom(
                                      textStyle: AppTextStyles.authLinkEmphasis,
                                    ),
                                    child: Text(
                                      AppStrings.retry,
                                      style: AppTextStyles.authLinkEmphasis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ProfileIdentityHeader(
                            name: controller.profileDisplayName,
                            phone: controller.profilePhone,
                            email: controller.userProfile.value?.email,
                          );
                        }),
                      ),
                      const SizedBox(height: AppDimensions.sectionSpacing),
                      ProfileExploreBanner(
                        onExplorePressed: controller.exploreHome,
                      ),
                      const SizedBox(height: AppDimensions.sectionSpacing),
                      Obx(
                        () => IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: controller.sections
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        start: entry.key == 0
                                            ? 0
                                            : AppDimensions
                                                      .profileSectionTabGap /
                                                  2,
                                        end:
                                            entry.key ==
                                                controller.sections.length - 1
                                            ? 0
                                            : AppDimensions
                                                      .profileSectionTabGap /
                                                  2,
                                      ),
                                      child: HoverableButton(
                                        child: GestureDetector(
                                          onTap: () => controller.selectSection(
                                            entry.key,
                                          ),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              minHeight: AppDimensions
                                                  .profileSectionTabMinHeight,
                                            ),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: AppDimensions
                                                  .profileSectionTabVerticalPadding,
                                              horizontal: AppDimensions
                                                  .profileSectionTabHorizontalPadding,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  controller
                                                          .selectedSectionIndex
                                                          .value ==
                                                      entry.key
                                                  ? AppColors.primary
                                                  : AppColors.surface,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDimensions.cardRadius,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    controller
                                                            .selectedSectionIndex
                                                            .value ==
                                                        entry.key
                                                    ? AppColors.primary
                                                    : AppColors.border,
                                                width: AppDimensions
                                                    .cardBorderWidth,
                                              ),
                                            ),
                                            child: Text(
                                              entry.value,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles
                                                  .profileSectionTabLabel
                                                  .copyWith(
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
                      ),
                      const SizedBox(height: AppDimensions.sectionSpacing),
                      Obx(() {
                        if (controller.selectedSectionIndex.value ==
                            ProfileController.lastReservationsSectionIndex) {
                          if (controller.isLoadingReservations.value &&
                              controller.reservationHistory.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.sectionSpacing,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: AppDimensions
                                      .progressIndicatorStrokeWidth,
                                ),
                              ),
                            );
                          }
                          final String? historyError =
                              controller.reservationsError.value;
                          if (historyError != null &&
                              controller.reservationHistory.isEmpty) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    historyError,
                                    style: AppTextStyles.body,
                                  ),
                                ),
                                TextButton(
                                  onPressed: controller.loadReservations,
                                  child: Text(AppStrings.retry),
                                ),
                              ],
                            );
                          }
                          // Touch reviews map so Obx rebuilds after submit/delete.
                          controller.reviewForReservation('');
                          return ProfileReservationHistoryPanel(
                            items: controller.reservationHistory,
                            reviewForReservation:
                                controller.reviewForReservation,
                            onWriteReview: controller.openWriteReview,
                            onDeleteReview: controller.deleteReviewForItem,
                            isReviewBusy: controller.isReviewBusy.value,
                          );
                        }

                        if (controller.selectedSectionIndex.value ==
                            ProfileController.favoritesSectionIndex) {
                          controller.watchFavorites();
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
                            onChanged: controller.toggleNotification,
                          );
                        }

                        if (controller.isLoadingReservations.value &&
                            controller.activeCustomerReservations.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.sectionSpacing,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    AppDimensions.progressIndicatorStrokeWidth,
                              ),
                            ),
                          );
                        }

                        final String? reservationsError =
                            controller.reservationsError.value;
                        final activeReservations =
                            controller.activeCustomerReservations;
                        if (reservationsError != null &&
                            activeReservations.isEmpty) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reservationsError,
                                  style: AppTextStyles.body,
                                ),
                              ),
                              TextButton(
                                onPressed: controller.loadReservations,
                                child: Text(AppStrings.retry),
                              ),
                            ],
                          );
                        }

                        if (activeReservations.isEmpty) {
                          return ProfileReservationsEmptyState(
                            onBookPressed: SelectRestaurantController.open,
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
                            ...activeReservations.map(
                              (reservation) => ProfileReservationCard(
                                restaurant: controller.restaurantPreviewFor(
                                  reservation,
                                ),
                                details: controller.detailsForReservation(
                                  reservation,
                                ),
                                statusLabel: reservation.customerStatusLabel,
                                reservationStatus: reservation.status,
                                onReschedule: () => controller
                                    .rescheduleReservation(reservation),
                                onCancel: () => controller.cancelReservation(
                                  reservation.reservationId,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: ProfileController.profileNavigationIndex,
          onTap: controller.handleBottomNavigation,
        ),
      ),
    );
  }
}

class _ProfileReservationsRefresh extends StatefulWidget {
  const _ProfileReservationsRefresh({
    required this.onOpen,
    required this.child,
  });

  final Future<void> Function() onOpen;
  final Widget child;

  @override
  State<_ProfileReservationsRefresh> createState() =>
      _ProfileReservationsRefreshState();
}

class _ProfileReservationsRefreshState
    extends State<_ProfileReservationsRefresh> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onOpen();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ProfileIdentityFallback extends StatelessWidget {
  const _ProfileIdentityFallback({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.contentPadding),
      child: child,
    );
  }
}
