import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/utils/media_url_resolver.dart';

void main() {
  test('normalize keeps absolute https URLs', () {
    expect(
      MediaUrlResolver.normalize('https://cdn.example/a.jpg'),
      'https://cdn.example/a.jpg',
    );
  });

  test('normalize resolves relative API paths', () {
    final String url = MediaUrlResolver.normalize('/uploads/cover.jpg');
    expect(url.startsWith('https://'), isTrue);
    expect(url.endsWith('/uploads/cover.jpg'), isTrue);
  });

  test('fromFileId builds versioned files path', () {
    const String id = '11111111-1111-1111-1111-111111111111';
    expect(
      MediaUrlResolver.fromFileId(id),
      '${AppUrls.apiBaseUrl}${AppUrls.mediaFilePath(id)}',
    );
  });

  test('resolve reads nested media maps and ids', () {
    expect(
      MediaUrlResolver.resolve(<String, dynamic>{
        'url': 'https://cdn.example/nested.jpg',
      }),
      'https://cdn.example/nested.jpg',
    );
    expect(
      MediaUrlResolver.resolve(<String, dynamic>{
        'coverImageId': '22222222-2222-2222-2222-222222222222',
      }),
      '${AppUrls.apiBaseUrl}${AppUrls.mediaFilePath('22222222-2222-2222-2222-222222222222')}',
    );
  });
}
