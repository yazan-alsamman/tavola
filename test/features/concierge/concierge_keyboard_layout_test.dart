import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/common/widgets/bottom_nav_bar.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/concierge/controller/concierge_controller.dart';
import 'package:tavla/features/concierge/model/conversation_model.dart';
import 'package:tavla/features/concierge/repository/conversations_repository.dart';
import 'package:tavla/features/concierge/view/concierge_screen.dart';
import 'package:tavla/features/concierge/widgets/concierge_composer.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  const ConversationModel openConversation = ConversationModel(
    conversationId: 'c-layout',
    restaurantId: 'r-1',
    restaurantName: 'Layout Bistro',
    status: AppStrings.conversationStatusOpen,
  );

  Future<void> pumpConcierge(WidgetTester tester) async {
    Get.testMode = true;
    Get.put(LocaleController()).syncFromLocale(const Locale('en'));
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.apiBaseUrl,
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{'items': <dynamic>[]},
              },
            ),
          );
        },
      ),
    );
    final ApiClient api = ApiClient(
      dio: dio,
      tokenReader: Get.find<AuthTokenReader>(),
    );
    Get.put(api);
    Get.put(ConversationsRepository(api));
    Get.put(DiscoveryRepository(api));
    Get.put(ConciergeController());

    await tester.pumpWidget(
      GetMaterialApp(
        home: const ConciergeScreen(),
        translations: _EmptyTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final ConciergeController controller = Get.find<ConciergeController>();
    controller.requiresSignIn.value = false;
    controller.isLoadingConversations.value = false;
    controller.showConversationList.value = false;
    controller.activeConversation.value = openConversation;
    await tester.pump();
  }

  testWidgets('composer docks above keyboard without empty gap or bottom nav', (
    tester,
  ) async {
    await pumpConcierge(tester);

    expect(find.byType(ConciergeComposer), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();

    expect(find.byType(BottomNavBar), findsNothing);
    expect(find.byType(ConciergeComposer), findsOneWidget);

    final double keyboardTop =
        tester.view.physicalSize.height / tester.view.devicePixelRatio -
        300 / tester.view.devicePixelRatio;
    final Rect composerRect = tester.getRect(find.byType(ConciergeComposer));
    expect(composerRect.bottom, lessThanOrEqualTo(keyboardTop + 1));
    expect(
      keyboardTop - composerRect.bottom,
      lessThan(AppDimensions.pagePadding * 2),
    );
  });

  testWidgets('bottom nav returns when keyboard closes', (tester) async {
    await pumpConcierge(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    expect(find.byType(BottomNavBar), findsNothing);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();
    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(find.byType(ConciergeComposer), findsOneWidget);
  });
}

class _EmptyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => <String, Map<String, String>>{
    'en': <String, String>{
      'Message your dining host...': 'Message your dining host...',
    },
    'ar': <String, String>{},
  };
}
