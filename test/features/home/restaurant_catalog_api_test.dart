import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/branches/model/branch_model.dart';
import 'package:tavla/features/branches/repository/branch_repository.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/reservation/model/restaurant_table_model.dart';
import 'package:tavla/features/reservation/repository/table_repository.dart';

class _StaticTokenReader implements AuthTokenReader {
  const _StaticTokenReader(this.token);
  final String token;
  @override
  Future<String?> readAccessToken() async => token;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio mockDio;
  late ApiClient apiClient;
  late List<String> hits;

  setUp(() {
    Get.reset();
    hits = <String>[];
    Get.put<AuthTokenReader>(const _StaticTokenReader('test-token'));
    mockDio = Dio(
      BaseOptions(
        baseUrl: AppUrls.apiBaseUrl,
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    mockDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          hits.add(options.path);
          if (options.path.startsWith(AppUrls.discoveryRestaurantsPath)) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'items': <dynamic>[],
                    'page': 1,
                    'limit': 20,
                    'total': 0,
                  },
                },
              ),
            );
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: 'Unexpected path ${options.path}',
            ),
          );
        },
      ),
    );
    apiClient = ApiClient(
      dio: mockDio,
      tokenReader: Get.find<AuthTokenReader>(),
    );
    Get.put(apiClient);
  });

  tearDown(Get.reset);

  test('DI wires Discovery for home/details/map/select-restaurant', () {
    AppDependency.ensureHomeDependencies();
    AppDependency.ensureDetailsDependencies();
    AppDependency.ensureMapDependencies();
    AppDependency.ensureSelectRestaurantDependencies();
    AppDependency.ensureProfileDependencies();
    expect(Get.isRegistered<DiscoveryRepository>(), isTrue);
    expect(Get.isRegistered<ApiClient>(), isTrue);
  });

  test('BranchRepository uses Discovery paths only', () async {
    AppDependency.ensureDiscoveryRepository();
    final BranchRepository repository = BranchRepository(
      Get.find<DiscoveryRepository>(),
    );
    final List<BranchModel> branches = await repository.listBranches('r1');
    expect(branches, isEmpty);
    expect(
      hits.any((String p) => p.contains('/discovery/restaurants')),
      isTrue,
    );
    expect(
      hits.any(
        (String p) =>
            p.contains('/restaurants') && !p.contains('/discovery/restaurants'),
      ),
      isFalse,
    );
  });

  test('TableRepository fetchTableById stays on /tables/:id', () async {
    mockDio.interceptors.clear();
    mockDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          hits.add(options.path);
          if (options.path.contains('/tables/') &&
              !options.path.contains('/branches/')) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'tableId': 't1',
                    'tableNumber': 'A1',
                    'capacity': 4,
                    'status': 'Available',
                    'positionX': 10,
                    'positionY': 20,
                  },
                },
              ),
            );
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: 'Unexpected path',
            ),
          );
        },
      ),
    );

    AppDependency.ensureDiscoveryRepository();
    final TableRepository repository = TableRepository(
      apiClient,
      BranchRepository(Get.find<DiscoveryRepository>()),
      discoveryRepository: Get.find<DiscoveryRepository>(),
    );

    final RestaurantTableModel byId = await repository.fetchTableById('t1');
    expect(byId.id, 't1');
    expect(hits, contains('/tables/t1'));
    expect(
      hits.any(
        (String p) =>
            p.contains('/restaurants') && !p.contains('/discovery/restaurants'),
      ),
      isFalse,
    );
  });
}
