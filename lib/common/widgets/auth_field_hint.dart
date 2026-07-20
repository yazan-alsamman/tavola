import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

class AuthFieldHint extends StatelessWidget {
  const AuthFieldHint({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: AppDimensions.compactSpacing,
        start: AppDimensions.tinySpacing,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          message,
          style: AppTextStyles.authFieldErrorHint,
        ),
      ),
    );
  }
}
