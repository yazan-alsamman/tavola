import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fetchMyProfile reads nested data.user avatar payload', () async {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://example.com/api/v1'));
    dio.httpClientAdapter = _UsersAdapter();
    final _Tokens tokens = _Tokens();
    Get.put<AuthTokenReader>(tokens, permanent: true);

    final UsersRepository users = UsersRepository(
      ApiClient(dio: dio, tokenReader: tokens),
    );

    final profile = await users.fetchMyProfile();
    expect(profile.username, 'nested-user');
    final Uri base = Uri.parse(AppUrls.apiBaseUrl);
    final String expectedOrigin = '${base.scheme}://${base.authority}';
    expect(profile.avatarUrl, '$expectedOrigin/uploads/customer-avatar.png');
  });
}

class _Tokens implements AuthTokenSession {
  @override
  Future<void> clearSessionTokens() async {}

  @override
  Future<String?> readAccessToken() async => 'access-token';

  @override
  Future<String?> readRefreshToken() async => 'refresh-token';

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
    bool persistToDisk = true,
  }) async {}
}

class _UsersAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/users/me')) {
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{
          'success': true,
          'message': 'ok',
          'data': <String, dynamic>{
            'user': <String, dynamic>{
              'userId': 'u1',
              'username': 'nested-user',
              'firstName': 'Test',
              'lastName': 'User',
              'email': 'nested@example.com',
              'avatar': <String, dynamic>{
                'path': '/uploads/customer-avatar.png',
              },
            },
          },
        }),
        200,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{
        'success': true,
        'message': 'ok',
        'data': <String, dynamic>{},
      }),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
