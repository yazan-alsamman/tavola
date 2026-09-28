import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('history cards use the public cover instead of the file id', () async {
    const String cover =
        'https://media.example.com/cover.jpg?X-Amz-Signature=abc';
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          final bool discovery = options.path.contains('/discovery/');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': discovery
                    ? <String, dynamic>{
                        'restaurantId': 'rest-1',
                        'name': 'The Old Mill',
                        'status': 'Active',
                        'coverImageUrl': cover,
                      }
                    : <String, dynamic>{
                        'items': <dynamic>[
                          <String, dynamic>{
                            'reservationId': 'res-1',
                            'restaurantId': 'rest-1',
                            'restaurantName': 'The Old Mill',
                            'restaurantImage':
                                '11111111-1111-4111-8111-111111111111',
                            'status': 'Completed',
                            'partySize': 2,
                            'reservationStartTime': '2026-06-02T19:00:00.000Z',
                          },
                        ],
                      },
              },
            ),
          );
        },
      ),
    );
    Get.put<AuthTokenReader>(_Token());
    final ApiClient api = ApiClient(
      dio: dio,
      tokenReader: Get.find<AuthTokenReader>(),
    );
    Get.put(api);
    Get.put(DiscoveryRepository(api));

    final ReservationRepository repository = ReservationRepository(api);
    final history = await repository.fetchMyHistory();

    expect(history.single.imageUrl, cover);
    expect(repository.historyReservations.single.imageUrl, cover);
  });
}

class _Token implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'token';
}
