import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/model/customer_login_request_model.dart';
import 'package:tavla/features/auth/model/customer_password_reset_request_models.dart';
import 'package:tavla/features/auth/model/customer_registration_request_models.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/notifications/repository/notifications_repository.dart';
import 'package:tavla/features/reservation/model/reservation_time_window.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';
import 'package:tavla/features/waitlist/model/waitlist_join_request_model.dart';
import 'package:tavla/features/waitlist/repository/waitlist_repository.dart';

/// Proves customer APIs send HTTP through Dio/ApiClient (restaurants excluded).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late List<String> hits;
  late _MemoryTokens tokens;

  setUp(() {
    Get.reset();
    hits = <String>[];
    tokens = _MemoryTokens(
      accessToken: 'access-test',
      refreshToken: 'refresh-test',
    );
    dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.httpClientAdapter = _RoutingAdapter(hits);
    Get.put<AuthTokenReader>(tokens);
  });

  tearDown(Get.reset);

  test(
    'taxonomy + auth + users + notifications + reservations + waitlist fire',
    () async {
      final ApiClient client = ApiClient(
        dio: dio,
        tokenReader: tokens,
        authRepository: AuthRepository(dio: dio),
      );
      final AuthRepository auth = AuthRepository(dio: dio);
      final TaxonomyRepository taxonomy = TaxonomyRepository(client);
      final UsersRepository users = UsersRepository(client);
      final NotificationsRepository notifications = NotificationsRepository(
        client,
      );
      final ReservationRepository reservations = ReservationRepository(client);
      final WaitlistRepository waitlist = WaitlistRepository(client);

      await taxonomy.fetchCuisineCategories();
      await taxonomy.fetchOccasionCategories();

      await auth.refreshSession('refresh-test');
      await auth.loginCustomer(
        const CustomerLoginRequestModel(
          countryCode: 'AE',
          phoneNumber: '501234567',
          password: 'SecurePass123!',
          deviceName: 'test',
          deviceType: 'ios',
        ),
      );
      await auth.startCustomerRegistration(
        const CustomerRegistrationStartRequestModel(
          username: 'probe',
          countryCode: 'AE',
          phoneNumber: '501234567',
        ),
      );
      await auth.startCustomerPasswordReset(
        const CustomerPasswordResetStartRequestModel(
          countryCode: 'AE',
          phoneNumber: '501234567',
        ),
      );

      await users.fetchMyProfile();
      await users.fetchMyPreferences();
      await users.fetchFavoriteRestaurants();

      await notifications.fetchUnreadCount();
      await notifications.fetchNotifications();

      final DateTime start = DateTime.utc(2026, 8, 1, 18);
      await reservations.searchAvailability(
        ReservationTimeWindow(
          branchId: 'b1',
          startTime: start,
          endTime: start.add(const Duration(hours: 2)),
          partySize: 2,
        ),
      );

      await waitlist.join(
        const WaitlistJoinRequestModel(
          branchId: 'b1',
          partySize: 2,
          preferredDate: '2026-08-01',
          preferredTimeFrom: '18:00',
        ),
      );

      expect(hits, contains('/cuisine-categories'));
      expect(hits, contains('/occasion-categories'));
      expect(hits, contains('/auth/refresh'));
      expect(hits, contains('/auth/customer/login'));
      expect(hits, contains('/auth/customer/register/start'));
      expect(hits, contains('/auth/customer/password-reset/start'));
      expect(hits, contains('/users/me'));
      expect(hits, contains('/users/me/preferences'));
      expect(hits, contains('/users/me/favorites'));
      expect(hits, contains('/notifications/unread-count'));
      expect(hits, contains('/notifications'));
      expect(hits, contains('/reservations/availability'));
      expect(hits, contains('/waitlist'));
      expect(
        hits.where((String path) => path.contains('restaurants')),
        isEmpty,
      );
    },
  );
}

class _MemoryTokens implements AuthTokenSession {
  _MemoryTokens({
    required String this.accessToken,
    required String this.refreshToken,
  });

  String? accessToken;
  String? refreshToken;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearSessionTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

class _RoutingAdapter implements HttpClientAdapter {
  _RoutingAdapter(this.hits);

  final List<String> hits;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    hits.add(options.path);
    final Map<String, dynamic> body = _bodyFor(options.path);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _bodyFor(String path) {
  if (path.endsWith('/auth/refresh')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{
        'accessToken': 'new-access',
        'refreshToken': 'new-refresh',
      },
    };
  }
  if (path.endsWith('/auth/customer/login')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{
        'accessToken': 'login-access',
        'refreshToken': 'login-refresh',
        'sessionId': 's1',
        'user': <String, dynamic>{
          'userId': 'u1',
          'username': 'probe',
          'phone': '+971501234567',
        },
      },
    };
  }
  if (path.contains('/auth/customer/')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{},
    };
  }
  if (path.endsWith('/users/me')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{
        'userId': 'u1',
        'username': 'probe',
        'firstName': 'P',
        'lastName': 'R',
        'email': 'p@example.com',
        'phone': '+971501234567',
      },
    };
  }
  if (path.endsWith('/users/me/preferences')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{
        'notificationOptIn': true,
        'marketingOptIn': false,
      },
    };
  }
  if (path.endsWith('/notifications/unread-count')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{'count': 1},
    };
  }
  if (path.endsWith('/waitlist')) {
    return <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': <String, dynamic>{'entryId': 'w1'},
    };
  }
  return <String, dynamic>{
    'success': true,
    'message': 'ok',
    'data': <String, dynamic>{'items': <Map<String, dynamic>>[]},
  };
}
