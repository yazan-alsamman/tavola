import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/reservation/model/reservation_time_window.dart';
import 'package:tavla/features/reservation/repository/reservation_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test(
    'searchAvailability without token throws ApiException.authRequired',
    () async {
      Get.testMode = true;
      Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));

      final ReservationRepository repo = ReservationRepository(
        Get.find<ApiClient>(),
      );

      expect(
        () => repo.searchAvailability(
          ReservationTimeWindow(
            branchId: 'branch-1',
            startTime: DateTime.utc(2026, 7, 28, 18),
            endTime: DateTime.utc(2026, 7, 28, 20),
            partySize: 2,
          ),
        ),
        throwsA(
          isA<ApiException>()
              .having(
                (ApiException e) => e.message,
                'message',
                AppStrings.authSignInRequired,
              )
              .having((ApiException e) => e.statusCode, 'statusCode', 401),
        ),
      );
    },
  );
}
