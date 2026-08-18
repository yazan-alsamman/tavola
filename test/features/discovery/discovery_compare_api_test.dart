import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late DiscoveryRepository discovery;
  String? lastPath;
  Object? lastBody;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          lastPath = options.path;
          lastBody = options.data;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'Restaurants compared successfully.',
                'data': <String, dynamic>{
                  'items': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'restaurantId': 'id-a',
                      'name': 'La Joya',
                      'description': 'Dry-aged steaks.',
                      'cuisineType': 'Lounge',
                      'averageRating': 4.7,
                      'priceLevel': 4,
                      'status': 'Active',
                      'hasActiveOffer': false,
                      'hasMenu': true,
                    },
                    <String, dynamic>{
                      'restaurantId': 'id-b',
                      'name': 'The Green Fork',
                      'description': 'Plant-forward kitchen.',
                      'cuisineType': 'Vegetarian',
                      'averageRating': 4.4,
                      'priceLevel': 2,
                      'status': 'Active',
                      'hasActiveOffer': true,
                      'hasMenu': true,
                    },
                  ],
                },
              },
            ),
          );
        },
      ),
    );
    discovery = DiscoveryRepository(
      ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()),
    );
  });

  tearDown(Get.reset);

  test('compareRestaurants posts restaurantIds and maps DTO fields', () async {
    final List<RestaurantModel> items = await discovery.compareRestaurants(
      <String>['id-a', 'id-b'],
    );

    expect(lastPath, AppUrls.discoveryRestaurantsComparePath);
    expect(
      lastBody,
      <String, dynamic>{
        AppStrings.apiCompareRestaurantIdsField: <String>['id-a', 'id-b'],
      },
    );
    expect(items, hasLength(2));
    expect(items[0].id, 'id-a');
    expect(items[0].name, 'La Joya');
    expect(items[0].cuisine, 'Lounge');
    expect(items[0].averageRating, 4.7);
    expect(items[0].priceLevel, 4);
    expect(items[0].hasMenu, isTrue);
    expect(items[0].hasActiveOffer, isFalse);
    expect(items[0].status, 'Active');
    expect(items[0].description, 'Dry-aged steaks.');
    expect(items[1].id, 'id-b');
    expect(items[1].hasActiveOffer, isTrue);
    expect(items[1].priceLevel, 2);
  });

  test('fromDiscoveryJson maps compare/list restaurant payload', () {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(
      jsonDecode(
            '{"restaurantId":"x","name":"N","description":"D",'
            '"cuisineType":"Italian","averageRating":4.2,"priceLevel":3,'
            '"status":"Active","hasActiveOffer":true,"hasMenu":false}',
          )
          as Map,
    );
    final RestaurantModel model = RestaurantModel.fromDiscoveryJson(payload);

    expect(model.id, 'x');
    expect(model.cuisine, 'Italian');
    expect(model.averageRating, 4.2);
    expect(model.priceLevel, 3);
    expect(model.hasMenu, isFalse);
    expect(model.hasActiveOffer, isTrue);
    expect(model.status, 'Active');
    expect(AppStrings.priceLevelSymbols(model.priceLevel!), '\$\$\$');
  });
}
