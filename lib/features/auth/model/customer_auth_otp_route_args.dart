/// Shared OTP route payload for customer registration and password reset.
enum CustomerAuthOtpPurpose { registration, passwordReset }

class CustomerAuthOtpRouteArgs {
  const CustomerAuthOtpRouteArgs({
    required this.purpose,
    required this.countryCode,
    required this.dialCode,
    required this.phoneNumber,
    this.username = '',
  });

  final CustomerAuthOtpPurpose purpose;
  final String countryCode;
  final String dialCode;
  final String phoneNumber;
  final String username;

  String get displayPhone => '$dialCode $phoneNumber';

  bool get isRegistration => purpose == CustomerAuthOtpPurpose.registration;

  bool get isPasswordReset => purpose == CustomerAuthOtpPurpose.passwordReset;
}
