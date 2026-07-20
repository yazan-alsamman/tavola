import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Frosted primaryDark glass container for premium onboarding previews.
class OnboardingGlassShell extends StatelessWidget {
  const OnboardingGlassShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingSectionRadius,
        ),
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
                      AppColors.primaryDark,
                      AppColors.primaryDark75,
                      AppColors.primary,
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: -AppDimensions.onboardingConciergeGlowOrbSize * 0.35,
              end: -AppDimensions.onboardingConciergeGlowOrbSize * 0.25,
              child: OnboardingGlassGlowOrb(
                size: AppDimensions.onboardingConciergeGlowOrbSize,
                color: AppColors.accent.withValues(alpha: 0.34),
              ),
            ),
            PositionedDirectional(
              bottom: -AppDimensions.onboardingConciergeGlowOrbSize * 0.2,
              start: -AppDimensions.onboardingConciergeGlowOrbSize * 0.15,
              child: OnboardingGlassGlowOrb(
                size: AppDimensions.onboardingConciergeGlowOrbSize * 0.72,
                color: AppColors.secondary.withValues(alpha: 0.28),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDimensions.onboardingConciergeGlassBlurSigma,
                sigmaY: AppDimensions.onboardingConciergeGlassBlurSigma,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppDimensions.onboardingSectionPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.72),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.28),
                    width: AppDimensions.cardBorderWidth,
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingGlassGlowOrb extends StatelessWidget {
  const OnboardingGlassGlowOrb({
    required this.size,
    required this.color,
    super.key,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: AppDimensions.onboardingConciergeGlassBlurSigma,
        sigmaY: AppDimensions.onboardingConciergeGlassBlurSigma,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class OnboardingGlassDivider extends StatelessWidget {
  const OnboardingGlassDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.compactSpacing,
      ),
      child: Divider(
        height: AppDimensions.dividerHeight,
        thickness: AppDimensions.dividerHeight,
        color: AppColors.textLight.withValues(alpha: 0.16),
      ),
    );
  }
}

/// Light frosted inner panel for readable content on glass backgrounds.
class OnboardingGlassInnerCard extends StatelessWidget {
  const OnboardingGlassInnerCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.compactSpacing),
      decoration: BoxDecoration(
        color: AppColors.textLight.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingRewardsOfferRadius,
        ),
        border: Border.all(
          color: AppColors.textLight.withValues(alpha: 0.24),
        ),
      ),
      child: child,
    );
  }
}

class OnboardingGlassFrostPanel extends StatelessWidget {
  const OnboardingGlassFrostPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.compactSpacing),
      decoration: BoxDecoration(
        color: AppColors.textLight.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.textLight.withValues(alpha: 0.18),
        ),
      ),
      child: child,
    );
  }
}

class OnboardingGlassSectionLabel extends StatelessWidget {
  const OnboardingGlassSectionLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.onboardingRewardsProgressLabel.copyWith(
        color: AppColors.textLight,
      ),
    );
  }
}

class OnboardingGlassHeader extends StatelessWidget {
  const OnboardingGlassHeader({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppDimensions.onboardingConfirmedIconSize +
              AppDimensions.smallSpacing,
          height: AppDimensions.onboardingConfirmedIconSize +
              AppDimensions.smallSpacing,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryDark,
            size: AppDimensions.onboardingConfirmedIconSize,
          ),
        ),
        const SizedBox(width: AppDimensions.regularSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.onboardingConfirmedTitle),
              const SizedBox(height: AppDimensions.tinySpacing),
              Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.onboardingConfirmedMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
