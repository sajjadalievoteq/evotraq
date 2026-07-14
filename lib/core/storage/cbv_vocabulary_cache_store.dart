import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_session.dart';

/// A cached CBV vocabulary session paired with the time it was fetched.
class CbvVocabularyCacheEntry {
  final CbvVocabularySession session;
  final DateTime cachedAt;

  const CbvVocabularyCacheEntry({required this.session, required this.cachedAt});
}

/// Persists the last-known-good CBV vocabulary to disk (mirrors the
/// static-method [SharedPreferences] wrapper pattern already used by
/// OperationalGlnStore) so it's available immediately on the next app
/// launch, before any network request completes.
class CbvVocabularyCacheStore {
  CbvVocabularyCacheStore._();

  static const _jsonKey = 'cbv_vocabulary_cache_json_v1';
  static const _timestampKey = 'cbv_vocabulary_cache_ts_v1';

  /// Reads the cached session. Never throws — returns null if nothing is
  /// cached or the cached data is corrupt/unreadable.
  static Future<CbvVocabularyCacheEntry?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_jsonKey);
      final rawTimestamp = prefs.getInt(_timestampKey);
      if (rawJson == null || rawTimestamp == null) return null;

      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return null;

      final session = CbvVocabularySession.fromJson(Map<String, dynamic>.from(decoded));
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
      return CbvVocabularyCacheEntry(session: session, cachedAt: cachedAt);
    } catch (_) {
      return null;
    }
  }

  /// Best-effort write; failures are swallowed since this is a cache, not a
  /// source of truth.
  static Future<void> write(CbvVocabularySession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_jsonKey, jsonEncode(session.toJson()));
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // Ignore cache write failures — the in-memory session still works.
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jsonKey);
      await prefs.remove(_timestampKey);
    } catch (_) {
      // Ignore.
    }
  }
}
