import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/network/secure_auth_token_store.dart';
import 'package:tavla/features/auth/controller/delete_account_controller.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('requestAccountDeletion sends DELETE /users/me with password', () async {
    Get.put<AuthTokenReader>(_TokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    Get.put(
      UsersRepository(
        Get.find<ApiClient>(),
        vault: _MemoryVault(),
      ),
    );

    String? method;
    Object? body;
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          method = options.method;
          body = options.data;
          expect(options.path, AppUrls.usersMePath);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message':
                    'Account deletion requested. You have until the grace period ends to cancel.',
                'data': <String, dynamic>{
                  'scheduledAnonymizationAt': '2026-09-06T12:00:00.000Z',
                },
              },
            ),
          );
        },
      ),
    );

    final UsersRepository users = Get.find<UsersRepository>();
    final result = await users.requestAccountDeletion(password: 'Secret123!');
    expect(method, 'DELETE');
    expect(body, <String, dynamic>{'password': 'Secret123!'});
    expect(result.scheduledAnonymizationAt, '2026-09-06T12:00:00.000Z');
    expect(users.hasPendingAccountDeletion.value, isTrue);
  });

  test('cancelAccountDeletion posts cancel-deletion path', () async {
    Get.put<AuthTokenReader>(_TokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    final UsersRepository users = UsersRepository(
      Get.find<ApiClient>(),
      vault: _MemoryVault(),
    );
    Get.put(users);
    await users.markPendingAccountDeletion(
      scheduledAnonymizationAt: '2026-09-06T12:00:00.000Z',
    );

    String? method;
    String? path;
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          method = options.method;
          path = options.path;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 204,
            ),
          );
        },
      ),
    );

    await users.cancelAccountDeletion();
    expect(method, 'POST');
    expect(path, AppUrls.usersMeCancelDeletionPath);
    expect(users.hasPendingAccountDeletion.value, isFalse);
  });

  test('DeleteAccountController validates password before submit', () {
    Get.put<AuthTokenReader>(_TokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    Get.put(
      UsersRepository(
        Get.find<ApiClient>(),
        vault: _MemoryVault(),
      ),
    );
    final DeleteAccountController controller = DeleteAccountController();
    Get.put(controller);

    controller.passwordController.text = 'short';
    controller.submit();
    expect(controller.canSubmit.value, isFalse);
    expect(controller.isLoading.value, isFalse);
  });
}

class _TokenReader implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'access';
}

class _MemoryVault implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
