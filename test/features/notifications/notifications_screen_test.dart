import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/common/widgets/custom_app_bar.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/notifications/controller/notifications_badge_controller.dart';
import 'package:tavla/features/notifications/controller/notifications_controller.dart';
import 'package:tavla/features/notifications/model/notification_item_model.dart';
import 'package:tavla/features/notifications/model/notifications_page_model.dart';
import 'package:tavla/features/notifications/repository/notifications_repository.dart';
import 'package:tavla/features/notifications/view/notifications_screen.dart';

class _StaticTokenReader implements AuthTokenReader {
  const _StaticTokenReader(this.token);

  final String? token;

  @override
  Future<String?> readAccessToken() async => token;
}

class _FakeNotificationsRepository extends NotificationsRepository {
  _FakeNotificationsRepository() : super(ApiClient());

  NotificationsPageModel page = const NotificationsPageModel(
    items: <NotificationItemModel>[],
    page: 1,
    limit: 20,
    hasMore: false,
  );

  @override
  Future<NotificationsPageModel> fetchNotifications({
    int page = 1,
    int limit = 20,
    bool? unread,
  }) async {
    return this.page;
  }

  @override
  Future<int> fetchUnreadCount() async => unreadCount.value;

  @override
  Future<void> markRead(String notificationId) async {}

  @override
  Future<void> markAllRead() async {
    unreadCount.value = 0;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.locale = const Locale('en');
    Get.put(AuthSessionController());
  });

  tearDown(Get.reset);

  Future<void> pumpNotifications(
    WidgetTester tester, {
    required _FakeNotificationsRepository repository,
    bool authenticated = true,
  }) async {
    Get.put<AuthTokenReader>(
      _StaticTokenReader(authenticated ? 'test-token' : null),
    );
    Get.find<AuthSessionController>().hasAuthenticatedSession.value =
        authenticated;
    Get.find<AuthSessionController>().isGuest.value = !authenticated;
    Get.put<NotificationsRepository>(repository, permanent: true);
    Get.put(NotificationsBadgeController(repository), permanent: true);
    Get.put(NotificationsController());

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: const NotificationsScreen(),
        getPages: <GetPage<dynamic>>[
          GetPage(
            name: AppRoutes.login,
            page: () => const Scaffold(body: Text('login-route')),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shows empty state when inbox has no items', (tester) async {
    await pumpNotifications(tester, repository: _FakeNotificationsRepository());
    expect(find.text(AppStrings.notificationsEmpty), findsOneWidget);
  });

  testWidgets('shows list items when repository returns notifications', (
    tester,
  ) async {
    final _FakeNotificationsRepository repository =
        _FakeNotificationsRepository()
          ..page = const NotificationsPageModel(
            items: <NotificationItemModel>[
              NotificationItemModel(
                id: '1',
                title: 'Welcome',
                body: 'Thanks for joining Tavola.',
                isRead: false,
              ),
            ],
            page: 1,
            limit: 20,
            hasMore: false,
          );

    await pumpNotifications(tester, repository: repository);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Thanks for joining Tavola.'), findsOneWidget);
  });

  testWidgets('shows sign-in prompt when guest has no token', (tester) async {
    await pumpNotifications(
      tester,
      repository: _FakeNotificationsRepository(),
      authenticated: false,
    );
    expect(find.text(AppStrings.notificationsSignInPrompt), findsOneWidget);
  });

  testWidgets('app bar notification icon opens notifications route', (
    tester,
  ) async {
    Get.put<AuthTokenReader>(const _StaticTokenReader('test-token'));
    Get.find<AuthSessionController>().hasAuthenticatedSession.value = true;
    final _FakeNotificationsRepository repository =
        _FakeNotificationsRepository();
    Get.put<NotificationsRepository>(repository, permanent: true);
    Get.put(NotificationsBadgeController(repository), permanent: true);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: const Scaffold(appBar: CustomAppBar()),
        getPages: <GetPage<dynamic>>[
          GetPage(
            name: AppRoutes.notifications,
            page: () => const NotificationsScreen(),
            binding: BindingsBuilder(() {
              Get.put(NotificationsController());
            }),
          ),
        ],
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Symbols.notifications));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(Get.currentRoute, AppRoutes.notifications);
    expect(find.byType(NotificationsScreen), findsOneWidget);
  });
}
