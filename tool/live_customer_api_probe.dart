// Live customer API probe — same Dio/AppUrls stack as production.
// Run: dart run tool/live_customer_api_probe.dart
//
// Optional authenticated checks:
//   --dart-define=CUSTOMER_COUNTRY_CODE=SY
//   --dart-define=CUSTOMER_PHONE=0912345678
//   --dart-define=CUSTOMER_PASSWORD=...

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

Future<void> main() async {
  const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.tavola.business/api/v1',
  );
  const String countryCode = String.fromEnvironment('CUSTOMER_COUNTRY_CODE');
  const String phoneNumber = String.fromEnvironment('CUSTOMER_PHONE');
  const String password = String.fromEnvironment('CUSTOMER_PASSWORD');

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
      headers: const <String, dynamic>{
        Headers.acceptHeader: Headers.jsonContentType,
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
      validateStatus: (int? status) => status != null,
    ),
  );

  stdout.writeln('BASE=$baseUrl');
  stdout.writeln('HOST_PROBE=${await _tcpProbe(Uri.parse(baseUrl))}');

  final List<_Case> cases = <_Case>[
    _Case('GET', '/health', auth: false),
    _Case('GET', '/cuisine-categories', auth: false),
    _Case('GET', '/occasion-categories', auth: false),
    _Case(
      'POST',
      '/auth/refresh',
      auth: false,
      body: <String, dynamic>{'refreshToken': 'probe-invalid'},
    ),
    _Case(
      'POST',
      '/auth/customer/login',
      auth: false,
      body: <String, dynamic>{
        'countryCode': 'SY',
        'phoneNumber': '0911111111',
        'password': 'WrongPassword12',
        'deviceName': 'TAVOLA',
        'deviceType': 'mobile',
      },
    ),
    _Case(
      'POST',
      '/auth/customer/register/start',
      auth: false,
      body: <String, dynamic>{
        'username': 'probe_user',
        'countryCode': 'SY',
        'phoneNumber': '0999999999',
      },
    ),
    _Case(
      'POST',
      '/auth/customer/password-reset/start',
      auth: false,
      body: <String, dynamic>{'countryCode': 'SY', 'phoneNumber': '0911111111'},
    ),
    _Case('GET', '/users/me', auth: true),
    _Case('GET', '/users/me/preferences', auth: true),
    _Case('GET', '/users/me/favorites', auth: true),
    _Case('GET', '/notifications', auth: true),
    _Case('GET', '/notifications/unread-count', auth: true),
    _Case(
      'GET',
      '/reservations/availability',
      auth: true,
      query: <String, dynamic>{
        'branchId': 'probe',
        'reservationStartTime': '2026-08-01T18:00:00.000Z',
        'reservationEndTime': '2026-08-01T20:00:00.000Z',
        'partySize': 2,
      },
    ),
  ];

  int leftApp = 0;
  int httpReceived = 0;
  int transportFail = 0;

  for (final _Case c in cases) {
    leftApp += 1;
    final Stopwatch sw = Stopwatch()..start();
    try {
      final Response<dynamic> response = await dio.request<dynamic>(
        c.path,
        data: c.body,
        queryParameters: c.query,
        options: Options(
          method: c.method,
          headers: c.auth
              ? <String, dynamic>{'Authorization': 'Bearer probe-token'}
              : null,
        ),
      );
      httpReceived += 1;
      final String body = _preview(response.data);
      stdout.writeln(
        'OK ${c.method} ${c.path} status=${response.statusCode} '
        'ms=${sw.elapsedMilliseconds} body=$body',
      );
    } on DioException catch (error) {
      transportFail += 1;
      stdout.writeln(
        'FAIL ${c.method} ${c.path} type=${error.type} '
        'status=${error.response?.statusCode} '
        'ms=${sw.elapsedMilliseconds} msg=${error.message}',
      );
    } catch (error) {
      transportFail += 1;
      stdout.writeln(
        'FAIL ${c.method} ${c.path} ms=${sw.elapsedMilliseconds} error=$error',
      );
    }
  }

  if (countryCode.isNotEmpty && phoneNumber.isNotEmpty && password.isNotEmpty) {
    stdout.writeln('AUTHENTICATED_PROBE=start');
    try {
      final Response<dynamic> login = await dio.post<dynamic>(
        '/auth/customer/login',
        data: <String, dynamic>{
          'countryCode': countryCode,
          'phoneNumber': phoneNumber,
          'password': password,
          'deviceName': 'TAVOLA',
          'deviceType': 'mobile',
        },
      );
      stdout.writeln(
        'OK POST /auth/customer/login status=${login.statusCode} '
        'body=${_preview(login.data)}',
      );
      final Object? data = login.data is Map
          ? (login.data as Map)['data']
          : null;
      final String? token = data is Map
          ? (data['accessToken']?.toString())
          : null;
      if (token != null && token.isNotEmpty) {
        for (final String path in <String>[
          '/users/me',
          '/notifications/unread-count',
        ]) {
          final Response<dynamic> response = await dio.get<dynamic>(
            path,
            options: Options(
              headers: <String, dynamic>{'Authorization': 'Bearer $token'},
            ),
          );
          stdout.writeln(
            'OK GET $path status=${response.statusCode} '
            'body=${_preview(response.data)}',
          );
        }
      }
    } catch (error) {
      stdout.writeln('AUTHENTICATED_PROBE_FAIL error=$error');
    }
  } else {
    stdout.writeln(
      'AUTHENTICATED_PROBE=skipped '
      '(pass CUSTOMER_COUNTRY_CODE / CUSTOMER_PHONE / CUSTOMER_PASSWORD)',
    );
  }

  stdout.writeln(
    'SUMMARY leftApp=$leftApp httpReceived=$httpReceived '
    'transportFail=$transportFail',
  );

  exit(httpReceived > 0 ? 0 : 2);
}

Future<String> _tcpProbe(Uri uri) async {
  final String host = uri.host;
  final int port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);
  try {
    final Socket socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 5),
    );
    await socket.close();
    return 'open $host:$port';
  } catch (error) {
    return 'closed/unreachable $host:$port ($error)';
  }
}

String _preview(Object? data) {
  try {
    final String encoded = data is String ? data : jsonEncode(data);
    if (encoded.length <= 180) {
      return encoded;
    }
    return '${encoded.substring(0, 180)}…';
  } catch (_) {
    return '$data';
  }
}

class _Case {
  const _Case(
    this.method,
    this.path, {
    required this.auth,
    this.body,
    this.query,
  });

  final String method;
  final String path;
  final bool auth;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? query;
}
