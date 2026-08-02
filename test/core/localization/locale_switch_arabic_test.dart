import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/theme/app_theme.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/details/controller/details_controller.dart';
import 'package:tavla/features/favorites/controller/favorites_controller.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/map/controller/restaurant_map_controller.dart';
import 'package:tavla/features/profile/controller/profile_controller.dart';
import 'package:tavla/features/reservation/controller/reservation_controller.dart';
import 'package:tavla/features/reservation/controller/select_restaurant_controller.dart';
import 'package:tavla/features/reservation/controller/select_table_controller.dart';
import 'package:tavla/features/users/model/user_profile_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  void registerApiGraph() {
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{'data': <dynamic>[]},
            ),
          );
        },
      ),
    );
    Get.put<ApiClient>(
      ApiClient(dio: dio, tokenReader: const EmptyAuthTokenReader()),
      permanent: true,
    );
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader(), permanent: true);
    Get.put(AuthSessionController(), permanent: true);
    Get.put<LocationService>(_FakeLocationService(), permanent: true);
  }

  /// Advances fake time through [LocaleController.applyLocale] delays.
  Future<void> pumpLanguageSwitch(
    WidgetTester tester,
    Future<void> switchFuture,
  ) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(AppDimensions.languageSwitchCoverDelay);
    await tester.pump(AppDimensions.languageSwitchApplyDelay);
    await tester.pump(
      AppDimensions.languageSwitchDisplayDuration -
          AppDimensions.languageSwitchApplyDelay,
    );
    await switchFuture;
    await tester.pump();
  }

  /// Mirrors [LocaleController] reload gating used after language switch.
  void reloadAliveControllers() {
    void reloadIfAlive<T extends GetxController>(void Function(T) reload) {
      if (!Get.isRegistered<T>()) {
        return;
      }
      final T controller = Get.find<T>();
      if (controller.isClosed) {
        return;
      }
      reload(controller);
    }

    reloadIfAlive<HomeController>((c) => c.reloadLocalizedData());
    reloadIfAlive<ProfileController>((c) => c.reloadLocalizedData());
    reloadIfAlive<FavoritesController>((c) => c.reloadLocalizedData());
    reloadIfAlive<RestaurantMapController>((c) => c.reloadLocalizedData());
    reloadIfAlive<SelectRestaurantController>((c) => c.reloadLocalizedData());
    reloadIfAlive<ReservationController>((c) => c.reloadLocalizedData());
    reloadIfAlive<SelectTableController>((c) => c.reloadLocalizedData());
    reloadIfAlive<DetailsController>((c) => c.reloadLocalizedData());
  }

  test('DetailsController.reloadLocalizedData is a no-op when closed', () {
    registerApiGraph();
    AppDependency.ensureDetailsDependencies();

    final DetailsController controller = Get.put(DetailsController());
    controller.onDelete();
    expect(controller.isClosed, isTrue);

    expect(() => controller.reloadLocalizedData(), returnsNormally);
  });

  test(
    'locale reload skips closed DetailsController and keeps shell alive',
    () {
      registerApiGraph();
      AppDependency.ensureHomeController();
      AppDependency.ensureMapDependencies();
      AppDependency.putPermanentIfAbsent(RestaurantMapController.new);
      AppDependency.ensureProfileDependencies();
      AppDependency.putPermanentIfAbsent(ProfileController.new);
      AppDependency.ensureDetailsDependencies();

      final DetailsController staleDetails = Get.put(DetailsController());
      staleDetails.onDelete();
      expect(staleDetails.isClosed, isTrue);
      expect(Get.isRegistered<DetailsController>(), isTrue);

      expect(reloadAliveControllers, returnsNormally);
      expect(Get.find<HomeController>().isClosed, isFalse);
      expect(Get.find<ProfileController>().isClosed, isFalse);
      expect(Get.find<RestaurantMapController>().isClosed, isFalse);
    },
  );

  test('syncLanguageToProfile is a no-op without access token', () async {
    registerApiGraph();
    AppDependency.ensureProfileDependencies();
    final ProfileController profile = AppDependency.putPermanentIfAbsent(
      ProfileController.new,
    );
    profile.userProfile.value = const UserProfileModel(
      id: 'u1',
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      phone: '+10000000000',
      language: LocaleController.englishCode,
      preferredCurrency: 'USD',
    );

    await profile.syncLanguageToProfile(isArabic: true);

    // Still English on the model — API was not called (no token).
    expect(profile.userProfile.value?.language, LocaleController.englishCode);
  });

  testWidgets('en↔ar language switch does not pop the underlying route', (
    WidgetTester tester,
  ) async {
    final List<Object> errors = <Object>[];
    final void Function(FlutterErrorDetails)? old = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      errors.add(details.exceptionAsString());
      old?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = old;
    });

    registerApiGraph();
    final LocaleController locale = AppDependency.putPermanent(
      LocaleController(),
    );
    locale.syncFromLocale(const Locale(LocaleController.englishCode));
    AppDependency.ensureHomeController();
    AppDependency.ensureProfileDependencies();
    AppDependency.putPermanentIfAbsent(ProfileController.new);

    const Key shellKey = Key('language-switch-shell');
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale(LocaleController.englishCode),
        fallbackLocale: const Locale(LocaleController.englishCode),
        theme: AppTheme.themeFor(const Locale(LocaleController.englishCode)),
        home: const Scaffold(
          key: shellKey,
          body: Center(child: Text('shell-alive')),
        ),
      ),
    );
    await tester.pump();

    await pumpLanguageSwitch(tester, locale.setArabic(true));
    expect(locale.isArabic, isTrue);
    expect(find.byKey(shellKey), findsOneWidget);
    expect(find.text('shell-alive'), findsOneWidget);

    await pumpLanguageSwitch(tester, locale.setArabic(false));
    expect(locale.isArabic, isFalse);
    expect(find.byKey(shellKey), findsOneWidget);
    expect(find.text('shell-alive'), findsOneWidget);

    expect(errors, isEmpty, reason: errors.join('\n---\n'));
  });
}

class _FakeLocationService extends LocationService {
  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<LocationPermissionState> checkPermission() async =>
      LocationPermissionState.denied;

  @override
  Future<LocationPermissionState> requestPermission() async =>
      LocationPermissionState.denied;

  @override
  Future<UserLocationModel> getCurrentLocation() async =>
      const UserLocationModel(
        permissionStatus: LocationPermissionState.denied,
        isServiceEnabled: true,
      );

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}
