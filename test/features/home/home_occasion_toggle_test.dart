import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('selectOccasion toggles off when tapped again', () {
    Get.testMode = true;
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
    Get.put(UsersRepository(Get.find<ApiClient>()));
    Get.put(
      FavoritesRepository(usersRepository: Get.find<UsersRepository>()),
    );
    Get.put(TaxonomyRepository(Get.find<ApiClient>()));
    Get.put(DiscoveryRepository(Get.find<ApiClient>()));

    final HomeController controller = HomeController();
    controller.selectOccasion('Date night');
    expect(controller.selectedOccasion.value, 'Date night');

    controller.selectOccasion('Date night');
    expect(controller.selectedOccasion.value, isNull);

    controller.selectOccasion('Family');
    expect(controller.selectedOccasion.value, 'Family');
    controller.selectOccasion('Date night');
    expect(controller.selectedOccasion.value, 'Date night');
  });
}
