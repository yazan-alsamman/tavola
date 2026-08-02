import '../../../core/network/api_exception.dart';

class CustomerRegistrationResponseModel {
  const CustomerRegistrationResponseModel({required this.userId});

  final String userId;

  factory CustomerRegistrationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerRegistrationResponseModel(
      userId: _stringField(json['userId']),
    );
  }

  bool get isValid => userId.isNotEmpty;

  static String _stringField(Object? raw) {
    if (raw is Map || raw is List) {
      return '';
    }
    return ApiException.coerceMessage(raw);
  }
}

class AuthOperationResponseModel {
  const AuthOperationResponseModel({required this.message});

  final String message;
}
