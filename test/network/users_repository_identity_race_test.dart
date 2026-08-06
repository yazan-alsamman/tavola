import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/network/secure_auth_token_store.dart';
import 'package:tavla/features/users/model/user_profile_model.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test(
    'fetchMyProfile keeps login username when Keychain hydrate finishes empty',
    () async {
      final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      dio.httpClientAdapter = _ProfileAdapter();
      final _Tokens tokens = _Tokens();
      Get.put<AuthTokenReader>(tokens, permanent: true);

      final _SlowEmptyVault vault = _SlowEmptyVault();
      final UsersRepository users = UsersRepository(
        ApiClient(dio: dio, tokenReader: tokens),
        vault: vault,
      );

      final Future<UserProfileModel> fetchFuture = users.fetchMyProfile();
      // Let hydrate start awaiting the slow vault before login identity lands.
      await Future<void>.delayed(Duration.zero);
      await users.rememberCustomerIdentity(
        username: 'Yazan',
        phone: '+963900000001',
      );
      vault.completeReads();

      final UserProfileModel profile = await fetchFuture;
      expect(profile.username, 'Yazan');
      expect(users.cachedProfile?.username, 'Yazan');
      expect(users.cachedProfile?.displayName, 'Yazan');
    },
  );
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

class _SlowEmptyVault implements SecureKeyValueStore {
  final Completer<void> _ready = Completer<void>();

  void completeReads() {
    if (!_ready.isCompleted) {
      _ready.complete();
    }
  }

  @override
  Future<String?> read(String key) async {
    await _ready.future;
    return null;
  }

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}
}

class _ProfileAdapter implements HttpClientAdapter {
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
              'firstName': '',
              'lastName': '',
              'email': '',
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
