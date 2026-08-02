import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/utils/post_frame_work.dart';
import 'package:tavla/features/favorites/controller/favorites_controller.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets(
    'FavoritesController does not start sync during Binding/onInit frame',
    (tester) async {
      Get.testMode = true;
      Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
      Get.put(UsersRepository(Get.find<ApiClient>()));
      final FavoritesRepository favorites = FavoritesRepository(
        usersRepository: Get.find<UsersRepository>(),
      );
      Get.put(favorites);

      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));

      final FavoritesController controller = Get.put(FavoritesController());

      // Immediately after put: still waiting for the post-frame kickoff.
      expect(controller.isLoadingFavorites.value, isTrue);
      expect(favorites.isSyncing.value, isFalse);

      await tester.pump();
      // Post-frame scheduled loadFavorites → sync starts (or completes).
      expect(
        favorites.isSyncing.value || !controller.isLoadingFavorites.value,
        isTrue,
      );

      // Drain Dio / FakeAsync timers from the test HTTP stack.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    },
  );

  test('PostFrameWork schedules after current frame', () {
    var ran = false;
    PostFrameWork.schedule(() => ran = true);
    expect(ran, isFalse);
  });
}
