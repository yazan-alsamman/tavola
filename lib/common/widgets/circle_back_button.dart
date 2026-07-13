import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'hoverable_button.dart';

class CircleBackButton extends StatelessWidget {
  const CircleBackButton({
    super.key,
    required this.onPressed,
    this.onDarkBackground = false,
  });

  final VoidCallback onPressed;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        onDarkBackground ? AppColors.surface75 : AppColors.surface;
    final Color iconColor =
        onDarkBackground ? AppColors.primaryDark : AppColors.primary;
    final BorderSide borderSide = onDarkBackground
        ? BorderSide.none
        : const BorderSide(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          );

    return HoverableButton(
      child: SizedBox(
        width: AppDimensions.circleBackButtonSize,
        height: AppDimensions.circleBackButtonSize,
        child: Material(
          color: backgroundColor,
          elevation: onDarkBackground
              ? AppDimensions.circleBackButtonElevation
              : 0,
          shadowColor: AppColors.primaryDark22,
          shape: CircleBorder(side: borderSide),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.circleBackIconOffset,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: iconColor,
                  size: AppDimensions.circleBackIconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
