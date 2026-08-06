import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/users/model/user_profile_model.dart';

void main() {
  test('parses avatar URL from direct and nested payload keys', () {
    final UserProfileModel direct = UserProfileModel.fromJson(<String, dynamic>{
      'userId': 'u1',
      'firstName': 'A',
      'lastName': 'B',
      'email': 'a@b.com',
      'avatarPath': '/uploads/avatar-direct.png',
    });
    expect(direct.avatarUrl, '/uploads/avatar-direct.png');

    final UserProfileModel nested = UserProfileModel.fromJson(<String, dynamic>{
      'userId': 'u2',
      'firstName': 'C',
      'lastName': 'D',
      'email': 'c@d.com',
      'avatar': <String, dynamic>{
        'url': '/uploads/avatar-nested.png',
      },
    });
    expect(nested.avatarUrl, '/uploads/avatar-nested.png');
  });
}
