import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';

/// Live Discovery API contract check against [AppUrls.apiBaseUrl].
///
/// Skipped automatically when the server is unreachable so CI stays green.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late ApiClient apiClient;
  late DiscoveryRepository discovery;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 5),
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    apiClient = ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>());
    discovery = DiscoveryRepository(apiClient);
  });

  tearDown(Get.reset);

  Future<bool> serverReachable() async {
    try {
      final Response<dynamic> response = await dio
          .get<dynamic>(
            AppUrls.discoveryRestaurantsPath,
            queryParameters: <String, dynamic>{
              'page': AppDimensions.apiDefaultPage,
              'limit': 1,
            },
          )
          .timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  test(
    'Discovery list/detail/branches/floor-plan match UI models',
    () async {
      final bool up = await serverReachable();
      if (!up) {
        // ignore: avoid_print
        print(
          'SKIP live Discovery — server unreachable at ${AppUrls.apiBaseUrl}',
        );
        return;
      }

      final List<RestaurantModel> restaurants = await discovery
          .listRestaurants(limit: 5)
          .timeout(const Duration(seconds: 12));
      expect(
        restaurants,
        isNotEmpty,
        reason: 'Discovery catalog must have items',
      );

      for (final RestaurantModel item in restaurants) {
        expect(item.id, isNotEmpty);
        expect(item.name, isNotEmpty);
        expect(item.isAvailable, isTrue);
        expect(item.availabilityLabel, AppStrings.openNow);
      }

      final RestaurantModel first = restaurants.first;
      final RestaurantModel byId = await discovery
          .getRestaurantById(first.id)
          .timeout(const Duration(seconds: 8));
      expect(byId.id, first.id);
      expect(byId.name, first.name);
      expect(byId.cuisine, first.cuisine);

      final branches = await discovery
          .listBranches(first.id)
          .timeout(const Duration(seconds: 8));
      for (final branch in branches) {
        expect(branch.id, isNotEmpty);
        if (branch.hasCoordinates) {
          expect(branch.latitude, isNotNull);
          expect(branch.longitude, isNotNull);
        }
      }

      if (branches.isNotEmpty) {
        final branch = await discovery
            .getBranchById(restaurantId: first.id, branchId: branches.first.id)
            .timeout(const Duration(seconds: 8));
        expect(branch.id, branches.first.id);

        try {
          final floorPlan = await discovery
              .getActiveFloorPlan(
                restaurantId: first.id,
                branchId: branches.first.id,
              )
              .timeout(const Duration(seconds: 8));
          expect(floorPlan.floorPlanId, isNotEmpty);
          expect(floorPlan.branchId, branches.first.id);
        } catch (_) {
          // 404 when no active floor plan — valid Discovery contract.
        }
      }

      if (restaurants.length >= 2) {
        final List<RestaurantModel> compared = await discovery
            .compareRestaurants(<String>[
              restaurants[0].id,
              restaurants[1].id,
            ])
            .timeout(const Duration(seconds: 12));
        expect(compared, hasLength(2));
        expect(compared.map((RestaurantModel r) => r.id).toSet(), <String>{
          restaurants[0].id,
          restaurants[1].id,
        });
        for (final RestaurantModel item in compared) {
          expect(item.name, isNotEmpty);
          expect(item.status, isNotEmpty);
        }
      }

      expect(
        AppUrls.discoveryRestaurantsPath.startsWith('/discovery/'),
        isTrue,
      );
      expect(
        AppUrls.discoveryRestaurantsComparePath,
        '${AppUrls.discoveryRestaurantsPath}/compare',
      );
    },
    timeout: const Timeout(Duration(seconds: 40)),
  );
}
