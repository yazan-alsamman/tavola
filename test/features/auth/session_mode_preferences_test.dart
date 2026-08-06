import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/auth/model/session_mode.dart';
import 'package:tavla/features/auth/session_mode_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('first launch reads SessionMode.none', () async {
    expect(await SessionModePreferences.read(), SessionMode.none);
  });

  test('guest and authenticated round-trip without magic strings', () async {
    await SessionModePreferences.write(SessionMode.guest);
    expect(await SessionModePreferences.read(), SessionMode.guest);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(AppStrings.sessionModeKey),
      AppStrings.sessionModeGuestValue,
    );

    await SessionModePreferences.write(SessionMode.authenticated);
    expect(await SessionModePreferences.read(), SessionMode.authenticated);
    expect(
      prefs.getString(AppStrings.sessionModeKey),
      AppStrings.sessionModeAuthenticatedValue,
    );
  });

  test('clear removes persisted mode (Logout / Fresh)', () async {
    await SessionModePreferences.write(SessionMode.guest);
    await SessionModePreferences.clear();
    expect(await SessionModePreferences.read(), SessionMode.none);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(AppStrings.sessionModeKey), isFalse);
  });

  test('SessionMode.fromStorage rejects unknown values as none', () {
    expect(SessionMode.fromStorage(null), SessionMode.none);
    expect(SessionMode.fromStorage(''), SessionMode.none);
    expect(SessionMode.fromStorage('bogus'), SessionMode.none);
    expect(
      SessionMode.fromStorage(AppStrings.sessionModeGuestValue),
      SessionMode.guest,
    );
  });
}
