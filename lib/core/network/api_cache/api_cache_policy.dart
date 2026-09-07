import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_cache/api_cache_config.dart';

/// Decides whether a request is eligible for HTTP response caching.
abstract final class ApiCachePolicy {
  /// Overridable for tests (`() => true` to simulate web).
  static bool Function() isWeb = () => kIsWeb;

  static bool shouldCache(RequestOptions options) {
    if (options.method.toUpperCase() != 'GET') return false;

    final responseType = options.responseType;
    if (responseType == ResponseType.bytes ||
        responseType == ResponseType.stream) {
      return false;
    }

    final path = _normalizedPath(options);
    if (_isAuthPath(path)) return false;

    if (isWeb()) {
      return ApiCacheConfig.webHomePathMarkers.any(path.contains);
    }

    return ApiCacheConfig.isNativeCacheEnabled;
  }

  static String cacheKey(RequestOptions options) {
    final path = _normalizedPath(options);
    final query = _sortedQuery(options);
    return '${options.method.toUpperCase()}|$path|$query';
  }

  static String _normalizedPath(RequestOptions options) {
    final uri = options.uri;
    var path = uri.path;
    if (path.isEmpty) {
      path = options.path;
      final q = path.indexOf('?');
      if (q >= 0) path = path.substring(0, q);
      try {
        final asUri = Uri.parse(path);
        if (asUri.hasScheme) path = asUri.path;
      } catch (_) {}
    }
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }

  static String _sortedQuery(RequestOptions options) {
    final params = <String, dynamic>{
      ...options.uri.queryParameters,
      ...options.queryParameters,
    };
    if (params.isEmpty) return '';
    final keys = params.keys.map((k) => k.toString()).toList()..sort();
    return keys.map((k) => '$k=${params[k]}').join('&');
  }

  static bool _isAuthPath(String path) {
    return path.contains('/auth/') || path.contains('/verification/');
  }

  @visibleForTesting
  static void resetForTests() {
    isWeb = () => kIsWeb;
  }
}
