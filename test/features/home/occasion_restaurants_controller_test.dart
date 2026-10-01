import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/common/widgets/circle_back_button.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/home/controller/occasion_restaurants_controller.dart';
import 'package:tavla/features/home/view/occasion_restaurants_screen.dart';
import 'package:tavla/features/taxonomy/model/occasion_category_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, dynamic>? lastQuery;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    lastQuery = null;
  });

  tearDown(Get.reset);

  ApiClient clientWithItems(List<Map<String, dynamic>> items) {
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          lastQuery = Map<String, dynamic>.from(options.queryParameters);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{'items': items},
              },
            ),
          );
        },
      ),
    );
    return ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>());
  }

  OccasionCategoryModel dinner() {
    return const OccasionCategoryModel(
      id: '22222222-2222-4222-8222-222222222222',
      slug: 'dinner',
      name: 'Dinner',
      sortOrder: 1,
    );
  }

  test('loads restaurants with the selected occasion id only', () async {
    final DiscoveryRepository discovery = DiscoveryRepository(
      clientWithItems(<Map<String, dynamic>>[
        <String, dynamic>{
          'restaurantId': 'r1',
          'name': 'Sakura',
          'status': 'Active',
          'coverImageUrl': 'https://cdn.example/cover.jpg',
          'averageRating': 4.4,
          'cuisineType': 'Japanese',
        },
      ]),
    );
    final OccasionRestaurantsController controller =
        OccasionRestaurantsController(
          discoveryRepository: discovery,
          category: dinner(),
        );
    controller.onInit();
    await controller.load();

    expect(
      lastQuery?[AppUrls.discoveryOccasionIdQueryKey],
      '22222222-2222-4222-8222-222222222222',
    );
    expect(lastQuery?.containsKey(AppUrls.discoveryCuisineIdQueryKey), isFalse);
    expect(controller.restaurants, hasLength(1));
    expect(controller.restaurants.first.name, 'Sakura');
    expect(
      controller.restaurants.first.imageUrl,
      'https://cdn.example/cover.jpg',
    );
    expect(controller.errorMessage.value, isNull);
    controller.onClose();
  });

  test('empty occasion response stays empty', () async {
    final DiscoveryRepository discovery = DiscoveryRepository(
      clientWithItems(<Map<String, dynamic>>[]),
    );
    final OccasionRestaurantsController controller =
        OccasionRestaurantsController(
          discoveryRepository: discovery,
          category: dinner(),
        );
    controller.onInit();
    await controller.load();

    expect(controller.restaurants, isEmpty);
    expect(controller.errorMessage.value, isNull);
    expect(controller.isLoading.value, isFalse);
    controller.onClose();
  });

  testWidgets('occasion page shows the API restaurant and a back button', (
    WidgetTester tester,
  ) async {
    final DiscoveryRepository discovery = DiscoveryRepository(
      clientWithItems(<Map<String, dynamic>>[
        <String, dynamic>{
          'restaurantId': 'r1',
          'name': 'Sakura',
          'status': 'Active',
          'coverImageUrl': '',
        },
      ]),
    );
    final OccasionRestaurantsController controller =
        OccasionRestaurantsController(
          discoveryRepository: discovery,
          category: dinner(),
        );
    Get.put(controller);

    await tester.pumpWidget(
      const GetMaterialApp(home: OccasionRestaurantsScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Dinner'), findsWidgets);
    expect(find.text('Sakura'), findsOneWidget);
    expect(find.byType(CircleBackButton), findsOneWidget);
    expect(find.text(AppStrings.restaurantsEmpty), findsNothing);
    controller.onClose();
  });
}
