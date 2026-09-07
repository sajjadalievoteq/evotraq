import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/network/api_cache/api_cache_config.dart';
import 'package:traqtrace_app/core/network/api_cache/api_cache_interceptor.dart';
import 'package:traqtrace_app/core/network/api_cache/api_cache_policy.dart';
import 'package:traqtrace_app/core/network/api_cache/api_cache_store.dart';

class _CountingAdapter implements HttpClientAdapter {
  int hits = 0;
  bool fail = false;
  dynamic body = {'ok': true};

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    hits++;
    if (fail) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'offline',
      );
    }
    return ResponseBody.fromString(
      '{"ok":true,"n":$hits}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  late MemoryApiCacheStore store;
  late _CountingAdapter adapter;

  setUp(() {
    store = MemoryApiCacheStore();
    adapter = _CountingAdapter();
    ApiCacheConfig.resetForTests();
    ApiCachePolicy.resetForTests();
  });

  tearDown(() {
    ApiCacheConfig.resetForTests();
    ApiCachePolicy.resetForTests();
  });

  Dio buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://example.test',
        responseType: ResponseType.json,
      ),
    );
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(ApiCacheInterceptor(store: store));
    return dio;
  }

  group('ApiCachePolicy', () {
    test('native caches all GETs when enableForNative is on', () {
      ApiCachePolicy.isWeb = () => false;
      ApiCacheConfig.enableForNativeOverride = true;

      final options = RequestOptions(
        path: '/gs1/gtins',
        method: 'GET',
        baseUrl: 'http://localhost:8080/api',
      );
      expect(ApiCachePolicy.shouldCache(options), isTrue);
    });

    test('native skips cache when enableForNative is off', () {
      ApiCachePolicy.isWeb = () => false;
      ApiCacheConfig.enableForNativeOverride = false;

      final options = RequestOptions(
        path: '/dashboard/summary',
        method: 'GET',
        baseUrl: 'http://localhost:8080/api',
      );
      expect(ApiCachePolicy.shouldCache(options), isFalse);
    });

    test('web caches only home markers', () {
      ApiCachePolicy.isWeb = () => true;

      expect(
        ApiCachePolicy.shouldCache(
          RequestOptions(
            path: '/dashboard/summary',
            method: 'GET',
            baseUrl: 'http://localhost:8080/api',
          ),
        ),
        isTrue,
      );
      expect(
        ApiCachePolicy.shouldCache(
          RequestOptions(
            path: '/gs1/gtins',
            method: 'GET',
            baseUrl: 'http://localhost:8080/api',
          ),
        ),
        isFalse,
      );
    });

    test('never caches mutations or auth', () {
      ApiCachePolicy.isWeb = () => false;
      ApiCacheConfig.enableForNativeOverride = true;

      expect(
        ApiCachePolicy.shouldCache(
          RequestOptions(
            path: '/gs1/gtins',
            method: 'POST',
            baseUrl: 'http://localhost:8080/api',
          ),
        ),
        isFalse,
      );
      expect(
        ApiCachePolicy.shouldCache(
          RequestOptions(
            path: '/auth/login',
            method: 'GET',
            baseUrl: 'http://localhost:8080/api',
          ),
        ),
        isFalse,
      );
    });
  });

  group('ApiCacheInterceptor', () {
    test('serves fresh cache on second GET without hitting network', () async {
      ApiCachePolicy.isWeb = () => false;
      ApiCacheConfig.enableForNativeOverride = true;

      final dio = buildDio();
      final first = await dio.get<dynamic>('/dashboard/summary');
      final second = await dio.get<dynamic>('/dashboard/summary');

      expect(first.data['n'], 1);
      expect(second.data['n'], 1);
      expect(second.extra[ApiCacheStore.fromCacheExtraKey], isTrue);
      expect(adapter.hits, 1);
    });

    test('returns stale cache when network fails', () async {
      ApiCachePolicy.isWeb = () => false;
      ApiCacheConfig.enableForNativeOverride = true;

      await store.write(
        'GET|/dashboard/summary|',
        ApiCacheEntry(
          statusCode: 200,
          data: {'ok': true, 'stale': true},
          headers: const {},
          cachedAtMs: DateTime.now()
              .subtract(const Duration(hours: 5))
              .millisecondsSinceEpoch,
        ),
      );

      adapter.fail = true;
      final dio = buildDio();
      final response = await dio.get<dynamic>('/dashboard/summary');
      expect(response.data['stale'], isTrue);
      expect(response.extra[ApiCacheStore.fromCacheExtraKey], isTrue);
    });
  });
}
