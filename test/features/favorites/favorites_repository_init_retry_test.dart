import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('retries initialization when token appears after startup', () async {
    final _MutableTokenReader tokenReader = _MutableTokenReader();
    final _MutableGuestMode guestMode = _MutableGuestMode();
    final _FakeUsersRepository users = _FakeUsersRepository();

    Get.put<AuthTokenReader>(tokenReader);
    Get.put<GuestModeReader>(guestMode);

    final FavoritesRepository repo = FavoritesRepository(
      usersRepository: users,
    );

    await repo.ensureInitialized();
    expect(users.fetchCount, 0);

    tokenReader.token = 'access-token';
    await repo.ensureInitialized();

    expect(users.fetchCount, 1);
    expect(repo.isFavorite('r-1'), isTrue);
  });

  test('unauthorized sync does not lock later successful retry', () async {
    final _MutableTokenReader tokenReader = _MutableTokenReader(
      token: 'access-token',
    );
    final _MutableGuestMode guestMode = _MutableGuestMode();
    final _FakeUsersRepository users = _FakeUsersRepository(
      failUnauthorized: true,
    );

    Get.put<AuthTokenReader>(tokenReader);
    Get.put<GuestModeReader>(guestMode);

    final FavoritesRepository repo = FavoritesRepository(
      usersRepository: users,
    );

    await repo.ensureInitialized();
    expect(users.fetchCount, 1);
    expect(repo.isFavorite('r-1'), isFalse);

    users.failUnauthorized = false;
    await repo.ensureInitialized();

    expect(users.fetchCount, 2);
    expect(repo.isFavorite('r-1'), isTrue);
  });

  test('guest init does not block sync after sign-in', () async {
    final _MutableTokenReader tokenReader = _MutableTokenReader(
      token: 'access-token',
    );
    final _MutableGuestMode guestMode = _MutableGuestMode(
      isAnonymousGuest: true,
    );
    final _FakeUsersRepository users = _FakeUsersRepository();

    Get.put<AuthTokenReader>(tokenReader);
    Get.put<GuestModeReader>(guestMode);

    final FavoritesRepository repo = FavoritesRepository(
      usersRepository: users,
    );

    await repo.ensureInitialized();
    expect(users.fetchCount, 0);

    guestMode.isAnonymousGuest = false;
    await repo.ensureInitialized();

    expect(users.fetchCount, 1);
    expect(repo.isFavorite('r-1'), isTrue);
  });

  test('watchFavorites schedules deferred init retry automatically', () async {
    final _MutableTokenReader tokenReader = _MutableTokenReader();
    final _MutableGuestMode guestMode = _MutableGuestMode();
    final _FakeUsersRepository users = _FakeUsersRepository();

    Get.put<AuthTokenReader>(tokenReader);
    Get.put<GuestModeReader>(guestMode);

    final FavoritesRepository repo = FavoritesRepository(
      usersRepository: users,
    );

    await repo.ensureInitialized();
    expect(users.fetchCount, 0);

    tokenReader.token = 'access-token';
    repo.watchFavorites();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(users.fetchCount, 1);
    expect(repo.isFavorite('r-1'), isTrue);
  });
}

class _MutableTokenReader implements AuthTokenReader {
  _MutableTokenReader({this.token});

  String? token;

  @override
  Future<String?> readAccessToken() async => token;
}

class _MutableGuestMode implements GuestModeReader {
  _MutableGuestMode({this.isAnonymousGuest = false});

  @override
  bool isAnonymousGuest;
}

class _FakeUsersRepository extends UsersRepository {
  _FakeUsersRepository({this.failUnauthorized = false})
    : super(ApiClient(tokenReader: const EmptyAuthTokenReader()));

  int fetchCount = 0;
  bool failUnauthorized;

  @override
  Future<List<RestaurantModel>> fetchFavoriteRestaurants({
    int page = 1,
    int limit = 20,
  }) async {
    fetchCount++;
    if (failUnauthorized) {
      throw ApiException.authRequired();
    }
    return const <RestaurantModel>[
      RestaurantModel(
        id: 'r-1',
        name: 'Olive & Oak',
        cuisine: 'Mediterranean',
        occasion: '',
        description: '',
        imageUrl: '',
        location: '',
        availabilityLabel: 'Open now',
        isAvailable: true,
      ),
    ];
  }
}
