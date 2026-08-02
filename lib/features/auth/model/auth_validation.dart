import 'dart:math' as math;

import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../core/constants/app_dimensions.dart';

/// NSN length bounds for a selected ISO country, sourced from
/// [phone_numbers_parser] metadata when available.
class PhoneNsnConstraints {
  const PhoneNsnConstraints({
    required this.minLength,
    required this.maxLength,
    required this.allowedLengths,
    required this.hasLengthMetadata,
  });

  final int minLength;
  final int maxLength;
  final Set<int> allowedLengths;
  final bool hasLengthMetadata;

  /// ITU-backed defaults when country mobile metadata has no lengths.
  static const PhoneNsnConstraints fallback = PhoneNsnConstraints(
    minLength: AppDimensions.authPhoneFallbackMinNsnLength,
    maxLength: AppDimensions.authPhoneFallbackMaxNsnLength,
    allowedLengths: <int>{},
    hasLengthMetadata: false,
  );
}

class AuthValidation {
  /// Digits only — matches customer auth API phone contracts.
  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static int digitCount(String value) {
    return digitsOnly(value).length;
  }

  static bool hasMinDigits(String value, int minDigitCount) {
    return digitCount(value) >= minDigitCount;
  }

  /// Resolves ISO-3166 alpha-2 to [IsoCode], or null when unknown.
  static IsoCode? isoCodeForCountry(String countryCode) {
    final String normalized = countryCode.trim().toUpperCase();
    if (normalized.isEmpty) {
      return null;
    }
    try {
      return IsoCode.fromJson(normalized);
    } catch (_) {
      return null;
    }
  }

  /// Min/max mobile NSN lengths for [countryCode] from package metadata.
  ///
  /// Uses mobile lengths only (no fixed-line / landline). Falls back to
  /// [PhoneNsnConstraints.fallback] when mobile lengths are unavailable.
  static PhoneNsnConstraints phoneNsnConstraints(String countryCode) {
    final IsoCode? iso = isoCodeForCountry(countryCode);
    if (iso == null) {
      return PhoneNsnConstraints.fallback;
    }

    final lengths = metadataLenghtsByIsoCode[iso];
    if (lengths == null) {
      return PhoneNsnConstraints.fallback;
    }

    final Set<int> allowed = <int>{...lengths.mobile};
    if (allowed.isEmpty) {
      return PhoneNsnConstraints.fallback;
    }

    return PhoneNsnConstraints(
      minLength: allowed.reduce(math.min),
      maxLength: allowed.reduce(math.max),
      allowedLengths: allowed,
      hasLengthMetadata: true,
    );
  }

  /// Validates mobile national significant number for [countryCode].
  ///
  /// Uses exact mobile metadata lengths when present; otherwise package
  /// [PhoneNumber.isValid] with [PhoneNumberType.mobile].
  static bool isValidNationalPhone(String value, String countryCode) {
    final String national = digitsOnly(value);
    if (national.isEmpty) {
      return false;
    }

    final IsoCode? iso = isoCodeForCountry(countryCode);
    if (iso == null) {
      return false;
    }

    final PhoneNsnConstraints constraints = phoneNsnConstraints(countryCode);
    if (constraints.hasLengthMetadata) {
      if (national.length < constraints.minLength ||
          national.length > constraints.maxLength) {
        return false;
      }
      if (!constraints.allowedLengths.contains(national.length)) {
        return false;
      }
      try {
        final PhoneNumber phone = PhoneNumber(isoCode: iso, nsn: national);
        return phone.isValidLength(type: PhoneNumberType.mobile) ||
            phone.isValid(type: PhoneNumberType.mobile);
      } catch (_) {
        return false;
      }
    }

    try {
      final PhoneNumber phone = PhoneNumber.parse(
        national,
        destinationCountry: iso,
      );
      return phone.isValid(type: PhoneNumberType.mobile);
    } catch (_) {
      return false;
    }
  }

  static bool hasUppercase(String value) {
    return RegExp(r'[A-Z]').hasMatch(value);
  }

  static bool hasLowercase(String value) {
    return RegExp(r'[a-z]').hasMatch(value);
  }

  static bool hasDigit(String value) {
    return RegExp(r'\d').hasMatch(value);
  }

  static bool hasSpecial(String value) {
    return RegExp(r'[^A-Za-z0-9]').hasMatch(value);
  }

  /// Matches customer password policy from the API contract
  /// (`CompleteCustomerRegistrationRequestDto.password` / password-reset
  /// `newPassword`: `minLength: 12`, example `SecurePass123!`).
  static bool isValidPassword(String value, int minLength) {
    return value.length >= minLength &&
        hasUppercase(value) &&
        hasLowercase(value) &&
        hasDigit(value) &&
        hasSpecial(value);
  }

  /// Login only requires a non-empty password (legacy helper).
  static bool isNonEmptyPassword(String value) {
    return value.isNotEmpty;
  }

  /// Login API enforces a minimum length (create-policy is registration-only).
  static bool isLoginPassword(String value) {
    return value.length >= AppDimensions.authMinPasswordLength;
  }

  static bool isValidEmail(String value) {
    final String email = value.trim();
    if (email.isEmpty) {
      return false;
    }
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
}
