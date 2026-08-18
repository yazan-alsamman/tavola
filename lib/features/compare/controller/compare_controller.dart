import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../details/controller/details_controller.dart';
import '../../details/model/restaurant_detail_model.dart';
import '../../details/repository/restaurant_details_repository.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../model/compare_restaurant_snapshot.dart';
import '../model/compare_route_args.dart';
import '../model/compare_row_model.dart';
import '../model/compare_table_builder.dart';
import '../widgets/compare_cards_entrance.dart';
import '../widgets/compare_restaurant_picker_sheet.dart';

enum CompareSide { a, b }

/// Compare Restaurants screen controller (route-scoped via [putFresh]).
///
/// Catalog picker uses Discovery list; side-by-side values come from
/// `POST /discovery/restaurants/compare` once both sides are selected.
class CompareController extends GetxController {
  CompareController({
    DiscoveryRepository? discoveryRepository,
    RestaurantDetailsRepository? detailsRepository,
  }) : _discoveryRepository =
           discoveryRepository ?? Get.find<DiscoveryRepository>(),
       _detailsRepository =
           detailsRepository ?? Get.find<RestaurantDetailsRepository>();

  final DiscoveryRepository _discoveryRepository;
  final RestaurantDetailsRepository _detailsRepository;

  final Rxn<RestaurantModel> restaurantA = Rxn<RestaurantModel>();
  final Rxn<RestaurantModel> restaurantB = Rxn<RestaurantModel>();
  final Rxn<RestaurantDetailModel> detailA = Rxn<RestaurantDetailModel>();
  final Rxn<RestaurantDetailModel> detailB = Rxn<RestaurantDetailModel>();

  final RxList<RestaurantModel> catalog = <RestaurantModel>[].obs;
  final RxBool isLoadingCatalog = false.obs;
  final RxBool isComparing = false.obs;
  final RxBool isLoadingSideA = false.obs;
  final RxBool isLoadingSideB = false.obs;
  final RxnString catalogError = RxnString();
  final RxnString compareError = RxnString();
  final RxnString sideAError = RxnString();
  final RxnString sideBError = RxnString();

  bool get hasBothSides =>
      restaurantA.value != null && restaurantB.value != null;

  CompareRestaurantSnapshot? get snapshotA {
    final RestaurantModel? restaurant = restaurantA.value;
    if (restaurant == null) {
      return null;
    }
    return CompareRestaurantSnapshot(
      restaurant: restaurant,
      detail: detailA.value,
    );
  }

  CompareRestaurantSnapshot? get snapshotB {
    final RestaurantModel? restaurant = restaurantB.value;
    if (restaurant == null) {
      return null;
    }
    return CompareRestaurantSnapshot(
      restaurant: restaurant,
      detail: detailB.value,
    );
  }

  List<CompareRowModel> get comparisonRows =>
      CompareTableBuilder.build(sideA: snapshotA, sideB: snapshotB);

  @override
  void onInit() {
    super.onInit();
    _bindRouteArgs();
    PostFrameWork.schedule(() {
      if (isClosed) {
        return;
      }
      unawaited(loadCatalog());
      final RestaurantModel? seed = restaurantA.value;
      if (seed != null) {
        unawaited(_loadDetailsFor(CompareSide.a, seed));
      }
    });
  }

  void _bindRouteArgs() {
    final Object? args = Get.arguments;
    if (args is CompareRouteArgs && args.seedRestaurant != null) {
      restaurantA.value = args.seedRestaurant;
      final RestaurantDetailModel cached = _detailsRepository.getDetails(
        args.seedRestaurant!.id,
      );
      if (cached.restaurantId == args.seedRestaurant!.id) {
        detailA.value = cached;
      }
    }
  }

  Future<void> loadCatalog({bool forceRefresh = false}) async {
    if (isClosed) {
      return;
    }
    catalogError.value = null;
    final List<RestaurantModel> cached =
        _discoveryRepository.cachedRestaurants ?? const <RestaurantModel>[];
    if (!forceRefresh && cached.isNotEmpty) {
      catalog.assignAll(cached);
      return;
    }

    isLoadingCatalog.value = true;
    try {
      final List<RestaurantModel> restaurants = await _discoveryRepository
          .listRestaurants(forceRefresh: forceRefresh);
      if (!isClosed) {
        catalog.assignAll(restaurants);
      }
    } on ApiException catch (error) {
      if (!isClosed) {
        catalogError.value = error.message;
        if (catalog.isEmpty && cached.isNotEmpty) {
          catalog.assignAll(cached);
        }
      }
    } catch (_) {
      if (!isClosed) {
        catalogError.value = AppStrings.compareCatalogLoadFailed;
        if (catalog.isEmpty && cached.isNotEmpty) {
          catalog.assignAll(cached);
        }
      }
    } finally {
      if (!isClosed) {
        isLoadingCatalog.value = false;
      }
    }
  }

  Future<void> openPicker(CompareSide side) async {
    if (catalog.isEmpty && !isLoadingCatalog.value) {
      await loadCatalog();
    }
    if (catalogError.value != null && catalog.isEmpty) {
      Get.snackbar(AppStrings.compareRestaurants, catalogError.value!);
      return;
    }

    final String? excludeId = side == CompareSide.a
        ? restaurantB.value?.id
        : restaurantA.value?.id;

    await CompareRestaurantPickerSheet.open(
      restaurants: catalog.toList(growable: false),
      isLoading: isLoadingCatalog.value,
      excludeRestaurantId: excludeId,
      onRetry: () => loadCatalog(forceRefresh: true),
      onSelected: (RestaurantModel restaurant) {
        unawaited(selectRestaurant(side, restaurant));
      },
    );
  }

  Future<void> selectRestaurant(
    CompareSide side,
    RestaurantModel restaurant,
  ) async {
    final String id = restaurant.id.trim();
    if (id.isEmpty) {
      return;
    }

    final String? otherId = side == CompareSide.a
        ? restaurantB.value?.id
        : restaurantA.value?.id;
    if (otherId != null && otherId == id) {
      Get.snackbar(
        AppStrings.compareRestaurants,
        AppStrings.compareSelectDifferentRestaurant,
      );
      return;
    }

    if (side == CompareSide.a) {
      restaurantA.value = restaurant;
      detailA.value = null;
      sideAError.value = null;
    } else {
      restaurantB.value = restaurant;
      detailB.value = null;
      sideBError.value = null;
    }

    if (hasBothSides) {
      await refreshComparison();
    } else {
      await _loadDetailsFor(side, restaurant);
    }
  }

  Future<void> clearSide(CompareSide side) async {
    compareError.value = null;
    CompareCardsEntrance.resetCompletedKey();
    if (side == CompareSide.a) {
      restaurantA.value = null;
      detailA.value = null;
      sideAError.value = null;
      isLoadingSideA.value = false;
      return;
    }
    restaurantB.value = null;
    detailB.value = null;
    sideBError.value = null;
    isLoadingSideB.value = false;
  }

  Future<void> retrySide(CompareSide side) async {
    if (hasBothSides) {
      await refreshComparison();
      return;
    }
    final RestaurantModel? restaurant = side == CompareSide.a
        ? restaurantA.value
        : restaurantB.value;
    if (restaurant == null) {
      return;
    }
    await _loadDetailsFor(side, restaurant);
  }

  /// Calls `POST /discovery/restaurants/compare` and maps items onto both sides.
  Future<void> refreshComparison() async {
    final RestaurantModel? a = restaurantA.value;
    final RestaurantModel? b = restaurantB.value;
    if (a == null || b == null || isClosed) {
      return;
    }

    isComparing.value = true;
    isLoadingSideA.value = true;
    isLoadingSideB.value = true;
    compareError.value = null;
    sideAError.value = null;
    sideBError.value = null;

    try {
      final List<RestaurantModel> compared = await _discoveryRepository
          .compareRestaurants(<String>[a.id, b.id]);
      if (isClosed) {
        return;
      }

      RestaurantModel? matchedA;
      RestaurantModel? matchedB;
      for (final RestaurantModel item in compared) {
        if (item.id == a.id) {
          matchedA = item;
        } else if (item.id == b.id) {
          matchedB = item;
        }
      }

      if (matchedA == null || matchedB == null) {
        compareError.value = AppStrings.compareApiLoadFailed;
        return;
      }

      restaurantA.value = _preserveLocalImage(matchedA, a);
      restaurantB.value = _preserveLocalImage(matchedB, b);

      await Future.wait<void>(<Future<void>>[
        _loadDetailsFor(CompareSide.a, restaurantA.value!),
        _loadDetailsFor(CompareSide.b, restaurantB.value!),
      ]);
    } on ApiException catch (error) {
      if (!isClosed) {
        compareError.value = error.message;
      }
    } catch (_) {
      if (!isClosed) {
        compareError.value = AppStrings.compareApiLoadFailed;
      }
    } finally {
      if (!isClosed) {
        isComparing.value = false;
        isLoadingSideA.value = false;
        isLoadingSideB.value = false;
      }
    }
  }

  /// Compare DTO has image IDs only; keep a prior URL from catalog/details.
  RestaurantModel _preserveLocalImage(
    RestaurantModel fromCompare,
    RestaurantModel previous,
  ) {
    if (fromCompare.imageUrl.trim().isNotEmpty) {
      return fromCompare;
    }
    final String previousUrl = previous.imageUrl.trim();
    if (previousUrl.isEmpty) {
      return fromCompare;
    }
    return fromCompare.copyWith(imageUrl: previousUrl);
  }

  Future<void> _loadDetailsFor(
    CompareSide side,
    RestaurantModel restaurant,
  ) async {
    final String id = restaurant.id.trim();
    if (id.isEmpty) {
      return;
    }

    final RestaurantDetailModel cached = _detailsRepository.getDetails(id);
    if (cached.restaurantId == id &&
        (cached.hasWorkingHours || cached.openingHours.isNotEmpty)) {
      _assignDetail(side, cached);
    }

    try {
      final RestaurantDetailModel detail = await _detailsRepository
          .fetchDetails(id);
      if (isClosed) {
        return;
      }
      _assignDetail(side, detail);
      _mergeImageFromDetail(side, detail);
    } on ApiException catch (error) {
      if (!isClosed) {
        _assignSideError(side, error.message);
      }
    } catch (_) {
      if (!isClosed) {
        _assignSideError(side, AppStrings.compareDetailsLoadFailed);
      }
    }
  }

  void _assignDetail(CompareSide side, RestaurantDetailModel detail) {
    if (side == CompareSide.a) {
      detailA.value = detail;
    } else {
      detailB.value = detail;
    }
  }

  void _assignSideError(CompareSide side, String message) {
    if (side == CompareSide.a) {
      sideAError.value = message;
    } else {
      sideBError.value = message;
    }
  }

  void _mergeImageFromDetail(CompareSide side, RestaurantDetailModel detail) {
    final RestaurantModel? current = side == CompareSide.a
        ? restaurantA.value
        : restaurantB.value;
    if (current == null) {
      return;
    }
    if (current.imageUrl.trim().isNotEmpty) {
      return;
    }
    if (detail.galleryImageUrls.isEmpty) {
      return;
    }
    final RestaurantModel merged = current.copyWith(
      imageUrl: detail.galleryImageUrls.first,
    );
    if (side == CompareSide.a) {
      restaurantA.value = merged;
    } else {
      restaurantB.value = merged;
    }
  }

  void goBack() {
    Get.back<void>();
  }

  void openDetails(CompareSide side) {
    final RestaurantModel? restaurant = side == CompareSide.a
        ? restaurantA.value
        : restaurantB.value;
    if (restaurant == null || restaurant.id.trim().isEmpty) {
      return;
    }
    DetailsController.open(restaurant);
  }

  /// Opens Compare from Details with the current restaurant as side A.
  static void open({RestaurantModel? seedRestaurant}) {
    AppNavigation.pushOnce(
      AppRoutes.compareRestaurants,
      arguments: CompareRouteArgs(seedRestaurant: seedRestaurant),
    );
  }
}
