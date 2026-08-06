import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/auth/model/customer_auth_response_model.dart';
import 'package:tavla/features/users/model/user_profile_model.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  test('displayName uses username before phone', () {
    const UserProfileModel profile = UserProfileModel(
      id: 'u1',
      firstName: '',
      lastName: '',
      email: '',
      username: 'Yazan',
      phone: '+4917670130665',
    );

    expect(profile.displayName, 'Yazan');
  });

  test('parses username from sibling customer object on /users/me', () {
    final UserProfileModel profile = UsersRepository.parseProfileForTest(
      <String, dynamic>{
        'user': <String, dynamic>{
          'userId': 'u1',
          'firstName': '',
          'lastName': '',
          'phone': '+4917670130665',
        },
        'customer': <String, dynamic>{
          'username': 'Yazan',
        },
      },
    );

    expect(profile.username, 'Yazan');
    expect(profile.phone, '+4917670130665');
    expect(profile.displayName, 'Yazan');
  });

  test('login response reads username from nested customer sibling', () {
    final CustomerAuthResponseModel model = CustomerAuthResponseModel.fromJson(
      <String, dynamic>{
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'sessionId': 's1',
        'user': <String, dynamic>{
          'userId': 'u1',
          'phone': '+4917670130665',
        },
        'customer': <String, dynamic>{
          'username': 'Yazan',
        },
      },
    );

    expect(model.username, 'Yazan');
    expect(model.phone, '+4917670130665');
  });

  test('login response reads username from JWT when payload omits it', () {
    final String token = _jwt(<String, Object?>{
      'username': 'jwt-user',
      'exp': 4102444800,
    });
    final CustomerAuthResponseModel model = CustomerAuthResponseModel.fromJson(
      <String, dynamic>{
        'accessToken': token,
        'refreshToken': 'refresh',
        'sessionId': 's1',
        'user': <String, dynamic>{
          'userId': 'u1',
          'phone': '+4917670130665',
        },
      },
    );

    expect(model.username, 'jwt-user');
  });
}

String _jwt(Map<String, Object?> claims) {
  String enc(Map<String, Object?> value) {
    final String json = jsonEncode(value);
    return base64Url.encode(utf8.encode(json)).replaceAll('=', '');
  }

  return '${enc(<String, Object?>{'alg': 'none'})}.${enc(claims)}.sig';
}
