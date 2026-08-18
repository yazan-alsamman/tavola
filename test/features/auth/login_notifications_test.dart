import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';

import 'auth_e2e_helpers.dart';

/// Login UI notifications + loading state (single continuous GetX session).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  const String validAePhone = '501234567';
  const String password = 'secret-password';

  testWidgets(
    'login notifications: validation, errors, loading, retry, success',
    (tester) async {
      final AuthE2eHarness harness = AuthE2eHarness();

      // Phase 1 — empty fields: validation only, no HTTP.
      await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.login));
      await settleAuth(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      final LoginController login = Get.find<LoginController>();
      expect(login.canSubmit.value, isFalse);
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(harness.adapter.requestCount, 0);
      expect(login.isLoading.value, isFalse);
      expect(login.showValidationHints.value, isTrue);
      expect(login.phoneHint.value, isNotNull);

      // Phase 2 — wrong password: server message, loading clears.
      const String apiError = 'Invalid phone or password';
      harness.adapter.responses[AuthRepository.customerLoginPath] = () =>
          jsonResponseBody(
            statusCode: 401,
            body: <String, dynamic>{'success': false, 'message': apiError},
          );
      await tester.enterText(find.byType(TextField).at(0), validAePhone);
      await tester.enterText(find.byType(TextField).at(1), password);
      await tester.pump();
      expect(login.canSubmit.value, isTrue);

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(login.isLoading.value, isTrue);

      // Duplicate tap while loading must not fire a second request.
      final int inFlight = harness.adapter.requestCount;
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(harness.adapter.requestCount, inFlight);

      await settleAuth(tester);
      expect(login.isLoading.value, isFalse);
      expect(login.errorMessage.value, apiError);
      expect(find.text(apiError), findsOneWidget);
      expect(await harness.tokenStore.readAccessToken(), isNull);
      expect(harness.adapter.requestCount, greaterThanOrEqualTo(1));
      final int afterFailure = harness.adapter.requestCount;

      // Retry after failure.
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await settleAuth(tester);
      expect(harness.adapter.requestCount, afterFailure + 1);
      expect(login.isLoading.value, isFalse);

      // Phase 3 — bare 401 text body must not show session-expired copy.
      harness.adapter.responses[AuthRepository.customerLoginPath] = () =>
          ResponseBody.fromString(
            'Unauthorized',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['text/plain'],
            },
          );
      login.errorMessage.value = null;
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await settleAuth(tester);
      expect(login.isLoading.value, isFalse);
      expect(login.errorMessage.value, AppStrings.authCredentialsRejected);
      expect(find.text(AppStrings.networkUnauthorizedError), findsNothing);
      expect(find.text(AppStrings.authCredentialsRejected), findsOneWidget);

      // Phase 4 — success navigates with tokens.
      final int requestsBeforeSuccess = harness.adapter.requestCount;
      harness.adapter.responses[AuthRepository.customerLoginPath] = () =>
          jsonResponseBody(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'ok',
              'data': <String, dynamic>{
                'accessToken': 'access-ok',
                'refreshToken': 'refresh-ok',
                'sessionId': 'session-ok',
                'user': <String, dynamic>{
                  'userId': 'user-ok',
                  'username': 'Yazan',
                  'phone': '+971501234567',
                },
              },
            },
          );
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await settleAuth(tester);

      expect(find.byKey(const Key('home-stub')), findsOneWidget);
      expect(await harness.tokenStore.readAccessToken(), 'access-ok');
      // Login POST only on the critical path — GET /users/me is owned by Home
      // progressive / authenticated catch-up after navigation.
      expect(harness.adapter.requestCount, requestsBeforeSuccess + 1);
    },
  );
}
