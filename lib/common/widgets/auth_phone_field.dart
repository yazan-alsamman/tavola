import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import 'auth_country_code_picker.dart';
import 'auth_text_field.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Phone field with country dial code.
///
/// [maxLengthRx] is read by the length formatter without rebuilding this
/// widget (avoids CountryCodePicker onInit → Obx rebuild-during-build).
class AuthPhoneField extends StatefulWidget {
  const AuthPhoneField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onCountryChanged,
    this.onCountryInit,
    this.initialCountryCode = AppStrings.authDefaultCountryCode,
    this.maxLengthRx,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<CountryCode> onCountryChanged;
  final ValueChanged<CountryCode?>? onCountryInit;
  final String initialCountryCode;

  /// Max national significant number length for the selected country.
  final RxInt? maxLengthRx;

  @override
  State<AuthPhoneField> createState() => _AuthPhoneFieldState();
}

class _AuthPhoneFieldState extends State<AuthPhoneField> {
  bool _showCountryPicker = false;

  @override
  void initState() {
    super.initState();
    // CountryCodePicker builds/parses the full country model list in createState.
    // Defer it one frame so Welcome -> Login/SignUp navigation stays smooth.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _showCountryPicker = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        if (widget.maxLengthRx != null)
          _RxLengthLimitingFormatter(widget.maxLengthRx!),
      ],
      prefixIcon: SizedBox(
        width: AppDimensions.authPhonePrefixWidth,
        height: AppDimensions.authFieldMinHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _showCountryPicker
                ? AuthCountryCodePicker(
                    onChanged: widget.onCountryChanged,
                    onInit: widget.onCountryInit,
                    initialCountryCode: widget.initialCountryCode,
                  )
                : const _DeferredCountryCodePlaceholder(),
            Container(
              width: AppDimensions.cardBorderWidth,
              height: AppDimensions.authPhoneDividerHeight,
              margin: const EdgeInsetsDirectional.only(
                start: AppDimensions.compactSpacing,
              ),
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

class _DeferredCountryCodePlaceholder extends StatelessWidget {
  const _DeferredCountryCodePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AppDimensions.authPhoneFlagWidth,
          height: AppDimensions.authPhoneFlagWidth,
        ),
        const SizedBox(width: AppDimensions.tinySpacing),
        Text(
          AppStrings.authDefaultDialCode,
          style: AppTextStyles.authInput,
          textDirection: TextDirection.ltr,
        ),
        const Icon(
          Symbols.keyboard_arrow_down,
          color: AppColors.primary,
          size: AppDimensions.smallIconSize,
        ),
      ],
    );
  }
}

class _RxLengthLimitingFormatter extends TextInputFormatter {
  _RxLengthLimitingFormatter(this.maxLengthRx);

  final RxInt maxLengthRx;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int maxLength = maxLengthRx.value;
    if (maxLength <= 0 || newValue.text.length <= maxLength) {
      return newValue;
    }
    return LengthLimitingTextInputFormatter(
      maxLength,
    ).formatEditUpdate(oldValue, newValue);
  }
}
