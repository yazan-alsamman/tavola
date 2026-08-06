import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('syncProfileReservations loads upcoming + history endpoints', () async {
    Get.testMode = true;
    final List<String> paths = <String>[];
    Get.put<AuthTokenReader>(_TokenReader('access'));
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          paths.add(options.path);
          final bool upcoming = options.path.contains('/upcoming');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{
                  'items': <dynamic>[
                    <String, dynamic>{
                      'reservationId': upcoming ? 'up-1' : 'hist-1',
                      'restaurantId': 'rest-1',
                      'restaurantName': upcoming ? 'Upcoming Spot' : 'Past Spot',
                      'partySize': 2,
                      'status': upcoming ? 'Approved' : 'Completed',
                      'reservationStartTime': '2026-09-12T18:00:00.000Z',
                    },
                  ],
                  'page': 1,
                  'limit': 20,
                  'total': 1,
                },
              },
            ),
          );
        },
      ),
    );
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));

    final ReservationRepository repo = ReservationRepository(
      Get.find<ApiClient>(),
    );
    await repo.syncProfileReservations();

    expect(paths, contains(AppUrls.reservationsMyUpcomingPath));
    expect(paths, contains(AppUrls.reservationsMyHistoryPath));
    expect(repo.activeReservations.single.reservationId, 'up-1');
    expect(repo.historyReservations.single.reservationId, 'hist-1');
    expect(repo.activeReservations.single.isActive, isTrue);
    expect(repo.historyReservations.single.isActive, isFalse);
  });

  test('fetchMyReservationById hits detail path', () async {
    Get.testMode = true;
    Get.put<AuthTokenReader>(_TokenReader('access'));
    String? hit;
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          hit = options.path;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{
                  'reservationId': 'r-detail',
                  'restaurantId': 'rest-1',
                  'branchId': 'b1',
                  'tableId': 't1',
                  'guests': 3,
                  'status': 'Pending',
                  'notes': 'Note',
                  'reservationStartTime': '2026-09-12T18:00:00.000Z',
                },
              },
            ),
          );
        },
      ),
    );
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));

    final ReservationRepository repo = ReservationRepository(
      Get.find<ApiClient>(),
    );
    final detail = await repo.fetchMyReservationById('r-detail');
    expect(hit, AppUrls.reservationsMyDetailPath('r-detail'));
    expect(detail.guests, 3);
    expect(detail.notes, 'Note');
  });
}

class _TokenReader implements AuthTokenReader {
  _TokenReader(this.token);

  final String token;

  @override
  Future<String?> readAccessToken() async => token;
}
