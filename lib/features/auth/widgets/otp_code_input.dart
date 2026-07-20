import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/otp_controller.dart';

class OtpCodeInput extends StatelessWidget {
  const OtpCodeInput({
    super.key,
    required this.controller,
  });

  final OtpController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = OtpController.otpLength;
        final double gaps =
            AppDimensions.smallSpacing * (count - 1);
        final double fieldSize = ((constraints.maxWidth - gaps) / count)
            .clamp(
              AppDimensions.otpFieldMinSize,
              AppDimensions.otpFieldSize,
            );

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (index) => _OtpDigitField(
              textController: controller.digitControllers[index],
              focusNode: controller.focusNodes[index],
              onChanged: (value) => controller.onDigitChanged(index, value),
              size: fieldSize,
            ),
          ),
        );
      },
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.textController,
    required this.focusNode,
    required this.onChanged,
    required this.size,
  });

  final TextEditingController textController;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TextField(
        controller: textController,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTextStyles.otpDigit,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: AppStrings.empty,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.otpFieldRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.otpFieldRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.otpFieldRadius),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: AppDimensions.otpFieldFocusedBorderWidth,
            ),
          ),
        ),
      ),
    );
  }
}
