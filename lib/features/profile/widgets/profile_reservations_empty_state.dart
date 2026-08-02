import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Premium empty state for the profile Reservations tab.
class ProfileReservationsEmptyState extends StatelessWidget {
  const ProfileReservationsEmptyState({super.key, this.onBookPressed});

  final VoidCallback? onBookPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.activeDiningPlacements,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppDimensions.regularSpacing),
        HoverableCard(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(
                    alpha: AppDimensions.reservationHistoryCardElevationOpacity,
                  ),
                  blurRadius: AppDimensions.reservationHistoryCardElevationBlur,
                  offset: const Offset(
                    0,
                    AppDimensions.reservationHistoryCardElevationY,
                  ),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            AppColors.secondaryLight,
                            AppColors.accent,
                            AppColors.secondary,
                            AppColors.accent,
                          ],
                          stops: [0.0, 0.35, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: -AppDimensions.reservationHistoryOrbSize * 0.4,
                    end: -AppDimensions.reservationHistoryOrbSize * 0.25,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: AppDimensions.reservationHistoryCardBlurSigma,
                        sigmaY: AppDimensions.reservationHistoryCardBlurSigma,
                      ),
                      child: Container(
                        width: AppDimensions.reservationHistoryOrbSize,
                        height: AppDimensions.reservationHistoryOrbSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(
                            alpha:
                                AppDimensions.reservationHistoryAccentOrbAlpha,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: -AppDimensions.reservationHistoryOrbSize * 0.45,
                    start: -AppDimensions.reservationHistoryOrbSize * 0.3,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: AppDimensions.reservationHistoryCardBlurSigma,
                        sigmaY: AppDimensions.reservationHistoryCardBlurSigma,
                      ),
                      child: Container(
                        width: AppDimensions.reservationHistoryOrbSize * 0.9,
                        height: AppDimensions.reservationHistoryOrbSize * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryDark.withValues(
                            alpha:
                                AppDimensions.reservationHistoryPrimaryOrbAlpha,
                          ),
                        ),
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: AppDimensions.reservationHistoryCardBlurSigma,
                      sigmaY: AppDimensions.reservationHistoryCardBlurSigma,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.contentPadding,
                        vertical:
                            AppDimensions.sectionSpacing +
                            AppDimensions.smallSpacing,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            AppColors.surface.withValues(
                              alpha: AppDimensions
                                  .reservationHistoryGlassSurfaceAlpha,
                            ),
                            AppColors.accent.withValues(
                              alpha: AppDimensions
                                  .reservationHistoryGlassAccentAlpha,
                            ),
                            AppColors.primaryDark.withValues(
                              alpha: AppDimensions
                                  .reservationHistoryGlassPrimaryAlpha,
                            ),
                          ],
                          stops: const [0.0, 0.65, 1.0],
                        ),
                        border: Border.all(
                          color: AppColors.primaryDark.withValues(
                            alpha: AppDimensions.reservationHistoryBorderAlpha,
                          ),
                          width: AppDimensions.cardBorderWidth,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: AppDimensions
                                .profileReservationsEmptyIconContainer,
                            height: AppDimensions
                                .profileReservationsEmptyIconContainer,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(
                                alpha: AppDimensions
                                    .reservationHistorySoftOrbAlpha,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.reservationHistoryImageRadius,
                              ),
                              border: Border.all(
                                color: AppColors.primaryDark.withValues(
                                  alpha: AppDimensions
                                      .reservationHistoryBorderAlpha,
                                ),
                                width: AppDimensions.cardBorderWidth,
                              ),
                            ),
                            child: const Icon(
                              Symbols.event_busy,
                              color: AppColors.primaryDark,
                              size: AppDimensions
                                  .profileReservationsEmptyIconSize,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.regularSpacing),
                          Text(
                            AppStrings.noActiveReservationsTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.profileReservationsEmptyTitle,
                          ),
                          const SizedBox(height: AppDimensions.smallSpacing),
                          Text(
                            AppStrings.noActiveReservationsDescription,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.profileReservationsEmptyBody,
                          ),
                          if (onBookPressed != null) ...[
                            const SizedBox(
                              height: AppDimensions.regularSpacing,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: HoverableButton(
                                child: ElevatedButton(
                                  onPressed: onBookPressed,
                                  style: AppButtonStyles.filledHover(
                                    ElevatedButton.styleFrom(
                                      textStyle:
                                          AppTextStyles.exploreBannerButton,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions
                                            .buttonHorizontalPadding,
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
                                    idleForeground: AppColors.textLight,
                                  ),
                                  child: Text(
                                    AppStrings.bookATable,
                                    style: AppTextStyles.exploreBannerButton,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
