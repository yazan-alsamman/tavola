import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/reservation/model/customer_reservation_model.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomerReservationModel offer', () {
    test('reads offer { offerId, title } from a /my list item', () {
      final CustomerReservationModel model = CustomerReservationModel.fromJson(
        <String, dynamic>{
          'reservationId': 'r1',
          'status': 'Approved',
          'offer': <String, dynamic>{
            'offerId': 'off-1',
            'title': 'Quiet Tuesday',
          },
        },
      );

      expect(model.hasOffer, isTrue);
      expect(model.offerId, 'off-1');
      expect(model.offerTitle, 'Quiet Tuesday');
      expect(model.reportsOffer, isTrue);
    });

    test('reads offerId from the flat reservation shape', () {
      final CustomerReservationModel model = CustomerReservationModel.fromJson(
        <String, dynamic>{
          'reservationId': 'r1',
          'status': 'Pending',
          'offerId': 'off-1',
        },
      );

      expect(model.offerId, 'off-1');
      expect(model.offerTitle, isEmpty);
    });

    test('a null offer is an ordinary booking the backend reported', () {
      final CustomerReservationModel model = CustomerReservationModel.fromJson(
        <String, dynamic>{
          'reservationId': 'r1',
          'status': 'Pending',
          'offerId': null,
        },
      );

      expect(model.hasOffer, isFalse);
      expect(model.reportsOffer, isTrue);
    });

    test('an older backend that sends no offer field reports nothing', () {
      final CustomerReservationModel model = CustomerReservationModel.fromJson(
        <String, dynamic>{'reservationId': 'r1', 'status': 'Pending'},
      );

      expect(model.hasOffer, isFalse);
      expect(model.reportsOffer, isFalse);
    });
  });

  group('createReservation', () {
    setUp(() {
      Get.testMode = true;
      Get.reset();
    });
    tearDown(Get.reset);

    Future<(Map<String, dynamic>?, CustomerReservationModel)> create({
      String? offerId,
      Object? responseOfferId,
    }) async {
      final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      Get.put<AuthTokenReader>(const _TokenReader());
      Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
      Map<String, dynamic>? body;
      dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                body = Map<String, dynamic>.from(options.data as Map);
                handler.resolve(
                  Response<dynamic>(
                    requestOptions: options,
                    statusCode: 201,
                    data: <String, dynamic>{
                      'success': true,
                      'message': 'ok',
                      'data': <String, dynamic>{
                        'reservationId': 'r-new',
                        'branchId': 'b-1',
                        'tableId': 't-1',
                        'guests': 2,
                        'status': 'Pending',
                        'offerId': responseOfferId,
                      },
                    },
                  ),
                );
              },
        ),
      );
      final ReservationRepository repo = ReservationRepository(
        Get.find<ApiClient>(),
      );
      final CustomerReservationModel created = await repo.createReservation(
        branchId: 'b-1',
        tableId: 't-1',
        startTime: DateTime.utc(2026, 11, 17, 18),
        endTime: DateTime.utc(2026, 11, 17, 20),
        guests: 2,
        offerId: offerId,
        offerTitle: 'Quiet Tuesday',
      );
      return (body, created);
    }

    test('sends offerId and keeps the offer title when applied', () async {
      final (Map<String, dynamic>? body, CustomerReservationModel created) =
          await create(offerId: 'off-1', responseOfferId: 'off-1');

      expect(body?['offerId'], 'off-1');
      expect(created.offerId, 'off-1');
      expect(created.offerTitle, 'Quiet Tuesday');
    });

    test('reports an offer the backend did not apply', () async {
      final (_, CustomerReservationModel created) = await create(
        offerId: 'off-1',
      );

      expect(created.hasOffer, isFalse);
      expect(created.reportsOffer, isTrue);
      expect(created.offerTitle, isEmpty);
    });

    test('an ordinary booking sends no offerId', () async {
      final (Map<String, dynamic>? body, _) = await create();

      expect(body?.containsKey('offerId'), isFalse);
    });
  });
}

class _TokenReader implements AuthTokenReader {
  const _TokenReader();

  @override
  Future<String?> readAccessToken() async => 'access';
}
