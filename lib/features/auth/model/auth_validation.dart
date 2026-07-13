class AuthValidation {
  static int digitCount(String value) {
    return value.replaceAll(RegExp(r'\D'), '').length;
  }

  static bool hasMinDigits(String value, int minDigitCount) {
    return digitCount(value) >= minDigitCount;
  }

  static bool hasLetter(String value) {
    return RegExp(r'[A-Za-z]').hasMatch(value);
  }

  static bool hasDigit(String value) {
    return RegExp(r'\d').hasMatch(value);
  }

  static bool isValidPassword(String value, int minLength) {
    return value.length >= minLength &&
        hasLetter(value) &&
        hasDigit(value);
  }
}
