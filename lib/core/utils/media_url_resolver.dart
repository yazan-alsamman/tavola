import '../constants/app_strings.dart';
import '../constants/app_urls.dart';
import '../network/api_exception.dart';

/// Resolves API media fields (absolute URLs, relative paths, nested maps, file IDs)
/// into displayable network image URLs for [AppSafeImage].
class MediaUrlResolver {
  MediaUrlResolver._();

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Extracts and normalizes an image URL from a JSON field or nested media object.
  static String resolve(Object? raw) {
    if (raw == null) {
      return '';
    }
    if (raw is String) {
      return normalize(raw);
    }
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      for (final String key in const <String>[
        AppStrings.apiMediaFieldUrl,
        AppStrings.apiMediaFieldPublicUrl,
        AppStrings.apiMediaFieldSecureUrl,
        AppStrings.apiMediaFieldImageUrl,
        AppStrings.apiMediaFieldSrc,
        AppStrings.apiMediaFieldPath,
        AppStrings.apiAvatarFieldAvatarUrl,
        'coverImageUrl',
        'logoUrl',
        'thumbnailUrl',
      ]) {
        final String nested = normalize(ApiException.coerceString(map[key]));
        if (nested.isNotEmpty) {
          return nested;
        }
      }
      for (final String key in const <String>[
        AppStrings.apiMediaFieldFileId,
        'coverImageId',
        'logoId',
        'imageId',
        'mediaId',
        'id',
      ]) {
        final String id = ApiException.coerceString(map[key]).trim();
        if (id.isNotEmpty) {
          final String fromId = fromFileId(id);
          if (fromId.isNotEmpty) {
            return fromId;
          }
        }
      }
    }
    return '';
  }

  /// Turns a stored path / URL / file id into an absolute http(s) URL.
  static String normalize(String? raw) {
    final String value = (raw ?? '').trim();
    if (value.isEmpty) {
      return '';
    }
    if (value.startsWith(AppStrings.apiHttpSchemePrefix) ||
        value.startsWith(AppStrings.apiHttpsSchemePrefix)) {
      return value;
    }
    if (value.startsWith('//')) {
      final Uri base = Uri.parse(AppUrls.apiBaseUrl);
      final String scheme = base.scheme.isNotEmpty
          ? base.scheme
          : AppStrings.apiHttpsSchemePrefix.replaceAll(':', '');
      return '$scheme:$value';
    }
    if (_uuidPattern.hasMatch(value)) {
      return fromFileId(value);
    }
    final Uri base = Uri.parse(AppUrls.apiBaseUrl);
    final String origin = '${base.scheme}://${base.authority}';
    if (value.startsWith('/')) {
      return '$origin$value';
    }
    // Relative storage keys (e.g. `uploads/abc.jpg`) attach to API origin.
    if (value.contains('/') || value.contains('.')) {
      return '$origin/$value';
    }
    // Opaque non-UUID tokens are not inventable as file URLs.
    return '';
  }

  /// Builds a production file URL for a media/file identifier.
  static String fromFileId(String fileId) {
    final String id = fileId.trim();
    if (id.isEmpty) {
      return '';
    }
    if (id.startsWith(AppStrings.apiHttpSchemePrefix) ||
        id.startsWith(AppStrings.apiHttpsSchemePrefix)) {
      return id;
    }
    final String mediaBase = AppUrls.mediaBaseUrl.trim();
    if (mediaBase.isNotEmpty) {
      final String trimmedBase = mediaBase.endsWith('/')
          ? mediaBase.substring(0, mediaBase.length - 1)
          : mediaBase;
      final String path = id.startsWith('/') ? id.substring(1) : id;
      return '$trimmedBase/$path';
    }
    final Uri api = Uri.parse(AppUrls.apiBaseUrl);
    final String origin = '${api.scheme}://${api.authority}';
    final String apiPath = api.path.endsWith('/')
        ? api.path.substring(0, api.path.length - 1)
        : api.path;
    return '$origin$apiPath${AppUrls.mediaFilePath(id)}';
  }
}
