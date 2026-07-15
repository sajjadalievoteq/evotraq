import 'package:traqtrace_app/core/storage/hive_storage.dart';

class OperationalGlnStore {
  OperationalGlnStore._();

  static String _key(int userId) => 'operational_gln_user_$userId';

  static Future<String?> getGln(int userId) async {
    final value = await HiveStorage.getString(_key(userId));
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  static Future<void> setGln(int userId, String? glnCode) async {
    final key = _key(userId);
    if (glnCode == null || glnCode.trim().isEmpty) {
      await HiveStorage.remove(key);
      return;
    }
    await HiveStorage.putString(key, glnCode.trim());
  }
}
