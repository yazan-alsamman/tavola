import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.settings,
              color: AppColors.primary,
              size: AppDimensions.settingsIconSize,
            ),
            SizedBox(width: AppDimensions.smallSpacing),
            Text(
              AppStrings.fineSystemConfigurations,
              style: AppTextStyles.settingsHeader,
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
      ],
    );
  }
}
