import 'package:shared_preferences/shared_preferences.dart';

class OperationalGlnStore {
  OperationalGlnStore._();

  static String _key(int userId) => 'operational_gln_user_$userId';

  static Future<String?> getGln(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key(userId));
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  static Future<void> setGln(int userId, String? glnCode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(userId);
    if (glnCode == null || glnCode.trim().isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, glnCode.trim());
  }
}
