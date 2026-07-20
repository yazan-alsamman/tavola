import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';

class ConciergeComposer extends StatelessWidget {
  const ConciergeComposer({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppDimensions.pagePadding,
        AppDimensions.regularSpacing,
        AppDimensions.pagePadding,
        AppDimensions.regularSpacing,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.conciergeInput,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: AppStrings.conciergeMessageHint,
                hintStyle: AppTextStyles.inputHint,
                filled: true,
                fillColor: AppColors.scaffold,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.contentPadding,
                  vertical: AppDimensions.buttonVerticalPadding,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.conciergeComposerRadius,
                  ),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.conciergeComposerRadius,
                  ),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.conciergeComposerRadius,
                  ),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.smallSpacing),
          SizedBox(
            width: AppDimensions.conciergeSendButtonSize,
            height: AppDimensions.conciergeSendButtonSize,
            child: HoverableButton(
              child: IconButton.filled(
                onPressed: onSend,
                style: AppButtonStyles.filledHover(IconButton.styleFrom()),
                icon: const Icon(
                  Icons.send_rounded,
                  size: AppDimensions.conciergeSendIconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
