import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'auth_country_code_picker.dart';
import 'auth_text_field.dart';

class AuthPhoneField extends StatelessWidget {
  const AuthPhoneField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onCountryChanged,
    this.initialCountryCode = AppStrings.authDefaultCountryCode,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<CountryCode> onCountryChanged;
  final String initialCountryCode;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.phone,
      prefixIcon: SizedBox(
        width: AppDimensions.authPhonePrefixWidth,
        height: AppDimensions.authFieldMinHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthCountryCodePicker(
              onChanged: onCountryChanged,
              initialCountryCode: initialCountryCode,
            ),
            Container(
              width: AppDimensions.cardBorderWidth,
              height: AppDimensions.authPhoneDividerHeight,
              margin: const EdgeInsets.only(left: AppDimensions.compactSpacing),
              color: AppColors.border,
            ),
          ],
        ),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: AppDimensions.authPhonePrefixWidth,
        maxWidth: AppDimensions.authPhonePrefixWidth,
        minHeight: AppDimensions.authFieldMinHeight,
        maxHeight: AppDimensions.authFieldMinHeight,
      ),
    );
  }
}
