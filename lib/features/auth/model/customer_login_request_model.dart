class CustomerLoginRequestModel {
  const CustomerLoginRequestModel({
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
    required this.deviceName,
    required this.deviceType,
  });

  final String countryCode;
  final String phoneNumber;
  final String password;
  final String deviceName;
  final String deviceType;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'password': password,
    'deviceName': deviceName,
    'deviceType': deviceType,
  };
}
