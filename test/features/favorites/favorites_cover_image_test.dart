import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('favorites without coverImageUrl use the public discovery cover', () async {
    const String cover =
        'https://media.example.com/cover.jpg?X-Amz-Signature=abc';
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
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
                'data': <String, dynamic>{
                  'restaurantId': 'r-1',
                  'name': 'Olive & Oak',
                  'status': 'Active',
                  'coverImageUrl': cover,
                },
              },
            ),
          );
        },
      ),
    );
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    Get.put(DiscoveryRepository(Get.find<ApiClient>()));

    final FavoritesRepository repo = FavoritesRepository(
      usersRepository: _FavoriteUsers(),
    );
    await repo.syncFavoritesFromApi();

    expect(repo.listedFavoriteRestaurants().single.imageUrl, cover);
  });
}

class _FavoriteUsers extends UsersRepository {
  _FavoriteUsers() : super(Get.find<ApiClient>());

  @override
  Future<List<RestaurantModel>> fetchFavoriteRestaurants({
    int page = 1,
    int limit = 20,
  }) async {
    return const <RestaurantModel>[
      RestaurantModel(
        id: 'r-1',
        name: 'Olive & Oak',
        cuisine: 'Mediterranean',
        occasion: '',
        description: '',
        imageUrl: '',
        location: '',
        availabilityLabel: 'Open now',
        isAvailable: true,
      ),
    ];
  }
}
