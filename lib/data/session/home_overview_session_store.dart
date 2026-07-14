import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';

/// In-memory + SharedPreferences cache for home dashboard SWR.
class HomeOverviewSessionStore {
  HomeOverviewSessionStore({
    this.maxReuseAge = const Duration(days: 7),
    SharedPreferences? prefs,
  }) : _prefs = prefs;

  static const _prefsKeyPrefix = 'home_overview_v1_';

  final Duration maxReuseAge;
  SharedPreferences? _prefs;
  HomeOverviewBundle? _bundle;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Returns cached overview for [accountEmail] if present (may be stale).
  /// Used for stale-while-revalidate paints; age only discards very old disk entries.
  Future<HomeOverviewBundle?> readFor(String? accountEmail) async {
    if (accountEmail == null || accountEmail.isEmpty) return null;

    final memory = _bundle;
    if (memory != null && memory.accountEmail == accountEmail) {
      return memory;
    }

    try {
      final prefs = await _ensurePrefs();
      final raw = prefs.getString(_prefsKey(accountEmail));
      if (raw == null || raw.isEmpty) return null;
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final bundle = HomeOverviewBundle.fromJson(decoded);
      if (bundle.accountEmail != accountEmail) return null;
      if (DateTime.now().difference(bundle.lastDataRefreshAt) > maxReuseAge) {
        await prefs.remove(_prefsKey(accountEmail));
        return null;
      }
      _bundle = bundle;
      return bundle;
    } catch (_) {
      return null;
    }
  }

  /// Compatibility: only returns memory/disk cache when still "fresh".
  Future<HomeOverviewBundle?> readIfValidFor(String? accountEmail) =>
      readFor(accountEmail);

  Future<void> save(HomeOverviewBundle bundle) async {
    _bundle = bundle;
    final email = bundle.accountEmail;
    if (email == null || email.isEmpty) return;
    try {
      final prefs = await _ensurePrefs();
      await prefs.setString(_prefsKey(email), json.encode(bundle.toJson()));
    } catch (_) {
      // Memory cache still holds the bundle.
    }
  }

  void clear() {
    final email = _bundle?.accountEmail;
    _bundle = null;
    if (email == null || email.isEmpty) return;
    // Fire-and-forget disk eviction so logout stays synchronous.
    // ignore: discarded_futures
    _clearPersisted(email);
  }

  Future<void> _clearPersisted(String email) async {
    try {
      final prefs = await _ensurePrefs();
      await prefs.remove(_prefsKey(email));
    } catch (_) {}
  }

  String _prefsKey(String accountEmail) =>
      '$_prefsKeyPrefix${accountEmail.toLowerCase()}';
}

class HomeOverviewBundle {
  const HomeOverviewBundle({
    required this.stats,
    required this.recentEvents,
    this.healthStatus,
    required this.lastDataRefreshAt,
    required this.accountEmail,
  });

  final DashboardStats stats;
  final List<RecentEvent> recentEvents;
  final SystemHealthStatus? healthStatus;
  final DateTime lastDataRefreshAt;
  final String? accountEmail;

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'recentEvents': recentEvents.map((e) => e.toJson()).toList(),
      'healthStatus': healthStatus?.toJson(),
      'lastDataRefreshAt': lastDataRefreshAt.toIso8601String(),
      'accountEmail': accountEmail,
    };
  }

  factory HomeOverviewBundle.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['recentEvents'] as List<dynamic>? ?? const [];
    final healthRaw = json['healthStatus'];
    return HomeOverviewBundle(
      stats: DashboardStats.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map),
      ),
      recentEvents: rawEvents
          .whereType<Map>()
          .map((e) => RecentEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      healthStatus: healthRaw is Map
          ? SystemHealthStatus.fromJson(Map<String, dynamic>.from(healthRaw))
          : null,
      lastDataRefreshAt:
          DateTime.tryParse(json['lastDataRefreshAt']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      accountEmail: json['accountEmail']?.toString(),
    );
  }
}
