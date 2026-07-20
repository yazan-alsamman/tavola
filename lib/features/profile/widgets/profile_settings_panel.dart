import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';

class ProfileSettingsPanel extends StatelessWidget {
  const ProfileSettingsPanel({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
  });

  final List<(String, String)> options;
  final List<bool> values;
  final void Function(int index, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final LocaleController localeController = Get.find<LocaleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings,
              color: AppColors.primary,
              size: AppDimensions.settingsIconSize,
            ),
            SizedBox(width: AppDimensions.smallSpacing),
            Expanded(
              child: Text(
                AppStrings.fineSystemConfigurations,
                style: AppTextStyles.settingsHeader,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.smallSpacing),
        HoverableCard(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: AppColors.border,
                width: AppDimensions.cardBorderWidth,
              ),
            ),
            child: Column(
              children: List.generate(options.length, (index) {
                final option = options[index];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.contentPadding,
                        vertical: AppDimensions.buttonVerticalPadding,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.$1,
                                  style: AppTextStyles.settingsItemTitle,
                                ),
                                const SizedBox(
                                  height: AppDimensions.tinySpacing,
                                ),
                                Text(
                                  option.$2,
                                  style: AppTextStyles.settingsItemBody,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.smallSpacing),
                          Checkbox(
                            value: values[index],
                            onChanged: (value) {
                              onChanged(index, value ?? false);
                            },
                            activeColor: AppColors.primary,
                            checkColor: AppColors.textLight,
                            side: const BorderSide(
                              color: AppColors.divider,
                              width: AppDimensions.checkboxBorderWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != options.length - 1)
                      const Divider(
                        height: AppDimensions.cardBorderWidth,
                        color: AppColors.border,
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.sectionSpacing),
        Row(
          children: [
            Icon(
              Icons.language_rounded,
              color: AppColors.primary,
              size: AppDimensions.settingsIconSize,
            ),
            SizedBox(width: AppDimensions.smallSpacing),
            Expanded(
              child: Text(
                AppStrings.languageSettings,
                style: AppTextStyles.settingsHeader,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.smallSpacing),
        HoverableCard(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: AppColors.border,
                width: AppDimensions.cardBorderWidth,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.contentPadding,
                vertical: AppDimensions.buttonVerticalPadding,
              ),
              child: Obx(() {
                final bool isArabic = localeController.isArabic;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.languageSettings,
                      style: AppTextStyles.settingsItemTitle,
                    ),
                    const SizedBox(height: AppDimensions.tinySpacing),
                    Text(
                      AppStrings.languageSettingsDescription,
                      style: AppTextStyles.settingsItemBody,
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.tinySpacing),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.pillRadius,
                        ),
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimensions.cardBorderWidth,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _LanguageOptionButton(
                              label: AppStrings.languageEnglish,
                              selected: !isArabic,
                              onTap: () {
                                if (!isArabic ||
                                    localeController.isSwitchingLanguage.value) {
                                  return;
                                }
                                localeController.setArabic(false);
                              },
                            ),
                          ),
                          Expanded(
                            child: _LanguageOptionButton(
                              label: AppStrings.languageArabic,
                              selected: isArabic,
                              onTap: () {
                                if (isArabic ||
                                    localeController.isSwitchingLanguage.value) {
                                  return;
                                }
                                localeController.setArabic(true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageOptionButton extends StatelessWidget {
  const _LanguageOptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.compactVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.settingsItemTitle.copyWith(
              color: selected ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
