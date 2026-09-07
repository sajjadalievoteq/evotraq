import 'package:flutter/foundation.dart';

abstract final class ApiCacheConfig {
  /// Master switch for Android / iOS (and other non-web) platforms.
  /// Set to `false` to disable cache-first for all native requests.
  static const bool enableForNative = false;

  /// How long a cached GET stays fresh before the next call hits the network.
  static const Duration ttl = Duration(minutes: 15);

  /// Path markers treated as "home screen" APIs (used on web only).
  static const List<String> webHomePathMarkers = [
    '/dashboard/summary',
    '/commissioning/throughput',
    '/internal/actuator/health',
    '/internal/actuator/info',
  ];

  @visibleForTesting
  static bool? enableForNativeOverride;

  static bool get isNativeCacheEnabled =>
      enableForNativeOverride ?? enableForNative;

  @visibleForTesting
  static void resetForTests() {
    enableForNativeOverride = null;
  }
}
