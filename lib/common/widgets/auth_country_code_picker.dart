import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';

class AuthCountryCodePicker extends StatelessWidget {
  const AuthCountryCodePicker({
    super.key,
    required this.onChanged,
    this.initialCountryCode = AppStrings.authDefaultCountryCode,
  });

  final ValueChanged<CountryCode> onChanged;
  final String initialCountryCode;

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      onChanged: onChanged,
      initialSelection: initialCountryCode,
      favorite: AppStrings.authFavoriteDialCodes,
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
      showFlag: true,
      showDropDownButton: false,
      alignLeft: false,
      textStyle: AppTextStyles.authInput,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      flagWidth: AppDimensions.authPhoneFlagWidth,
      pickerStyle: PickerStyle.bottomSheet,
      backgroundColor: AppColors.surface,
      barrierColor: AppColors.primaryDark22,
      dialogBackgroundColor: AppColors.surface,
      dialogTextStyle: AppTextStyles.authInput,
      headerTextStyle: AppTextStyles.authScreenTitle,
      searchStyle: AppTextStyles.authInput,
      builder: _buildCompactSelector,
      searchDecoration: InputDecoration(
        hintText: AppStrings.searchCountry,
        hintStyle: AppTextStyles.authInputHint,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.contentPadding,
          vertical: AppDimensions.smallSpacing,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.authFieldRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.authFieldRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.authFieldRadius),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildCompactSelector(CountryCode? countryCode) {
    final String dialCode =
        countryCode?.dialCode ?? AppStrings.authDefaultDialCode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (countryCode?.flagUri != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.tinySpacing),
            child: Image.asset(
              countryCode!.flagUri!,
              package: 'country_code_picker',
              width: AppDimensions.authPhoneFlagWidth,
              height: AppDimensions.authPhoneFlagWidth,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(width: AppDimensions.tinySpacing),
        Text(
          dialCode,
          style: AppTextStyles.authInput,
        ),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary,
          size: AppDimensions.smallIconSize,
        ),
      ],
    );
  }
}
