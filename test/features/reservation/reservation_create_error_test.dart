import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/branches/repository/branch_repository.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/reservation/controller/reservation_controller.dart';
import 'package:tavla/features/reservation/controller/select_table_controller.dart';
import 'package:tavla/features/reservation/model/customer_reservation_model.dart';
import 'package:tavla/features/reservation/model/reservation_availability_slot_model.dart';
import 'package:tavla/features/reservation/model/restaurant_table_model.dart';
import 'package:tavla/features/reservation/model/table_status.dart';
import 'package:tavla/features/reservation/repository/reservation_availability_repository.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';
import 'package:tavla/features/reservation/repository/table_repository.dart';
import 'package:tavla/features/waitlist/repository/waitlist_repository.dart';

class _TokenReader implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'test-access';
}

class _SignedInSession extends AuthSessionController {
  @override
  Future<bool> hasAccessToken() async => true;

  @override
  Future<bool> requireSignInForProtectedAction() async => true;

  @override
  void openLogin() {}
}

class _ScriptedReservationRepository extends ReservationRepository {
  _ScriptedReservationRepository(super.client);

  Object? nextCreateError;
  CustomerReservationModel? nextCreateResult;
  int createCalls = 0;

  @override
  Future<CustomerReservationModel> createReservation({
    required String branchId,
    required String tableId,
    required DateTime startTime,
    required DateTime endTime,
    required int guests,
    String? notes,
    String restaurantId = '',
    String restaurantName = '',
    String imageUrl = '',
  }) async {
    createCalls += 1;
    final Object? error = nextCreateError;
    if (error != null) {
      if (error is Error) {
        throw error;
      }
      throw error as Exception;
    }
    final CustomerReservationModel? result = nextCreateResult;
    if (result == null) {
      throw ApiException.unexpected();
    }
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late List<({String path, int status})> hits;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    hits = <({String path, int status})>[];
    Get.put<AuthTokenReader>(_TokenReader());
    dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          hits.add((path: options.path, status: 0));
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 409,
                data: <String, dynamic>{
                  'success': false,
                  'message': 'Table is no longer available.',
                },
              ),
            ),
          );
        },
      ),
    );
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
  });

  tearDown(Get.reset);

  test('createReservation surfaces 409 and does not return a booking', () async {
    final ReservationRepository repo = ReservationRepository(
      Get.find<ApiClient>(),
    );

    try {
      await repo.createReservation(
        branchId: 'b1',
        tableId: 't1',
        startTime: DateTime.utc(2026, 9, 22, 18),
        endTime: DateTime.utc(2026, 9, 22, 20),
        guests: 2,
      );
      fail('expected ApiException');
    } on ApiException catch (error) {
      expect(error.isConflict, isTrue);
      expect(error.message, 'Table is no longer available.');
    }
    expect(repo.activeReservations, isEmpty);
    expect(hits.single.path, AppUrls.reservationsPath);
  });

  test('createReservation surfaces timeout without a fake booking', () async {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionTimeout,
            ),
          );
        },
      ),
    );

    final ReservationRepository repo = ReservationRepository(
      Get.find<ApiClient>(),
    );
    await expectLater(
      () => repo.createReservation(
        branchId: 'b1',
        tableId: 't1',
        startTime: DateTime.utc(2026, 9, 22, 18),
        endTime: DateTime.utc(2026, 9, 22, 20),
        guests: 2,
      ),
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.message,
          'message',
          AppStrings.networkTimeoutError,
        ),
      ),
    );
    expect(repo.activeReservations, isEmpty);
  });

  group('SelectTableController.confirmReservation', () {
    late _ScriptedReservationRepository reservations;
    late SelectTableController select;

    RestaurantTableModel availableTable() {
      return const RestaurantTableModel(
        id: 'table-1',
        label: 'T1',
        seatCount: 4,
        status: TableStatus.available,
        positionX: 10,
        positionY: 20,
        width: 80,
        height: 80,
        isAvailableForWindow: true,
      );
    }

    Future<void> pumpController(WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
      Get.put(DiscoveryRepository(Get.find<ApiClient>()));
      Get.put(BranchRepository(Get.find<DiscoveryRepository>()));
      Get.put(
        TableRepository(
          Get.find<ApiClient>(),
          Get.find<BranchRepository>(),
          discoveryRepository: Get.find<DiscoveryRepository>(),
        ),
      );
      reservations = _ScriptedReservationRepository(Get.find<ApiClient>());
      Get.put<ReservationRepository>(reservations);
      Get.put(WaitlistRepository(Get.find<ApiClient>()));
      Get.put(ReservationAvailabilityRepository());
      Get.put<AuthSessionController>(_SignedInSession());
      select = Get.put(SelectTableController());
      await tester.pump();
      Get.put(ReservationController());
      final ReservationController reservation = Get.find<ReservationController>();
      reservation.restaurantId.value = 'rest-1';
      reservation.restaurantName.value = 'Seeki';
      reservation.branchId.value = 'branch-1';
      reservation.availabilitySlots.assignAll(<ReservationAvailabilitySlotModel>[
        ReservationAvailabilitySlotModel(
          startTime: DateTime.utc(2026, 9, 22, 18),
          endTime: DateTime.utc(2026, 9, 22, 20),
          label: '6:00 PM',
        ),
      ]);
      reservation.timeSlots.assignAll(<String>['6:00 PM']);
      select.floorPlanTables.assignAll(<RestaurantTableModel>[availableTable()]);
      select.selectedTableId.value = 'table-1';
      select.isLoadingTables.value = false;
      addTearDown(() {
        Get.closeAllSnackbars();
      });
    }

    Future<void> expectFailure(WidgetTester tester, Object error) async {
      reservations.nextCreateError = error;
      await select.confirmReservation();
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      expect(select.isCreatingReservation.value, isFalse);
      expect(select.showConfirmation.value, isFalse);
      expect(select.confirmation.value, isNull);
    }

    testWidgets('success still shows confirmation and stops loading', (
      WidgetTester tester,
    ) async {
      await pumpController(tester);
      reservations.nextCreateResult = const CustomerReservationModel(
        reservationId: 'res-1',
        status: 'Pending',
        tableId: 'table-1',
      );
      await select.confirmReservation();
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      expect(reservations.createCalls, 1);
      expect(select.isCreatingReservation.value, isFalse);
      expect(select.showConfirmation.value, isTrue);
      expect(select.confirmation.value?.referenceCode, 'res-1');
    });

    testWidgets('400 validation is surfaced without success navigation', (
      WidgetTester tester,
    ) async {
      await pumpController(tester);
      await expectFailure(
        tester,
        ApiException.fromErrorBody(<String, dynamic>{
          'message': 'guests must be at least 1',
        }, statusCode: 400),
      );
      expect(reservations.createCalls, 1);
    });

    testWidgets('401 uses existing auth gate and does not confirm', (
      WidgetTester tester,
    ) async {
      await pumpController(tester);
      await expectFailure(tester, ApiException.unauthorized());
    });

    testWidgets('409 conflict is surfaced without a fake booking', (
      WidgetTester tester,
    ) async {
      await pumpController(tester);
      await expectFailure(
        tester,
        const ApiException(
          message: 'Table is no longer available.',
          statusCode: 409,
        ),
      );
    });

    testWidgets('timeout stops loading and does not confirm', (
      WidgetTester tester,
    ) async {
      await pumpController(tester);
      await expectFailure(tester, ApiException.timeout());
    });

    testWidgets('network failure stops loading and does not confirm', (
      WidgetTester tester,
    ) async {
      await pumpController(tester);
      await expectFailure(tester, ApiException.connection());
    });

    testWidgets('unexpected exception stops loading and does not confirm', (
      WidgetTester tester,
    ) async {
      await pumpController(tester);
      await expectFailure(tester, StateError('broken parser'));
    });
  });
}
