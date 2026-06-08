import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String _recentLoginUsernamesKey = 'recent_login_usernames';
const int _maxRecentLoginUsernames = 8;

/// Persists recently used login identifiers on-device only (SharedPreferences).
class RecentLoginUsernamesStore {
  const RecentLoginUsernamesStore();

  Future<List<String>> getUsernames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_recentLoginUsernamesKey);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> rememberUsername(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;

    try {
      final existing = await getUsernames();
      final updated = [
        trimmed,
        ...existing.where(
          (value) => value.toLowerCase() != trimmed.toLowerCase(),
        ),
      ].take(_maxRecentLoginUsernames).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_recentLoginUsernamesKey, jsonEncode(updated));
    } catch (_) {}
  }
}
