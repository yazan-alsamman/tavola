class CustomerPasswordResetStartRequestModel {
  const CustomerPasswordResetStartRequestModel({
    required this.countryCode,
    required this.phoneNumber,
  });

  final String countryCode;
  final String phoneNumber;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
  };
}

class CustomerPasswordResetResendRequestModel {
  const CustomerPasswordResetResendRequestModel({
    required this.countryCode,
    required this.phoneNumber,
  });

  final String countryCode;
  final String phoneNumber;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
  };
}

class CustomerPasswordResetVerifyRequestModel {
  const CustomerPasswordResetVerifyRequestModel({
    required this.countryCode,
    required this.phoneNumber,
    required this.code,
  });

  final String countryCode;
  final String phoneNumber;
  final String code;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'code': code,
  };
}

class CustomerPasswordResetCompleteRequestModel {
  const CustomerPasswordResetCompleteRequestModel({
    required this.countryCode,
    required this.phoneNumber,
    required this.newPassword,
  });

  final String countryCode;
  final String phoneNumber;
  final String newPassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'newPassword': newPassword,
  };
}
