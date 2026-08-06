import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/network/secure_auth_token_store.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('merge keeps login username when /users/me omits it', () async {
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.httpClientAdapter = _Adapter();
    final _Tokens tokens = _Tokens();
    Get.put<AuthTokenReader>(tokens, permanent: true);

    final UsersRepository users = UsersRepository(
      ApiClient(dio: dio, tokenReader: tokens),
      vault: _MemVault(),
    );
    await users.rememberCustomerIdentity(
      username: 'omarrr',
      phone: '+4917670130665',
    );
    expect(users.cachedProfile?.username, 'omarrr');

    final profile = await users.fetchMyProfile();
    expect(profile.username, 'omarrr');
    expect(profile.displayName, 'omarrr');
    expect(users.cachedProfile?.username, 'omarrr');
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

class _MemVault implements SecureKeyValueStore {
  final Map<String, String> map = <String, String>{};

  @override
  Future<String?> read(String key) async => map[key];

  @override
  Future<void> write(String key, String value) async {
    map[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    map.remove(key);
  }
}

class _Adapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{
        'success': true,
        'message': 'ok',
        'data': <String, dynamic>{
          'userId': 'u1',
          'phone': '+4917670130665',
          'language': 'en',
          'createdAt': 'x',
          'updatedAt': 'y',
        },
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
