import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/config/splash_redirect_utils.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';

/// Persists the last meaningful in-app route across refresh and app restart.
///
/// Splash / auth / public locations are never stored or restored. Writes are
/// debounced so rapid redirect chains do not thrash Hive.
class LastRouteStore {
  LastRouteStore({Duration debounce = const Duration(milliseconds: 350)})
      : _debounce = debounce;

  static const String storageKey = 'last_route_location';

  final Duration _debounce;

  String? _memory;
  String? _pending;
  Timer? _timer;

  /// Restorable location for redirects (`from` > this > home). Sync + filtered.
  String? readLocation() {
    String? raw = _memory;
    if (raw == null) {
      try {
        raw = HiveStorage.getStringSync(storageKey);
      } catch (_) {
        raw = null;
      }
    }
    _memory = raw;
    return resolvePendingLocationFrom(raw);
  }

  /// Schedule a persist of [location] if it is a real in-app destination.
  void saveLocation(String location) {
    final safe = resolvePendingLocationFrom(_normalizeLocation(location));
    if (safe == null) return;
    if (safe == _memory || safe == _pending) return;

    _pending = safe;
    _timer?.cancel();
    if (_debounce <= Duration.zero) {
      _flushPending();
      return;
    }
    _timer = Timer(_debounce, _flushPending);
  }

  Future<void> clear() async {
    _timer?.cancel();
    _timer = null;
    _pending = null;
    _memory = null;
    try {
      await HiveStorage.remove(storageKey);
    } catch (_) {}
  }

  @visibleForTesting
  void debugSetLocation(String? location) {
    _timer?.cancel();
    _timer = null;
    _pending = null;
    _memory = resolvePendingLocationFrom(location);
  }

  void _flushPending() {
    final toWrite = _pending;
    _pending = null;
    if (toWrite == null) return;
    _memory = toWrite;
    try {
      unawaited(HiveStorage.putString(storageKey, toWrite));
    } catch (_) {
      // Hive may be unavailable in tests; memory still holds the value.
    }
  }

  static String _normalizeLocation(String location) {
    final trimmed = location.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('/')) return trimmed;
    try {
      final uri = Uri.parse(trimmed);
      if (uri.hasScheme || uri.host.isNotEmpty) {
        return uri.path + (uri.hasQuery ? '?${uri.query}' : '');
      }
    } catch (_) {}
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }
}
