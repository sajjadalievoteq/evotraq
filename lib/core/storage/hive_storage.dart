import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Minimal typed persistence backed by a single Hive box.
///
/// Used for non-secure client preferences/caches.
/// JWT/auth tokens remain in [flutter_secure_storage] / [TokenManager].
class HiveStorage {
  HiveStorage._();

  static const String boxName = 'traqtrace_prefs';

  static Box<dynamic>? _box;

  static Box<dynamic> get _prefs {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError('HiveStorage.init() must be called before use');
    }
    return box;
  }

  /// Initializes Hive and opens the app preferences box.
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(boxName);
  }

  /// Test-only init that skips Flutter path_provider.
  @visibleForTesting
  static Future<void> initForTests(String directoryPath) async {
    Hive.init(directoryPath);
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
    _box = await Hive.openBox<dynamic>(boxName);
  }

  @visibleForTesting
  static Future<void> resetForTests() async {
    if (_box != null && _box!.isOpen) {
      await _box!.clear();
      await _box!.close();
    }
    _box = null;
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
  }

  static Future<String?> getString(String key) async {
    final value = _prefs.get(key);
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static Future<void> putString(String key, String value) async {
    await _prefs.put(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final value = _prefs.get(key);
    if (value is bool) return value;
    return null;
  }

  static Future<void> putBool(String key, bool value) async {
    await _prefs.put(key, value);
  }

  static Future<int?> getInt(String key) async {
    final value = _prefs.get(key);
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  static Future<void> putInt(String key, int value) async {
    await _prefs.put(key, value);
  }

  static Future<void> remove(String key) async {
    await _prefs.delete(key);
  }

  static Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }
}
