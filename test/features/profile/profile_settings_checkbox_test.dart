import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/profile/controller/profile_controller.dart';
import 'package:tavla/features/profile/repository/profile_repository.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';
import 'package:tavla/features/reviews/repository/reviews_repository.dart';
import 'package:tavla/features/users/model/user_preferences_model.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets(
    'guest toggle leaves checkboxes unchanged and opens Login',
    (tester) async {
      final _RecordingUsersRepository users = _putProfileStack(
        tokenReader: const EmptyAuthTokenReader(),
      );
      final ProfileController controller = Get.find<ProfileController>();
      expect(controller.notificationSettings, <bool>[true, false]);

      await tester.pumpWidget(
        GetMaterialApp(
          getPages: <GetPage<dynamic>>[
            GetPage<void>(
              name: '/home-stub',
              page: () => const Scaffold(body: Text('home')),
            ),
            GetPage<void>(
              name: AppRoutes.login,
              page: () => const Scaffold(body: Text('login-stub')),
            ),
          ],
          home: const Scaffold(body: Text('home')),
        ),
      );
      await tester.pump();

      await controller.toggleNotification(0, false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(controller.notificationSettings, <bool>[true, false]);
      expect(users.updateCalls, 0);
      expect(find.text('login-stub'), findsOneWidget);
    },
  );

  test(
    'signed-in toggle patches preferences and keeps server values',
    () async {
      final _RecordingUsersRepository users = _putProfileStack(
        tokenReader: _StaticTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
      );
      final ProfileController controller = Get.find<ProfileController>();

      await controller.toggleNotification(1, true);

      expect(users.updateCalls, 1);
      expect(users.lastNotificationOptIn, isTrue);
      expect(users.lastMarketingOptIn, isTrue);
      expect(controller.notificationSettings[1], isTrue);
    },
  );
}

_RecordingUsersRepository _putProfileStack({
  required AuthTokenReader tokenReader,
}) {
  Get.testMode = true;
  Get.reset();
  Get.put<AuthTokenReader>(tokenReader, permanent: true);
  Get.put(AuthSessionController(), permanent: true);
  final ApiClient apiClient = ApiClient(
    dio: Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl)),
    tokenReader: tokenReader,
  );
  Get.put(apiClient, permanent: true);
  Get.put(ProfileRepository(), permanent: true);
  final _RecordingUsersRepository users = _RecordingUsersRepository(apiClient);
  Get.put<UsersRepository>(users, permanent: true);
  Get.put(FavoritesRepository(), permanent: true);
  Get.put(ReservationRepository(apiClient), permanent: true);
  Get.put(ReviewsRepository(apiClient), permanent: true);
  Get.put(ProfileController(), permanent: true);
  return users;
}

class _RecordingUsersRepository extends UsersRepository {
  _RecordingUsersRepository(super.apiClient);

  int updateCalls = 0;
  bool? lastNotificationOptIn;
  bool? lastMarketingOptIn;

  @override
  Future<UserPreferencesModel> updateMyPreferences({
    required bool notificationOptIn,
    required bool marketingOptIn,
  }) async {
    updateCalls += 1;
    lastNotificationOptIn = notificationOptIn;
    lastMarketingOptIn = marketingOptIn;
    return UserPreferencesModel(
      notificationOptIn: notificationOptIn,
      marketingOptIn: marketingOptIn,
    );
  }
}

class _StaticTokens implements AuthTokenSession {
  _StaticTokens({required this.accessToken, required this.refreshToken});

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
    bool persistToDisk = true,
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
