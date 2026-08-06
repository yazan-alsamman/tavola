import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/features/auth/model/auth_device_session_model.dart';
import 'package:tavla/features/auth/model/change_password_request_model.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository repository;
  late _RecordingAdapter adapter;

  setUp(() {
    adapter = _RecordingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = adapter;
    repository = AuthRepository(dio: dio);
  });

  test('logoutCurrentSession POSTs /auth/logout with Bearer', () async {
    adapter.statusCode = 200;
    adapter.body = <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': null,
    };

    await repository.logoutCurrentSession('access-token');

    expect(adapter.lastMethod, 'POST');
    expect(adapter.lastPath, AppUrls.authLogoutPath);
    expect(adapter.lastAuthorization, 'Bearer access-token');
  });

  test('logoutAllSessions POSTs /auth/logout-all with Bearer', () async {
    adapter.statusCode = 204;
    adapter.body = null;

    await repository.logoutAllSessions('access-token');

    expect(adapter.lastMethod, 'POST');
    expect(adapter.lastPath, AppUrls.authLogoutAllPath);
    expect(adapter.lastAuthorization, 'Bearer access-token');
  });

  test('listSessions parses data.sessions', () async {
    adapter.statusCode = 200;
    adapter.body = <String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'sessions': <Map<String, dynamic>>[
          <String, dynamic>{
            'sessionId': 'current-id',
            'isCurrentSession': true,
            'deviceName': 'iPhone',
          },
          <String, dynamic>{
            'sessionId': 'other-id',
            'isCurrentSession': false,
            'deviceName': 'iPad',
          },
        ],
      },
    };

    final List<AuthDeviceSessionModel> sessions =
        await repository.listSessions('access-token');

    expect(adapter.lastMethod, 'GET');
    expect(adapter.lastPath, AppUrls.authSessionsPath);
    expect(sessions, hasLength(2));
    expect(sessions.first.sessionId, 'current-id');
    expect(sessions.first.isCurrentSession, isTrue);
    expect(sessions.last.sessionId, 'other-id');
  });

  test('revokeSession DELETEs /auth/sessions/:id', () async {
    adapter.statusCode = 200;
    adapter.body = <String, dynamic>{'success': true};

    await repository.revokeSession(
      accessToken: 'access-token',
      sessionId: 'sess-1',
    );

    expect(adapter.lastMethod, 'DELETE');
    expect(adapter.lastPath, AppUrls.authSessionPath('sess-1'));
  });

  test('changePassword POSTs current/new password body', () async {
    adapter.statusCode = 200;
    adapter.body = <String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'accessToken': 'new-access',
        'refreshToken': 'new-refresh',
      },
    };

    final tokens = await repository.changePassword(
      accessToken: 'access-token',
      request: const ChangePasswordRequestModel(
        currentPassword: 'OldPass123!',
        newPassword: 'BrandNewPass123!',
      ),
    );

    expect(adapter.lastMethod, 'POST');
    expect(adapter.lastPath, AppUrls.authChangePasswordPath);
    expect(adapter.lastBody?['currentPassword'], 'OldPass123!');
    expect(adapter.lastBody?['newPassword'], 'BrandNewPass123!');
    expect(tokens?.accessToken, 'new-access');
    expect(tokens?.refreshToken, 'new-refresh');
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  int statusCode = 200;
  Map<String, dynamic>? body = <String, dynamic>{'success': true};
  String? lastMethod;
  String? lastPath;
  String? lastAuthorization;
  Map<String, dynamic>? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastMethod = options.method;
    lastPath = options.path;
    lastAuthorization =
        options.headers[AppStrings.authorizationHeaderKey]?.toString();
    if (options.data is Map) {
      lastBody = Map<String, dynamic>.from(options.data as Map);
    } else {
      lastBody = null;
    }

    if (body == null) {
      return ResponseBody.fromString('', statusCode);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
