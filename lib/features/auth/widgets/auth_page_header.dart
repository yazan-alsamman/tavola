import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// Shared auth header: Playfair brand + title, Inter instruction.
class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    super.key,
    required this.title,
    required this.instruction,
  });

  final String title;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.splashTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.authBrandMark,
        ),
        const SizedBox(height: AppDimensions.regularSpacing),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.authScreenTitle,
        ),
        const SizedBox(height: AppDimensions.regularSpacing),
        Text(
          instruction,
          textAlign: TextAlign.center,
          style: AppTextStyles.authInstruction,
        ),
      ],
    );
  }
}
