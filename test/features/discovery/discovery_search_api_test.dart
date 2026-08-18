import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

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
  Map<String, dynamic>? lastQuery;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          lastPath = options.path;
          lastQuery = Map<String, dynamic>.from(options.queryParameters);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{
                  'items': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'restaurantId': 's1',
                      'name': 'Search Hit',
                      'cuisineType': 'Italian',
                      'status': 'Active',
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

  test('searchRestaurants sends q and does not replace browse cache', () async {
    await discovery.listRestaurants(forceRefresh: true);
    expect(discovery.cachedRestaurants, isNotNull);

    final List<RestaurantModel> hits = await discovery.searchRestaurants(
      query: 'pasta',
      latitude: 33.5,
      longitude: 36.2,
    );

    expect(lastPath, AppUrls.discoveryRestaurantsPath);
    expect(lastQuery?[AppUrls.discoverySearchQueryKey], 'pasta');
    expect(lastQuery?[AppUrls.nearbyLatitudeQueryKey], 33.5);
    expect(
      lastQuery?[AppUrls.discoveryLimitQueryKey],
      isNotNull,
      reason: 'Live Discovery expects limit, not pageSize',
    );
    expect(lastQuery?.containsKey(AppUrls.discoveryPageSizeQueryKey), isFalse);
    expect(hits, hasLength(1));
    expect(hits.first.name, 'Search Hit');
    expect(discovery.cachedRestaurants, isNotEmpty);
  });
}
