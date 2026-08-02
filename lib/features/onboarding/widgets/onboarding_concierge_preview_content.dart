import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../concierge/widgets/concierge_message_card.dart';
import 'onboarding_glass_shell.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Tavola AI preview with a frosted primaryDark glass card.
class OnboardingConciergePreviewContent extends StatelessWidget {
  const OnboardingConciergePreviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingGlassShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingGlassHeader(
            icon: Symbols.auto_awesome,
            title: AppStrings.onboardingDinemateTitle,
            message: AppStrings.onboardingDinemateStatus,
          ),
          const OnboardingGlassDivider(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: AppDimensions.conciergeMessageWidthFactor,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.contentPadding),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(
                    alpha: AppDimensions.onboardingConciergeBubbleFillAlpha,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: Border.all(
                    color: AppColors.textLight.withValues(
                      alpha: AppDimensions.onboardingPreviewBorderAlpha,
                    ),
                  ),
                ),
                child: Text(
                  AppStrings.onboardingDinemateUserMessage,
                  style: AppTextStyles.onboardingDinemateUserBubble.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          ConciergeMessageCard(message: AppStrings.onboardingDinemateAiMessage),
          const OnboardingGlassDivider(),
          OnboardingGlassFrostPanel(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.onboardingDinemateComposerHint,
                    style: AppTextStyles.inputHint.copyWith(
                      color: AppColors.textLight80,
                    ),
                  ),
                ),
                Container(
                  width: AppDimensions.conciergeSendButtonSize,
                  height: AppDimensions.conciergeSendButtonSize,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.pillRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(
                          alpha: AppDimensions.onboardingConciergeGlowAlpha,
                        ),
                        blurRadius: AppDimensions.shadowBlur,
                        offset: const Offset(0, AppDimensions.tinySpacing),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Symbols.send,
                    size: AppDimensions.conciergeSendIconSize,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
