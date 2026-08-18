import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/details/repository/menu_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('getDefaultMenu parses nested categories and items', () async {
    Get.testMode = true;
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          expect(options.path.contains('/menus/default'), isTrue);
          expect(options.headers['Authorization'], isNull);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'Menu retrieved successfully.',
                'data': <String, dynamic>{
                  'id': 'menu-1',
                  'restaurantId': 'rest-1',
                  'name': 'Main Menu',
                  'active': true,
                  'isDefault': true,
                  'displayOrder': 0,
                  'categories': <dynamic>[
                    <String, dynamic>{
                      'id': 'cat-1',
                      'name': 'Starters',
                      'displayOrder': 0,
                      'items': <dynamic>[
                        <String, dynamic>{
                          'id': 'item-1',
                          'name': 'Shrimp Cocktail',
                          'description': 'Chilled shrimp',
                          'price': 14,
                          'currency': null,
                          'displayOrder': 0,
                        },
                      ],
                    },
                  ],
                },
              },
            ),
          );
        },
      ),
    );

    final MenuRepository repo = MenuRepository(
      ApiClient(dio: dio, tokenReader: const EmptyAuthTokenReader()),
    );
    final menu = await repo.getDefaultMenu('rest-1');
    expect(menu.name, 'Main Menu');
    expect(menu.categories, hasLength(1));
    expect(menu.categories.first.name, 'Starters');
    expect(menu.flatItems.single.name, 'Shrimp Cocktail');
    expect(menu.flatItems.single.price, '14');
  });

  test('listMenus parses summary array', () async {
    Get.testMode = true;
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'Menus retrieved successfully.',
                'data': <dynamic>[
                  <String, dynamic>{
                    'id': 'menu-1',
                    'restaurantId': 'rest-1',
                    'name': 'Main Menu',
                    'active': true,
                    'isDefault': true,
                    'displayOrder': 0,
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    final MenuRepository repo = MenuRepository(
      ApiClient(dio: dio, tokenReader: const EmptyAuthTokenReader()),
    );
    final menus = await repo.listMenus('rest-1');
    expect(menus.single.id, 'menu-1');
    expect(menus.single.isDefault, isTrue);
  });

  test('getCategoryById and getItemById hit Postman category/item paths', () async {
    Get.testMode = true;
    String? categoryPath;
    String? itemPath;
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (options.path.contains('/categories/') &&
              !options.path.contains('/items/')) {
            categoryPath = options.path;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'id': 'cat-1',
                    'name': 'Starters',
                    'displayOrder': 0,
                    'items': <dynamic>[],
                  },
                },
              ),
            );
            return;
          }
          if (options.path.contains('/items/')) {
            itemPath = options.path;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'id': 'item-1',
                    'name': 'Shrimp Cocktail',
                    'description': 'Chilled shrimp',
                    'price': 14,
                  },
                },
              ),
            );
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );
    final MenuRepository repo = MenuRepository(
      ApiClient(dio: dio, tokenReader: const EmptyAuthTokenReader()),
    );

    final category = await repo.getCategoryById(
      restaurantId: 'rest-1',
      menuId: 'menu-1',
      categoryId: 'cat-1',
    );
    final item = await repo.getItemById(
      restaurantId: 'rest-1',
      menuId: 'menu-1',
      categoryId: 'cat-1',
      itemId: 'item-1',
    );

    expect(
      categoryPath,
      AppUrls.restaurantMenuCategoryPath(
        restaurantId: 'rest-1',
        menuId: 'menu-1',
        categoryId: 'cat-1',
      ),
    );
    expect(
      itemPath,
      AppUrls.restaurantMenuItemPath(
        restaurantId: 'rest-1',
        menuId: 'menu-1',
        categoryId: 'cat-1',
        itemId: 'item-1',
      ),
    );
    expect(category.name, 'Starters');
    expect(item.id, 'item-1');
  });
}
