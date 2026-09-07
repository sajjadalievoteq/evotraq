import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:traqtrace_app/core/network/api_cache/api_cache_config.dart';

class ApiCacheEntry {
  const ApiCacheEntry({
    required this.statusCode,
    required this.data,
    required this.headers,
    required this.cachedAtMs,
  });

  final int statusCode;
  final dynamic data;
  final Map<String, List<String>> headers;
  final int cachedAtMs;

  bool isFresh([Duration ttl = ApiCacheConfig.ttl]) {
    final ageMs = DateTime.now().millisecondsSinceEpoch - cachedAtMs;
    return ageMs >= 0 && ageMs <= ttl.inMilliseconds;
  }

  Map<String, dynamic> toMap() => {
    'statusCode': statusCode,
    'data': data,
    'headers': headers,
    'cachedAtMs': cachedAtMs,
  };

  factory ApiCacheEntry.fromMap(Map map) {
    final rawHeaders = map['headers'];
    final headers = <String, List<String>>{};
    if (rawHeaders is Map) {
      rawHeaders.forEach((key, value) {
        if (value is List) {
          headers[key.toString()] = value.map((e) => e.toString()).toList();
        } else if (value != null) {
          headers[key.toString()] = [value.toString()];
        }
      });
    }

    return ApiCacheEntry(
      statusCode: (map['statusCode'] as num?)?.toInt() ?? 200,
      data: map['data'],
      headers: headers,
      cachedAtMs: (map['cachedAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  Response<dynamic> toResponse(RequestOptions options) {
    return Response<dynamic>(
      requestOptions: options,
      data: data,
      statusCode: statusCode,
      headers: Headers.fromMap(headers),
      extra: <String, dynamic>{
        ...options.extra,
        ApiCacheStore.fromCacheExtraKey: true,
      },
    );
  }
}

abstract class ApiCacheStore {
  static const String fromCacheExtraKey = 'from_api_cache';

  static final ApiCacheStore instance = HiveApiCacheStore();

  Future<ApiCacheEntry?> read(String key);
  Future<void> write(String key, ApiCacheEntry entry);
  Future<void> clear();

  Future<void> writeResponse(String key, Response response) async {
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) return;

    final headers = <String, List<String>>{};
    response.headers.map.forEach((headerKey, value) {
      headers[headerKey] = List<String>.from(value);
    });

    await write(
      key,
      ApiCacheEntry(
        statusCode: code,
        data: response.data,
        headers: headers,
        cachedAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

class MemoryApiCacheStore extends ApiCacheStore {
  final Map<String, ApiCacheEntry> _entries = {};

  @override
  Future<ApiCacheEntry?> read(String key) async => _entries[key];

  @override
  Future<void> write(String key, ApiCacheEntry entry) async {
    _entries[key] = entry;
  }

  @override
  Future<void> clear() async => _entries.clear();
}

class HiveApiCacheStore extends ApiCacheStore {
  static const String boxName = 'traqtrace_api_cache';

  Box<dynamic>? _box;

  Future<Box<dynamic>> _ensureBox() async {
    final existing = _box;
    if (existing != null && existing.isOpen) return existing;
    _box = await Hive.openBox<dynamic>(boxName);
    return _box!;
  }

  @override
  Future<ApiCacheEntry?> read(String key) async {
    try {
      final box = await _ensureBox();
      final raw = box.get(key);
      if (raw is! Map) return null;
      return ApiCacheEntry.fromMap(raw);
    } catch (e) {
      debugPrint('[ApiCacheStore] read failed: $e');
      return null;
    }
  }

  @override
  Future<void> write(String key, ApiCacheEntry entry) async {
    try {
      final box = await _ensureBox();
      await box.put(key, entry.toMap());
    } catch (e) {
      debugPrint('[ApiCacheStore] write failed: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final box = await _ensureBox();
      await box.clear();
    } catch (e) {
      debugPrint('[ApiCacheStore] clear failed: $e');
    }
  }

  @visibleForTesting
  Future<void> resetForTests() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.clear();
        await _box!.close();
      }
    } catch (_) {}
    _box = null;
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
  }
}
