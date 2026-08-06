import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

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
      child: SafeArea(
        top: false,
        child: Padding(
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
                  enabled: enabled,
                  style: AppTextStyles.conciergeInput,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: enabled ? (_) => onSend() : null,
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
                    onPressed: enabled ? onSend : null,
                    style: AppButtonStyles.filledHover(IconButton.styleFrom()),
                    icon: const Icon(
                      Symbols.send,
                      size: AppDimensions.conciergeSendIconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
