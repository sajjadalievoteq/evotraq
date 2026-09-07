import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_cache/api_cache_policy.dart';
import 'package:traqtrace_app/core/network/api_cache/api_cache_store.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';

/// Cache-first GET interceptor.
///
/// Fresh cache → return immediately.
/// Miss / expired → network, then store.
/// Network failure with any cached copy → return stale.
class ApiCacheInterceptor extends QueuedInterceptorsWrapper {
  ApiCacheInterceptor({ApiCacheStore? store})
    : this._(store ?? ApiCacheStore.instance);

  ApiCacheInterceptor._(ApiCacheStore store)
    : super(
        onRequest: (options, handler) async {
          try {
            if (!ApiCachePolicy.shouldCache(options)) {
              handler.next(options);
              return;
            }

            final key = ApiCachePolicy.cacheKey(options);
            options.extra[_keyExtra] = key;

            final entry = await store.read(key);
            if (entry != null && entry.isFresh()) {
              handler.resolve(entry.toResponse(options));
              return;
            }

            handler.next(options);
          } catch (_) {
            handler.next(options);
          }
        },
        onResponse: (response, handler) async {
          try {
            final key = response.requestOptions.extra[_keyExtra];
            if (key is String && key.isNotEmpty) {
              await store.writeResponse(key, response);
            }
          } catch (_) {}
          handler.next(response);
        },
        onError: (err, handler) async {
          try {
            if (!ApiExceptionMapper.isNetworkFailure(err)) {
              handler.next(err);
              return;
            }

            final options = err.requestOptions;
            if (!ApiCachePolicy.shouldCache(options)) {
              handler.next(err);
              return;
            }

            final key =
                options.extra[_keyExtra] as String? ??
                ApiCachePolicy.cacheKey(options);
            final entry = await store.read(key);
            if (entry == null) {
              handler.next(err);
              return;
            }

            handler.resolve(entry.toResponse(options));
          } catch (_) {
            handler.next(err);
          }
        },
      );

  static const _keyExtra = 'api_cache_key';
}
