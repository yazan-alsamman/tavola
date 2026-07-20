import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/search_bar.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../controller/restaurant_map_controller.dart';
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
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(
                AppDimensions.mapInitialLatitude,
                AppDimensions.mapInitialLongitude,
              ),
              initialZoom: AppDimensions.mapInitialZoom,
              onTap: (_, _) => controller.clearSelection(),
            ),
            children: [
              TileLayer(
                urlTemplate: AppUrls.openStreetMapTiles,
                userAgentPackageName: AppUrls.mapUserAgent,
              ),
              Obx(
                () => MarkerLayer(
                  markers: controller.filteredLocations.map((location) {
                    return Marker(
                      point: LatLng(location.latitude, location.longitude),
                      width: AppDimensions.mapMarkerSize,
                      height: AppDimensions.mapMarkerSize,
                      child: ShiningRestaurantMarker(
                        restaurantName: location.restaurant.name,
                        onTap: () =>
                            controller.selectRestaurant(location.restaurant),
                      ),
                    );
                  }).toList(),
                ),
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(AppStrings.openStreetMapContributors),
                ],
              ),
            ],
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
                child: CustomSearchBar(
                  controller: controller.searchController,
                  hintText: AppStrings.mapSearchHint,
                  onChanged: controller.updateSearch,
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
}
