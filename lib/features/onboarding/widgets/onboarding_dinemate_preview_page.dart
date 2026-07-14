import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingDinematePreviewPage extends StatelessWidget {
  const OnboardingDinematePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePadding,
      ),
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.onboardingSectionMaxWidth,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppDimensions.onboardingSectionPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.onboardingSectionRadius,
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.online,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox.square(
                            dimension: AppDimensions.conciergeStatusDotSize,
                          ),
                        ),
                        SizedBox(width: AppDimensions.smallSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.onboardingDinemateTitle,
                                style: AppTextStyles.onboardingRewardsHeader,
                              ),
                              Text(
                                AppStrings.conciergeStatus,
                                style: AppTextStyles.conciergeStatus,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor:
                            AppDimensions.conciergeMessageWidthFactor,
                        child: Container(
                          padding: const EdgeInsets.all(
                            AppDimensions.contentPadding,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                          child: const Text(
                            AppStrings.onboardingDinemateUserMessage,
                            style: AppTextStyles.onboardingDinemateUserBubble,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: AppDimensions.conciergeMessageWidthFactor,
                      child: Container(
                        padding: const EdgeInsets.all(
                          AppDimensions.contentPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.cardRadius,
                          ),
                          border: Border.all(
                            color: AppColors.border,
                            width: AppDimensions.cardBorderWidth,
                          ),
                        ),
                        child: const Text(
                          AppStrings.onboardingDinemateAiMessage,
                          style: AppTextStyles.conciergeMessage,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.regularSpacing,
                        vertical: AppDimensions.buttonVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.conciergeComposerRadius,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        AppStrings.conciergeMessageHint,
                        style: AppTextStyles.authInputHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          const Text(
            AppStrings.onboardingDinemateHeadline,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBookHeadline,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          const Text(
            AppStrings.onboardingDinemateHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBookHint,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
