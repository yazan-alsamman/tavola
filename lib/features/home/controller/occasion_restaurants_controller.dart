import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../taxonomy/model/occasion_category_model.dart';
import '../model/occasion_restaurants_route_args.dart';
import '../model/restaurant_model.dart';

/// Restaurants assigned to one occasion via `GET /discovery/restaurants?occasionId=`.
class OccasionRestaurantsController extends GetxController {
  OccasionRestaurantsController({
    DiscoveryRepository? discoveryRepository,
    OccasionCategoryModel? category,
  }) : _discoveryRepository =
           discoveryRepository ?? Get.find<DiscoveryRepository>(),
       _categoryOverride = category;

  final DiscoveryRepository _discoveryRepository;
  final OccasionCategoryModel? _categoryOverride;

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  OccasionCategoryModel? _category;
  Future<void>? _activeLoad;

  OccasionCategoryModel? get category => _category;

  String get title {
    final OccasionCategoryModel? current = _category;
    if (current == null) {
      return '';
    }
    return AppStrings.localizeUiLabel(current.name, alternate: current.slug);
  }

  static void open(OccasionCategoryModel category) {
    final String id = category.id.trim();
    if (id.isEmpty) {
      return;
    }
    AppNavigation.pushOnce(
      AppRoutes.occasionRestaurants,
      arguments: OccasionRestaurantsRouteArgs(category: category),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _category = _categoryOverride ?? _categoryFromRoute();
    unawaited(load());
  }

  Future<void> load() {
    final Future<void>? active = _activeLoad;
    if (active != null) {
      return active;
    }
    final Future<void> run = _loadOnce();
    _activeLoad = run;
    return run.whenComplete(() {
      if (identical(_activeLoad, run)) {
        _activeLoad = null;
      }
    });
  }

  Future<void> _loadOnce() async {
    final String occasionId = _category?.id.trim() ?? '';
    if (occasionId.isEmpty) {
      restaurants.clear();
      errorMessage.value = AppStrings.networkUnexpectedError;
      isLoading.value = false;
      return;
    }

    if (restaurants.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = null;
    try {
      final List<RestaurantModel> items = await _discoveryRepository
          .listRestaurants(occasionId: occasionId, forceRefresh: true)
          .timeout(AppDimensions.homeCatalogLoadTimeout);
      if (isClosed) {
        return;
      }
      restaurants.assignAll(items);
    } on TimeoutException {
      if (!isClosed && restaurants.isEmpty) {
        errorMessage.value = AppStrings.networkTimeoutError;
      }
    } on ApiException catch (error) {
      if (!isClosed && restaurants.isEmpty && !error.isCancelled) {
        errorMessage.value = error.message;
      }
    } catch (_) {
      if (!isClosed && restaurants.isEmpty) {
        errorMessage.value = AppStrings.networkUnexpectedError;
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  OccasionCategoryModel? _categoryFromRoute() {
    final Object? args = Get.arguments;
    if (args is OccasionRestaurantsRouteArgs) {
      return args.category;
    }
    return null;
  }
}
