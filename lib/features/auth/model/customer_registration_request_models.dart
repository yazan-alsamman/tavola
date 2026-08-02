class CustomerRegistrationStartRequestModel {
  const CustomerRegistrationStartRequestModel({
    required this.username,
    required this.countryCode,
    required this.phoneNumber,
  });

  final String username;
  final String countryCode;
  final String phoneNumber;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': username,
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
  };
}

class CustomerRegistrationVerifyRequestModel {
  const CustomerRegistrationVerifyRequestModel({
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

class CustomerRegistrationCompleteRequestModel {
  const CustomerRegistrationCompleteRequestModel({
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
  });

  final String countryCode;
  final String phoneNumber;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'password': password,
  };
}

class CustomerRegistrationResendRequestModel {
  const CustomerRegistrationResendRequestModel({
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
