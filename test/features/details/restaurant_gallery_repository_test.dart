import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/details/repository/restaurant_details_repository.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('gallery parser keeps signed urls in sortOrder and drops the rest', () {
    const String first =
        'https://media.example.com/a.jpg?X-Amz-Signature=abc&X-Amz-Expires=3600';
    const String second = 'https://media.example.com/b.jpg?X-Amz-Signature=def';
    final List<String> urls = RestaurantDetailsRepository.parseGalleryImageUrls(
      <String, dynamic>{
        'restaurantId': 'rest-1',
        'items': <dynamic>[
          <String, dynamic>{
            'galleryItemId': 'g2',
            'sortOrder': 2,
            'imageUrl': second,
          },
          <String, dynamic>{
            'galleryItemId': 'g0',
            'sortOrder': 0,
            'imageUrl': null,
          },
          <String, dynamic>{
            'galleryItemId': 'g1',
            'sortOrder': 1,
            'imageUrl': first,
          },
          <String, dynamic>{
            'galleryItemId': 'g3',
            'sortOrder': 3,
            'imageUrl': '/files/not-a-signed-url',
          },
        ],
      },
    );

    expect(urls, <String>[first, second]);
  });

  test('fetchDetails loads gallery without sending an access token', () async {
    Get.put<AuthTokenReader>(_TokenReader('access-token'));
    final List<String> galleryPaths = <String>[];
    final List<String?> authHeaders = <String?>[];
    final RestaurantDetailsRepository repo = _repository(
      onGallery: (RequestOptions options) {
        galleryPaths.add(options.path);
        authHeaders.add(options.headers['Authorization'] as String?);
        return <String, dynamic>{
          'success': true,
          'message': 'Restaurant gallery retrieved successfully.',
          'data': <String, dynamic>{
            'restaurantId': 'rest-1',
            'items': <dynamic>[
              <String, dynamic>{
                'sortOrder': 0,
                'imageUrl':
                    'https://media.example.com/one.jpg?X-Amz-Expires=3600',
              },
              <String, dynamic>{
                'sortOrder': 1,
                'imageUrl':
                    'https://media.example.com/two.jpg?X-Amz-Expires=3600',
              },
            ],
          },
        };
      },
    );

    final detail = await repo.fetchDetails('rest-1');
    expect(galleryPaths, <String>[AppUrls.restaurantGalleryPath('rest-1')]);
    expect(authHeaders.single, isNull);
    expect(detail.galleryImageUrls, <String>[
      'https://media.example.com/one.jpg?X-Amz-Expires=3600',
      'https://media.example.com/two.jpg?X-Amz-Expires=3600',
    ]);
  });

  test('fetchDetails loads gallery for a guest with no access token', () async {
    Get.put<AuthTokenReader>(_TokenReader(null));
    final List<String?> authHeaders = <String?>[];
    final RestaurantDetailsRepository repo = _repository(
      onGallery: (RequestOptions options) {
        authHeaders.add(options.headers['Authorization'] as String?);
        return <String, dynamic>{
          'success': true,
          'message': 'Restaurant gallery retrieved successfully.',
          'data': <String, dynamic>{
            'items': <dynamic>[
              <String, dynamic>{
                'sortOrder': 0,
                'imageUrl':
                    'https://media.example.com/guest.jpg?X-Amz-Expires=3600',
              },
            ],
          },
        };
      },
    );

    final detail = await repo.fetchDetails('rest-1');
    expect(authHeaders.single, isNull);
    expect(detail.galleryImageUrls, <String>[
      'https://media.example.com/guest.jpg?X-Amz-Expires=3600',
    ]);
    expect(detail.about, 'Test');
  });

  test('gallery auth failure leaves details on an empty gallery', () async {
    Get.put<AuthTokenReader>(_TokenReader('access-token'));
    final RestaurantDetailsRepository repo = _repository(
      onGallery: (RequestOptions options) {
        return <String, dynamic>{
          'success': false,
          'message': 'Caller is not allowed.',
          'code': 'FORBIDDEN',
          'data': null,
        };
      },
      galleryStatusCode: 403,
    );

    final detail = await repo.fetchDetails('rest-1');
    expect(detail.galleryImageUrls, isEmpty);
    expect(detail.restaurantId, 'rest-1');
  });
}

RestaurantDetailsRepository _repository({
  required Map<String, dynamic> Function(RequestOptions options) onGallery,
  int galleryStatusCode = 200,
}) {
  final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
  Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        if (options.path.endsWith('/gallery')) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: galleryStatusCode,
              data: onGallery(options),
            ),
          );
          return;
        }
        if (options.path.contains('/branches')) {
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
          return;
        }
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: <String, dynamic>{
              'success': true,
              'message': 'ok',
              'data': <String, dynamic>{
                'restaurantId': 'rest-1',
                'name': 'SakuraGrape',
                'status': 'Active',
                'description': 'Test',
                'coverImageUrl':
                    'https://media.example.com/cover.jpg?X-Amz-Signature=cover',
                'workingHours': <dynamic>[],
              },
            },
          ),
        );
      },
    ),
  );
  return RestaurantDetailsRepository(
    DiscoveryRepository(Get.find<ApiClient>()),
    Get.find<ApiClient>(),
  );
}

class _TokenReader implements AuthTokenReader {
  _TokenReader(this.token);

  final String? token;

  @override
  Future<String?> readAccessToken() async => token;
}
