import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/model/session_mode.dart';
import 'package:tavla/features/auth/session_mode_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
  });

  tearDown(Get.reset);

  test('enterAsGuest sets flags without awaiting storage', () async {
    final _SlowAuthTokenSession tokens = _SlowAuthTokenSession();
    Get.put<AuthTokenReader>(tokens);
    final AuthSessionController session = AuthSessionController();

    final Future<void> enter = session.enterAsGuest();
    expect(session.isGuest.value, isTrue);
    expect(session.hasAuthenticatedSession.value, isFalse);
    expect(tokens.clearStarted, isTrue);
    expect(tokens.clearCompleted, isFalse);

    tokens.completeClear();
    await enter;
    await Future<void>.delayed(Duration.zero);
    expect(await SessionModePreferences.read(), SessionMode.guest);
  });
}

class _SlowAuthTokenSession implements AuthTokenSession {
  final Completer<void> _clearCompleter = Completer<void>();
  bool clearStarted = false;
  bool clearCompleted = false;

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
    bool persistToDisk = true,
  }) async {}

  @override
  Future<void> clearSessionTokens() async {
    clearStarted = true;
    await _clearCompleter.future;
    clearCompleted = true;
  }

  void completeClear() {
    if (!_clearCompleter.isCompleted) {
      _clearCompleter.complete();
    }
  }
}
