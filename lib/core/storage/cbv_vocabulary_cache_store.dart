import 'dart:convert';

import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_session.dart';


class CbvVocabularyCacheEntry {
  final CbvVocabularySession session;
  final DateTime cachedAt;

  const CbvVocabularyCacheEntry({required this.session, required this.cachedAt});
}





class CbvVocabularyCacheStore {
  CbvVocabularyCacheStore._();

  static const _jsonKey = 'cbv_vocabulary_cache_json_v1';
  static const _timestampKey = 'cbv_vocabulary_cache_ts_v1';

  
  
  static Future<CbvVocabularyCacheEntry?> read() async {
    try {
      final rawJson = await HiveStorage.getString(_jsonKey);
      final rawTimestamp = await HiveStorage.getInt(_timestampKey);
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

  
  
  static Future<void> write(CbvVocabularySession session) async {
    try {
      await HiveStorage.putString(_jsonKey, jsonEncode(session.toJson()));
      await HiveStorage.putInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      
    }
  }

  static Future<void> clear() async {
    try {
      await HiveStorage.remove(_jsonKey);
      await HiveStorage.remove(_timestampKey);
    } catch (_) {
      
    }
  }
}
