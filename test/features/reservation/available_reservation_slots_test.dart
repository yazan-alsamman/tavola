import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/branches/repository/branch_repository.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/reservation/controller/reservation_controller.dart';
import 'package:tavla/features/reservation/model/available_reservation_slots.dart';
import 'package:tavla/features/reservation/model/reservation_time_slot.dart';
import 'package:tavla/features/reservation/repository/reservation_availability_repository.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';
import 'package:tavla/features/reservation/widgets/reservation_choice_chip.dart';
import 'package:tavla/features/reservation/widgets/reservation_time_slots_panel.dart';

const String _branchA = '11111111-1111-4111-8111-111111111111';
const String _branchB = '22222222-2222-4222-8222-222222222222';
const String _zoneDamascus = 'Asia/Damascus';
const String _zoneLondon = 'Europe/London';
const String _zoneNewYork = 'America/New_York';

const List<String> _retiredCandidateLabels = <String>[
  '7:30 PM',
  '8:00 PM',
  '8:30 PM',
  '9:15 PM',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AvailableReservationSlots.parse', () {
    test('reads the available-slots data object and keeps original ISO', () {
      final AvailableReservationSlots parsed = AvailableReservationSlots.parse(
        _data(
          timezone: _zoneDamascus,
          slots: <Map<String, dynamic>>[
            _slot('2026-09-30T16:30:00Z', '2026-09-30T18:30:00Z'),
          ],
        ),
      );

      expect(parsed.outcome, AvailableReservationSlotsOutcome.available);
      expect(parsed.timezone, _zoneDamascus);
      expect(parsed.openingTime, '18:00');
      expect(parsed.intervalMinutes, 30);
      expect(parsed.slots, hasLength(1));
      expect(parsed.slots.single.startTimeIso, '2026-09-30T16:30:00Z');
      expect(parsed.slots.single.endTimeIso, '2026-09-30T18:30:00Z');
      expect(parsed.slots.single.startTime, DateTime.utc(2026, 9, 30, 16, 30));
    });

    test('rejects clock labels instead of turning them into slots', () {
      expect(
        () => ReservationTimeSlot.fromJson(<String, dynamic>{
          'startTime': '19:30',
          'endTime': '21:15',
        }),
        throwsFormatException,
      );
    });

    test('preserves backend order and does not invent missing windows', () {
      final AvailableReservationSlots parsed = AvailableReservationSlots.parse(
        _data(
          timezone: _zoneDamascus,
          slots: <Map<String, dynamic>>[
            _slot('2026-09-30T19:00:00.000Z', '2026-09-30T21:00:00.000Z'),
            _slot('2026-09-30T15:00:00.000Z', '2026-09-30T17:00:00.000Z'),
          ],
        ),
      );

      expect(
        parsed.slots.map((ReservationTimeSlot slot) => slot.startTimeIso),
        <String>['2026-09-30T19:00:00.000Z', '2026-09-30T15:00:00.000Z'],
      );
    });
  });

  group('ReservationController time slots', () {
    late _RecordingAdapter adapter;
    late ReservationController controller;

    setUp(() {
      Get.testMode = true;
      Get.reset();
      adapter = _RecordingAdapter();
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = adapter;
      Get.put<AuthTokenReader>(const _TokenReader());
      Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
      Get.put(ReservationRepository(Get.find<ApiClient>()));
      Get.put(DiscoveryRepository(Get.find<ApiClient>()));
      Get.put(BranchRepository(Get.find<DiscoveryRepository>()));
      Get.put(ReservationAvailabilityRepository());
      controller = Get.put(ReservationController());
    });

    tearDown(Get.reset);

    test('shows every slot the backend returns', () async {
      adapter.builder = (_) => _envelope(
        timezone: _zoneDamascus,
        slots: <Map<String, dynamic>>[
          _slot('2026-09-30T15:00:00.000Z', '2026-09-30T17:00:00.000Z'),
          _slot('2026-09-30T15:30:00.000Z', '2026-09-30T17:30:00.000Z'),
          _slot('2026-09-30T16:30:00.000Z', '2026-09-30T18:30:00.000Z'),
          _slot('2026-09-30T18:00:00.000Z', '2026-09-30T20:00:00.000Z'),
        ],
      );

      await _load(controller, branchId: _branchA);

      expect(controller.timeSlots, <String>[
        '6:00 PM',
        '6:30 PM',
        '7:30 PM',
        '9:00 PM',
      ]);
      expect(adapter.calls, hasLength(1));
      expect(adapter.calls.single.path, AppUrls.reservationsAvailableSlotsPath);
    });

    test('shows 2, 10, and 100 slots without a request cap', () async {
      for (final int count in <int>[2, 10, 100]) {
        adapter.calls.clear();
        adapter.builder = (_) => _envelope(
          timezone: _zoneDamascus,
          slots: List<Map<String, dynamic>>.generate(count, _slotAt),
        );

        await _load(controller, branchId: _branchA);

        expect(controller.availabilitySlots, hasLength(count));
        expect(controller.timeSlots, hasLength(count));
        expect(
          controller.availabilitySlots.first.startTimeIso,
          _slotAt(0)['startTime'],
        );
        expect(
          controller.availabilitySlots.last.startTimeIso,
          _slotAt(count - 1)['startTime'],
        );
        final Map<String, dynamic> query = adapter.calls.last.query;
        expect(query.containsKey('limit'), isFalse);
        expect(query.containsKey('page'), isFalse);
        expect(query.containsKey('pageSize'), isFalse);
      }
    });

    testWidgets('the time-slot panel renders every returned slot', (
      WidgetTester tester,
    ) async {
      const int count = 100;
      adapter.builder = (_) => _envelope(
        timezone: _zoneDamascus,
        slots: List<Map<String, dynamic>>.generate(count, _slotAt),
      );

      await tester.runAsync(() => _load(controller, branchId: _branchA));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReservationTimeSlotsPanel(controller: controller),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ReservationChoiceChip), findsNWidgets(count));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    test('shows only the two slots in the payload', () async {
      adapter.builder = (_) => _envelope(
        timezone: _zoneDamascus,
        slots: <Map<String, dynamic>>[
          _slot('2026-09-30T16:00:00.000Z', '2026-09-30T18:00:00.000Z'),
          _slot('2026-09-30T17:00:00.000Z', '2026-09-30T19:00:00.000Z'),
        ],
      );

      await _load(controller, branchId: _branchA);

      expect(controller.timeSlots, <String>['7:00 PM', '8:00 PM']);
    });

    test('shows no times when slots is empty', () async {
      adapter.builder = (_) => _envelope(
        timezone: _zoneDamascus,
        outcome: AppStrings.apiReservationSlotsOutcomeNoRemainingSlots,
        slots: const <Map<String, dynamic>>[],
      );

      await _load(controller, branchId: _branchA);

      expect(controller.timeSlots, isEmpty);
      expect(controller.slotsError.value, isNull);
      expect(
        controller.slotsOutcome.value,
        AvailableReservationSlotsOutcome.noRemainingSlots,
      );
      expect(controller.timeSlots, isNot(containsAll(_retiredCandidateLabels)));
    });

    test(
      'shows the returned wall times and skips the interval series',
      () async {
        adapter.builder = (_) => _envelope(
          timezone: _zoneDamascus,
          openingTime: '18:00',
          intervalMinutes: 30,
          slots: <Map<String, dynamic>>[
            _slot('2026-09-30T15:00:00.000Z', '2026-09-30T17:00:00.000Z'),
            _slot('2026-09-30T15:30:00.000Z', '2026-09-30T17:30:00.000Z'),
            _slot('2026-09-30T18:00:00.000Z', '2026-09-30T20:00:00.000Z'),
            _slot('2026-09-30T19:00:00.000Z', '2026-09-30T21:00:00.000Z'),
          ],
        );

        await _load(controller, branchId: _branchA);

        expect(controller.timeSlots, <String>[
          '6:00 PM',
          '6:30 PM',
          '9:00 PM',
          '10:00 PM',
        ]);
        expect(controller.timeSlots, isNot(contains('7:00 PM')));
        expect(controller.timeSlots, isNot(contains('8:00 PM')));
        expect(controller.timeSlots, isNot(contains('8:30 PM')));
      },
    );

    test(
      'formats the same UTC instant with the timezone from the response',
      () async {
        const String start = '2026-09-30T16:30:00.000Z';
        const String end = '2026-09-30T18:30:00.000Z';

        adapter.builder = (_) => _envelope(
          timezone: _zoneDamascus,
          slots: <Map<String, dynamic>>[_slot(start, end)],
        );
        await _load(controller, branchId: _branchA);
        expect(controller.timeSlots, <String>['7:30 PM']);

        adapter.builder = (_) => _envelope(
          timezone: _zoneLondon,
          slots: <Map<String, dynamic>>[_slot(start, end)],
        );
        await _load(controller, branchId: _branchA);
        expect(controller.timeSlots, <String>['5:30 PM']);

        adapter.builder = (_) => _envelope(
          timezone: _zoneNewYork,
          slots: <Map<String, dynamic>>[_slot(start, end)],
        );
        await _load(controller, branchId: _branchA);
        expect(controller.timeSlots, <String>['12:30 PM']);
      },
    );

    test('keeps backend order', () async {
      adapter.builder = (_) => _envelope(
        timezone: _zoneDamascus,
        slots: <Map<String, dynamic>>[
          _slot('2026-09-30T19:00:00.000Z', '2026-09-30T21:00:00.000Z'),
          _slot('2026-09-30T15:00:00.000Z', '2026-09-30T17:00:00.000Z'),
        ],
      );

      await _load(controller, branchId: _branchA);

      expect(controller.timeSlots, <String>['10:00 PM', '6:00 PM']);
    });

    test('does not show slots when outcome is not AVAILABLE', () async {
      adapter.builder = (_) => _envelope(
        timezone: _zoneDamascus,
        outcome: AppStrings.apiReservationSlotsOutcomeClosed,
        slots: <Map<String, dynamic>>[
          _slot('2026-09-30T15:00:00.000Z', '2026-09-30T17:00:00.000Z'),
        ],
      );

      await _load(controller, branchId: _branchA);

      expect(controller.timeSlots, isEmpty);
      expect(controller.slotsError.value, isNull);
      expect(
        controller.slotsOutcome.value,
        AvailableReservationSlotsOutcome.closed,
      );
      expect(controller.buildTimeWindow(), isNull);
    });

    test(
      'reloads when branch, date, party size, or duration changes',
      () async {
        adapter.builder = (Map<String, dynamic> query) {
          final String branch = '${query['branchId']}';
          final String date = '${query['date']}';
          final String party = '${query['partySize']}';
          final String duration = '${query['durationMinutes']}';
          if (duration == '150') {
            return _envelope(
              timezone: _zoneDamascus,
              durationMinutes: 150,
              slots: <Map<String, dynamic>>[
                _slot('2026-09-30T19:00:00.000Z', '2026-09-30T21:30:00.000Z'),
              ],
            );
          }
          if (party == '6') {
            return _envelope(
              timezone: _zoneDamascus,
              slots: <Map<String, dynamic>>[
                _slot('2026-09-30T18:00:00.000Z', '2026-09-30T20:00:00.000Z'),
              ],
            );
          }
          if (date == '2026-10-03') {
            return _envelope(
              timezone: _zoneDamascus,
              date: date,
              slots: <Map<String, dynamic>>[
                _slot('2026-10-03T15:00:00.000Z', '2026-10-03T17:00:00.000Z'),
                _slot('2026-10-03T16:00:00.000Z', '2026-10-03T18:00:00.000Z'),
              ],
            );
          }
          if (branch == _branchB) {
            return _envelope(
              timezone: _zoneLondon,
              branchId: _branchB,
              slots: <Map<String, dynamic>>[
                _slot('2026-09-30T16:30:00.000Z', '2026-09-30T18:30:00.000Z'),
              ],
            );
          }
          return _envelope(
            timezone: _zoneDamascus,
            slots: <Map<String, dynamic>>[
              _slot('2026-09-30T15:00:00.000Z', '2026-09-30T17:00:00.000Z'),
              _slot('2026-09-30T15:30:00.000Z', '2026-09-30T17:30:00.000Z'),
              _slot('2026-09-30T16:00:00.000Z', '2026-09-30T18:00:00.000Z'),
              _slot('2026-09-30T16:30:00.000Z', '2026-09-30T18:30:00.000Z'),
            ],
          );
        };

        await _load(controller, branchId: _branchA, day: DateTime(2026, 9, 30));
        expect(controller.timeSlots, hasLength(4));
        expect(adapter.calls.single.query['branchId'], _branchA);
        expect(adapter.calls.single.query['date'], '2026-09-30');
        expect('${adapter.calls.single.query['partySize']}', '2');
        expect(
          '${adapter.calls.single.query['durationMinutes']}',
          '${(AppDimensions.reservationDurationHours[0] * 60).round()}',
        );

        controller.branchId.value = _branchB;
        await controller.loadAvailabilitySlots();
        expect(controller.timeSlots, <String>['5:30 PM']);
        expect(adapter.calls.last.query['branchId'], _branchB);

        final int afterBranch = adapter.calls.length;
        controller.selectedDay.value = DateTime(2026, 10, 3);
        await _waitForCalls(adapter, controller, afterBranch + 1);
        expect(controller.timeSlots, <String>['6:00 PM', '7:00 PM']);
        expect(adapter.calls.last.query['date'], '2026-10-03');
        expect(adapter.calls.last.query['branchId'], _branchB);

        controller.branchId.value = _branchA;
        final int beforeReset = adapter.calls.length;
        controller.selectedDay.value = DateTime(2026, 9, 30);
        await _waitForCalls(adapter, controller, beforeReset + 1);
        final int beforeParty = adapter.calls.length;
        controller.dinerCount.value = 6;
        await _waitForCalls(adapter, controller, beforeParty + 1);
        expect(controller.timeSlots, <String>['9:00 PM']);
        expect('${adapter.calls.last.query['partySize']}', '6');

        final int beforeDuration = adapter.calls.length;
        controller.selectDuration(2);
        await _waitForCalls(adapter, controller, beforeDuration + 1);
        expect(controller.timeSlots, <String>['10:00 PM']);
        expect('${adapter.calls.last.query['durationMinutes']}', '150');
        expect(
          adapter.calls.where(
            (_RecordedCall call) =>
                call.path == AppUrls.reservationsAvailabilityPath,
          ),
          isEmpty,
        );
      },
    );

    test('sends the original slot instants to availability', () async {
      const String start = '2026-09-30T16:30:00Z';
      const String end = '2026-09-30T18:30:00Z';
      adapter.builder = (Map<String, dynamic> query) {
        if ('${query['pathHint']}' == 'ignore') {
          return _envelope(timezone: _zoneDamascus);
        }
        return _envelope(
          timezone: _zoneDamascus,
          slots: <Map<String, dynamic>>[_slot(start, end)],
        );
      };

      await _load(controller, branchId: _branchA);
      final window = controller.buildTimeWindow();
      expect(window, isNotNull);
      expect(window!.startTimeIso, start);
      expect(window.endTimeIso, end);

      adapter.availabilityBody = <String, dynamic>{
        'success': true,
        'message': 'ok',
        'data': <String, dynamic>{'items': <Map<String, dynamic>>[]},
      };
      await Get.find<ReservationRepository>().searchAvailability(window);

      final _RecordedCall availability = adapter.calls.last;
      expect(availability.path, AppUrls.reservationsAvailabilityPath);
      expect(availability.query['reservationStartTime'], start);
      expect(availability.query['reservationEndTime'], end);
      expect(availability.query['branchId'], _branchA);
      expect('${availability.query['partySize']}', '2');
    });

    test(
      'drops the previous list while the next request is in flight',
      () async {
        adapter.builder = (_) => _envelope(
          timezone: _zoneDamascus,
          slots: <Map<String, dynamic>>[
            _slot('2026-09-30T15:00:00.000Z', '2026-09-30T17:00:00.000Z'),
          ],
        );
        await _load(controller, branchId: _branchA);
        expect(controller.timeSlots, <String>['6:00 PM']);

        adapter.hold = Completer<void>();
        adapter.builder = (_) => _envelope(
          timezone: _zoneDamascus,
          slots: <Map<String, dynamic>>[
            _slot('2026-09-30T19:00:00.000Z', '2026-09-30T21:00:00.000Z'),
          ],
        );
        final Future<void> pending = controller.loadAvailabilitySlots();
        await Future<void>.delayed(Duration.zero);
        expect(controller.isLoadingSlots.value, isTrue);
        expect(controller.timeSlots, isEmpty);

        adapter.hold!.complete();
        await pending;
        expect(controller.timeSlots, <String>['10:00 PM']);
      },
    );

    test(
      'API failure clears slots and does not restore candidate times',
      () async {
        adapter.builder = (_) => _envelope(
          timezone: _zoneDamascus,
          slots: <Map<String, dynamic>>[
            _slot('2026-09-30T15:00:00.000Z', '2026-09-30T17:00:00.000Z'),
          ],
        );
        await _load(controller, branchId: _branchA);
        expect(controller.timeSlots, <String>['6:00 PM']);

        adapter.statusCode = 500;
        adapter.builder = (_) => <String, dynamic>{
          'success': false,
          'message': 'Server error',
          'code': 'INTERNAL_ERROR',
        };
        await controller.loadAvailabilitySlots();

        expect(controller.timeSlots, isEmpty);
        expect(controller.availabilitySlots, isEmpty);
        expect(controller.slotsError.value, isNotNull);
        for (final String retired in _retiredCandidateLabels) {
          expect(controller.timeSlots, isNot(contains(retired)));
        }
        expect(controller.timeSlots, isNot(contains('6:00 PM')));
      },
    );

    test('validation and network errors do not show slots', () async {
      adapter.statusCode = 400;
      adapter.builder = (_) => <String, dynamic>{
        'success': false,
        'message': 'date must be a valid calendar date',
        'code': 'VALIDATION_ERROR',
      };
      await _load(controller, branchId: _branchA);
      expect(controller.timeSlots, isEmpty);
      expect(controller.slotsError.value, 'date must be a valid calendar date');

      adapter.statusCode = 200;
      adapter.connectionError = true;
      await controller.loadAvailabilitySlots();
      expect(controller.timeSlots, isEmpty);
      expect(controller.slotsError.value, AppStrings.networkConnectionError);

      adapter.connectionError = false;
      adapter.builder = (_) => <String, dynamic>{
        'success': true,
        'message': 'ok',
        'data': <String, dynamic>{
          'timezone': _zoneDamascus,
          'outcome': 'AVAILABLE',
          'slots': <String>['19:30', '20:00', '20:30', '21:15'],
        },
      };
      await controller.loadAvailabilitySlots();
      expect(controller.timeSlots, isEmpty);
      expect(controller.slotsError.value, AppStrings.reservationSlotsLoadError);
    });

    test(
      'omits durationMinutes when the repository is asked not to send it',
      () async {
        adapter.builder = (_) => _envelope(
          timezone: _zoneDamascus,
          slots: const <Map<String, dynamic>>[],
        );
        await Get.find<ReservationRepository>().fetchAvailableSlots(
          branchId: _branchA,
          date: DateTime(2026, 9, 30),
          partySize: 2,
        );

        expect(
          adapter.calls.single.query.containsKey('durationMinutes'),
          isFalse,
        );
        expect(adapter.calls.single.query.keys.toList(), <String>[
          'branchId',
          'date',
          'partySize',
        ]);
      },
    );
  });
}

Future<void> _load(
  ReservationController controller, {
  required String branchId,
  DateTime? day,
}) async {
  controller.selectedDay.value = day ?? DateTime(2026, 9, 30);
  controller.branchId.value = branchId;
  await controller.loadAvailabilitySlots();
}

Future<void> _waitForCalls(
  _RecordingAdapter adapter,
  ReservationController controller,
  int count,
) async {
  for (int attempt = 0; attempt < 40; attempt++) {
    if (adapter.calls.length >= count && !controller.isLoadingSlots.value) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail(
    'expected $count calls, saw ${adapter.calls.length}, '
    'loading=${controller.isLoadingSlots.value}',
  );
}

Map<String, dynamic> _slot(String start, String end) {
  return <String, dynamic>{'startTime': start, 'endTime': end};
}

Map<String, dynamic> _slotAt(int index) {
  final DateTime start = DateTime.utc(
    2026,
    9,
    30,
    12,
  ).add(Duration(minutes: 15 * index));
  return _slot(
    start.toIso8601String(),
    start.add(const Duration(hours: 2)).toIso8601String(),
  );
}

Map<String, dynamic> _data({
  required String timezone,
  String outcome = AppStrings.apiReservationSlotsOutcomeAvailable,
  String openingTime = '18:00',
  String? closingTime = '23:00',
  int intervalMinutes = 30,
  int durationMinutes = 120,
  String date = '2026-09-30',
  String branchId = _branchA,
  List<Map<String, dynamic>> slots = const <Map<String, dynamic>>[],
}) {
  return <String, dynamic>{
    'branchId': branchId,
    'date': date,
    'timezone': timezone,
    'dayOfWeek': 3,
    'openingTime': openingTime,
    'closingTime': closingTime,
    'intervalMinutes': intervalMinutes,
    'durationMinutes': durationMinutes,
    'outcome': outcome,
    'slots': slots,
  };
}

Map<String, dynamic> _envelope({
  required String timezone,
  String outcome = AppStrings.apiReservationSlotsOutcomeAvailable,
  String openingTime = '18:00',
  int intervalMinutes = 30,
  int durationMinutes = 120,
  String date = '2026-09-30',
  String branchId = _branchA,
  List<Map<String, dynamic>> slots = const <Map<String, dynamic>>[],
}) {
  return <String, dynamic>{
    'success': true,
    'message': 'Available reservation slots retrieved successfully.',
    'data': _data(
      timezone: timezone,
      outcome: outcome,
      openingTime: openingTime,
      intervalMinutes: intervalMinutes,
      durationMinutes: durationMinutes,
      date: date,
      branchId: branchId,
      slots: slots,
    ),
    'meta': <String, dynamic>{},
  };
}

class _TokenReader implements AuthTokenReader {
  const _TokenReader();

  @override
  Future<String?> readAccessToken() async => 'access-token';
}

class _RecordedCall {
  const _RecordedCall(this.path, this.query);

  final String path;
  final Map<String, dynamic> query;
}

class _RecordingAdapter implements HttpClientAdapter {
  Map<String, dynamic> Function(Map<String, dynamic> query)? builder;
  Map<String, dynamic>? availabilityBody;
  int statusCode = 200;
  bool connectionError = false;
  Completer<void>? hold;
  final List<_RecordedCall> calls = <_RecordedCall>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final Completer<void>? gate = hold;
    calls.add(
      _RecordedCall(
        options.path,
        Map<String, dynamic>.from(options.queryParameters),
      ),
    );
    if (gate != null) {
      await gate.future;
    }
    if (connectionError) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }

    final bool availability =
        options.path == AppUrls.reservationsAvailabilityPath;
    final Map<String, dynamic> body = availability
        ? (availabilityBody ??
              <String, dynamic>{
                'success': true,
                'data': <String, dynamic>{'items': <Map<String, dynamic>>[]},
              })
        : (builder?.call(Map<String, dynamic>.from(options.queryParameters)) ??
              _envelope(timezone: _zoneDamascus));
    if (!availability && statusCode >= 400) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: statusCode,
          data: body,
        ),
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      availability ? 200 : statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
