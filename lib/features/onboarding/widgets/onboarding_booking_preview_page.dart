import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/onboarding_controller.dart';
import '../model/onboarding_date_chip.dart';

class OnboardingBookingPreviewPage extends StatelessWidget {
  const OnboardingBookingPreviewPage({super.key});

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _PartySizeSection(),
                  SizedBox(height: AppDimensions.regularSpacing),
                  _SelectDateSection(),
                  SizedBox(height: AppDimensions.regularSpacing),
                  _InviteFriendsSection(),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          const Text(
            AppStrings.onboardingBookHeadline,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBookHeadline,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          const Text(
            AppStrings.onboardingBookHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBookHint,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _OnboardingSectionCard extends StatelessWidget {
  const _OnboardingSectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.onboardingSectionPadding),
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
          Row(
            children: [
              Icon(
                icon,
                size: AppDimensions.onboardingSectionIconSize,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: AppDimensions.smallSpacing),
              Text(title, style: AppTextStyles.onboardingSectionTitle),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppDimensions.tinySpacing),
            Padding(
              padding: const EdgeInsets.only(
                left:
                    AppDimensions.onboardingSectionIconSize +
                    AppDimensions.smallSpacing,
              ),
              child: Text(subtitle!, style: AppTextStyles.onboardingSectionHint),
            ),
          ],
          const SizedBox(height: AppDimensions.smallSpacing),
          child,
        ],
      ),
    );
  }
}

class _PartySizeSection extends StatelessWidget {
  const _PartySizeSection();

  @override
  Widget build(BuildContext context) {
    return _OnboardingSectionCard(
      icon: Icons.groups_rounded,
      title: AppStrings.onboardingPartySize,
      child: Wrap(
        spacing: AppDimensions.compactSpacing,
        runSpacing: AppDimensions.compactSpacing,
        alignment: WrapAlignment.center,
        children: AppStrings.onboardingPartySizes.map((String size) {
          return Container(
            width: AppDimensions.onboardingPartyChipSize,
            height: AppDimensions.onboardingPartyChipSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(
                AppDimensions.onboardingPartyChipRadius,
              ),
            ),
            child: Text(size, style: AppTextStyles.onboardingPartyChip),
          );
        }).toList(),
      ),
    );
  }
}

class _SelectDateSection extends StatelessWidget {
  const _SelectDateSection();

  @override
  Widget build(BuildContext context) {
    return _OnboardingSectionCard(
      icon: Icons.calendar_month_rounded,
      title: AppStrings.onboardingSelectDate,
      child: Row(
        children: List<Widget>.generate(
          OnboardingController.dateChips.length,
          (int index) {
            final OnboardingDateChip chip =
                OnboardingController.dateChips[index];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == OnboardingController.dateChips.length - 1
                      ? 0
                      : AppDimensions.compactSpacing,
                ),
                child: _DateChipCard(chip: chip, isHighlighted: index == 0),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DateChipCard extends StatelessWidget {
  const _DateChipCard({required this.chip, required this.isHighlighted});

  final OnboardingDateChip chip;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.smallSpacing,
        horizontal: AppDimensions.tinySpacing,
      ),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.secondary : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingDateChipRadius,
        ),
        border: Border.all(
          color: isHighlighted ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(chip.weekday, style: AppTextStyles.onboardingDateWeekday),
          const SizedBox(height: AppDimensions.tinySpacing),
          Text(chip.dayNumber, style: AppTextStyles.onboardingDateNumber),
          const SizedBox(height: AppDimensions.tinySpacing),
          SizedBox(
            height: AppDimensions.smallIconSize,
            child: Text(
              chip.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.onboardingDateLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteFriendsSection extends StatelessWidget {
  const _InviteFriendsSection();

  @override
  Widget build(BuildContext context) {
    return _OnboardingSectionCard(
      icon: Icons.person_add_alt_1_rounded,
      title: AppStrings.onboardingInviteFriends,
      subtitle: AppStrings.onboardingInviteFriendsHint,
      child: SizedBox(
        width: double.infinity,
        child: HoverableButton(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.person_outline_rounded,
              size: AppDimensions.onboardingInviteIconSize,
            ),
            label: const Text(AppStrings.onboardingInviteFriendsAction),
            style: AppButtonStyles.filledHover(
              ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primaryDark,
                textStyle: AppTextStyles.onboardingInviteLabel,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.onboardingInviteButtonVerticalPadding,
                  horizontal: AppDimensions.regularSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.onboardingInviteButtonRadius,
                  ),
                ),
              ),
              idleBackground: AppColors.accent,
              idleForeground: AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }
}
