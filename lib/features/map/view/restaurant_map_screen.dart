import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/search_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_urls.dart';
import '../controller/restaurant_map_controller.dart';
import '../model/restaurant_map_location.dart';
import '../widgets/map_restaurant_card.dart';
import '../widgets/shining_restaurant_marker.dart';

class RestaurantMapScreen extends StatelessWidget {
  const RestaurantMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RestaurantMapController controller =
        Get.find<RestaurantMapController>();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  controller.mapCenterLatitude,
                  controller.mapCenterLongitude,
                ),
                initialZoom: AppDimensions.mapInitialZoom,
                onTap: (_, _) => controller.clearSelection(),
              ),
              children: [
                TileLayer(
                  urlTemplate: AppUrls.mapRasterTiles,
                  userAgentPackageName: AppUrls.mapUserAgentPackageName,
                  errorTileCallback: (TileImage tile, Object error, StackTrace? _) {
                    // Swallow tile fetch noise; map stays interactive with markers.
                  },
                ),
                Obx(() {
                  final List<RestaurantMapLocation> locations =
                      controller.filteredLocations;
                  return MarkerLayer(
                    markers: locations
                        .where(_hasValidCoordinates)
                        .map(
                          (RestaurantMapLocation location) => Marker(
                            point: LatLng(
                              location.latitude,
                              location.longitude,
                            ),
                            width: AppDimensions.mapMarkerSize,
                            height: AppDimensions.mapMarkerSize,
                            child: ShiningRestaurantMarker(
                              restaurantName: location.restaurant.name,
                              onTap: () => controller.selectRestaurant(
                                location.restaurant,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                }),
                SimpleAttributionWidget(
                  source: Text(AppStrings.mapAttributionLabel),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: AppDimensions.pagePadding,
            start: AppDimensions.pagePadding,
            end: AppDimensions.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.mapCardMaxWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSearchBar(
                      controller: controller.searchController,
                      hintText: AppStrings.mapSearchHint,
                      onChanged: controller.updateSearch,
                    ),
                    Obx(() {
                      if (!controller.isLoadingLocations.value) {
                        return const SizedBox.shrink();
                      }
                      return const Padding(
                        padding: EdgeInsets.only(
                          top: AppDimensions.smallSpacing,
                        ),
                        child: LinearProgressIndicator(
                          minHeight: AppDimensions.progressIndicatorStrokeWidth,
                        ),
                      );
                    }),
                    Obx(() {
                      final String? error = controller.locationsError.value;
                      if (error == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: AppDimensions.smallSpacing,
                        ),
                        child: Material(
                          color: AppColors.surface,
                          elevation: AppDimensions.mapErrorCardElevation,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.cardRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.contentPadding,
                              vertical: AppDimensions.compactVerticalPadding,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    error,
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                HoverableButton(
                                  child: TextButton(
                                    onPressed: controller.loadMapLocations,
                                    style: TextButton.styleFrom(
                                      textStyle: AppTextStyles.authLinkEmphasis,
                                    ),
                                    child: Text(
                                      AppStrings.retry,
                                      style: AppTextStyles.authLinkEmphasis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: AppDimensions.pagePadding,
            end: AppDimensions.pagePadding,
            bottom: AppDimensions.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.mapCardMaxWidth,
                ),
                child: Obx(() {
                  final restaurant = controller.selectedRestaurant.value;
                  return AnimatedSwitcher(
                    duration: AppDimensions.hoverDuration,
                    child: restaurant == null
                        ? const SizedBox.shrink()
                        : MapRestaurantCard(
                            key: ValueKey(restaurant.id),
                            restaurant: restaurant,
                            isSaved: controller.isSaved(restaurant.id),
                            onSave: () => controller.toggleSaved(restaurant.id),
                            onReserve: () =>
                                controller.reserveTable(restaurant),
                            onViewDetails: () =>
                                controller.viewDetails(restaurant),
                          ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: RestaurantMapController.mapNavigationIndex,
        onTap: controller.handleBottomNavigation,
      ),
    );
  }

  static bool _hasValidCoordinates(RestaurantMapLocation location) {
    final double latitude = location.latitude;
    final double longitude = location.longitude;
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}
