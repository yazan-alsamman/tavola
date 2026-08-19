import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../concierge/widgets/concierge_message_card.dart';

/// Mini TAVOLA Concierge / messaging preview for onboarding.
///
/// Matches the Chat tab header, bubbles, and composer — scaled down — while
/// [OnboardingAnimatedPageLayout] owns the entrance animation.
class OnboardingConciergePreviewContent extends StatelessWidget {
  const OnboardingConciergePreviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingMessagingPreviewRadius,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.scaffold,
            borderRadius: BorderRadius.circular(
              AppDimensions.onboardingMessagingPreviewRadius,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _MiniConciergeHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.compactSpacing,
                  AppDimensions.compactSpacing,
                  AppDimensions.compactSpacing,
                  AppDimensions.tinySpacing,
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double bubbleMaxWidth =
                        constraints.maxWidth *
                        AppDimensions.onboardingMessagingBubbleWidthFactor;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConciergeMessageCard(
                          message: AppStrings.onboardingDinemateUserMessage,
                          isFromCustomer: true,
                          compact: true,
                          maxWidth: bubbleMaxWidth,
                        ),
                        const SizedBox(height: AppDimensions.tinySpacing),
                        ConciergeMessageCard(
                          message: AppStrings.onboardingDinemateAiMessage,
                          compact: true,
                          maxWidth: bubbleMaxWidth,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const _MiniConciergeComposer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniConciergeHeader extends StatelessWidget {
  const _MiniConciergeHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePadding,
          vertical: AppDimensions.smallSpacing,
        ),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: AppDimensions.conciergeStatusDotSize,
              ),
            ),
            const SizedBox(width: AppDimensions.smallSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.conciergeTitle,
                    style: AppTextStyles.conciergeTitle.copyWith(
                      fontSize: AppDimensions.onboardingMessagingTitleFontSize,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.tinySpacing),
                  Text(
                    AppStrings.conciergeStatus,
                    style: AppTextStyles.conciergeStatus,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniConciergeComposer extends StatelessWidget {
  const _MiniConciergeComposer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.compactSpacing,
          AppDimensions.compactSpacing,
          AppDimensions.compactSpacing,
          AppDimensions.compactSpacing,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: AppDimensions.onboardingMessagingComposerHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.contentPadding,
                ),
                alignment: AlignmentDirectional.centerStart,
                decoration: BoxDecoration(
                  color: AppColors.scaffold,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.conciergeComposerRadius,
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  AppStrings.conciergeMessageHint,
                  style: AppTextStyles.inputHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.smallSpacing),
            Container(
              width: AppDimensions.onboardingMessagingSendButtonSize,
              height: AppDimensions.onboardingMessagingSendButtonSize,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
              ),
              child: const Icon(
                Symbols.send,
                size: AppDimensions.conciergeSendIconSize,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
