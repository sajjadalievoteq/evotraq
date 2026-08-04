import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/data/services/profile_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

/// Access point for the user's Operational GLN preference.
///
/// Public API is unchanged (`getGln` / `setGln`). Persistence is server-first
/// via `PUT /users/profile`, with Hive kept as an offline mirror/cache.
class OperationalGlnStore {
  OperationalGlnStore._();

  static String _key(int userId) => 'operational_gln_user_$userId';

  static Future<String?> getGln(int userId) async {
    final cached = _serverValueFor(userId);
    if (cached != null) {
      await _mirrorHive(userId, cached);
      return cached;
    }

    try {
      final profile = await getIt<ProfileService>().getCurrentUser();
      if (profile.id == userId) {
        getIt<AuthCubit>().applyCachedUser(profile);
        final server = _normalize(profile.operationalGln);
        if (server != null) {
          await _mirrorHive(userId, server);
          return server;
        }
      }
    } catch (_) {
      // Fall through to Hive when profile is unavailable.
    }

    return _readHive(userId);
  }

  static Future<void> setGln(int userId, String? glnCode) async {
    final normalized = _normalize(glnCode);

    final updated = await getIt<ProfileService>().updateOperationalGln(
      normalized,
    );
    if (updated.id == userId) {
      getIt<AuthCubit>().applyCachedUser(updated);
    } else {
      final auth = getIt<AuthCubit>();
      final current = auth.state.user;
      if (current != null && current.id == userId) {
        auth.applyCachedUser(
          current.copyWith(
            operationalGln: normalized,
            clearOperationalGln: normalized == null,
          ),
        );
      }
    }

    if (normalized == null) {
      await HiveStorage.remove(_key(userId));
    } else {
      await _mirrorHive(userId, normalized);
    }
  }

  /// One-time Hive → DB migration for users who set Operational GLN before
  /// server persistence shipped. No-op when the server already has a value.
  static Future<void> backfillIfNeeded(User user) async {
    final server = _normalize(user.operationalGln);
    if (server != null) {
      await _mirrorHive(user.id, server);
      return;
    }

    final hive = await _readHive(user.id);
    if (hive == null) return;

    try {
      await setGln(user.id, hive);
    } catch (_) {
      // Keep Hive value; next successful auth/profile load will retry.
    }
  }

  static String? _serverValueFor(int userId) {
    final user = getIt<AuthCubit>().state.user;
    if (user == null || user.id != userId) return null;
    return _normalize(user.operationalGln);
  }

  static Future<String?> _readHive(int userId) async {
    final value = await HiveStorage.getString(_key(userId));
    return _normalize(value);
  }

  static Future<void> _mirrorHive(int userId, String glnCode) async {
    await HiveStorage.putString(_key(userId), glnCode);
  }

  static String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
