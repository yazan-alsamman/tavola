import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/map/controller/restaurant_map_controller.dart';
import 'package:tavla/features/map/model/restaurant_map_location.dart';
import 'package:tavla/features/map/view/restaurant_map_screen.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  Future<void> registerMapGraph() async {
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
    Get.put(LocaleController(), permanent: true);
    Get.put<LocationService>(_FakeLocationService(), permanent: true);
  }

  testWidgets('RestaurantMapScreen builds without crash', (tester) async {
    final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
    final void Function(FlutterErrorDetails)? old = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      errors.add(details);
      old?.call(details);
    };
    addTearDown(() => FlutterError.onError = old);

    await registerMapGraph();
    AppDependency.ensureMapDependencies();
    AppDependency.putPermanentIfAbsent(RestaurantMapController.new);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: const RestaurantMapScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      errors,
      isEmpty,
      reason: errors.map((e) => e.exceptionAsString()).join('\n'),
    );
    expect(find.byType(RestaurantMapScreen), findsOneWidget);
  });

  testWidgets('map route binding builds RestaurantMapScreen', (tester) async {
    final List<Object> errors = <Object>[];
    final void Function(FlutterErrorDetails)? old = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      errors.add(details.exception);
      old?.call(details);
    };
    addTearDown(() => FlutterError.onError = old);

    await registerMapGraph();

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        initialRoute: AppRoutes.map,
        getPages: AppRoutes.routes,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(RestaurantMapScreen), findsOneWidget);
    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  testWidgets('map markers with coordinates do not crash LatLng', (
    tester,
  ) async {
    await registerMapGraph();
    AppDependency.ensureMapDependencies();
    AppDependency.putPermanentIfAbsent(RestaurantMapController.new);

    final RestaurantMapController controller =
        Get.find<RestaurantMapController>();
    controller.restaurantLocations.assignAll(<RestaurantMapLocation>[
      RestaurantMapLocation(
        restaurant: const RestaurantModel(
          id: 'r1',
          name: 'Test',
          cuisine: 'Italian',
          occasion: 'Social',
          description: 'Desc',
          imageUrl: '',
          location: 'London',
          availabilityLabel: 'Open',
          isAvailable: true,
        ),
        latitude: 51.5,
        longitude: -0.12,
      ),
    ]);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: const RestaurantMapScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(RestaurantMapScreen), findsOneWidget);
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
