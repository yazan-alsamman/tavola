import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_button_styles.dart';
import 'hoverable_button.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverableButton(
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.filledHover(
          ElevatedButton.styleFrom(
            textStyle: AppTextStyles.buttonLabel(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            ),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
