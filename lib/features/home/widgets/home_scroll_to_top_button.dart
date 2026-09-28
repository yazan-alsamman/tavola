import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../common/widgets/hoverable_button.dart';

class HomeScrollToTopButton extends StatelessWidget {
  const HomeScrollToTopButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverableButton(
      child: Tooltip(
        message: AppStrings.backToTop,
        child: SizedBox(
          width: AppDimensions.homeScrollToTopButtonSize,
          height: AppDimensions.homeScrollToTopButtonSize,
          child: Material(
            color: AppColors.primary,
            elevation: AppDimensions.homeScrollToTopElevation,
            shadowColor: AppColors.primaryDark22,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: const Icon(
                Symbols.arrow_upward,
                color: AppColors.textLight,
                size: AppDimensions.homeScrollToTopIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
