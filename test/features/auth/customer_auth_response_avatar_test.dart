import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/auth/model/customer_auth_response_model.dart';

void main() {
  test('captures avatar URL from login user payload', () {
    final CustomerAuthResponseModel model = CustomerAuthResponseModel.fromJson(
      <String, dynamic>{
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'sessionId': 's1',
        'user': <String, dynamic>{
          'userId': 'u1',
          'username': 'demo',
          'phone': '+123',
          'avatar': <String, dynamic>{
            'path': '/uploads/avatar-login.png',
          },
        },
      },
    );

    expect(model.avatarUrl, '/uploads/avatar-login.png');
    expect(model.isValid, isTrue);
  });
}
