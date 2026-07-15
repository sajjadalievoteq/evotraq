import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/core/storage/recent_login_usernames_store.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('hive_storage_test_');
    await HiveStorage.initForTests(hiveDir.path);
  });

  tearDown(() async {
    await HiveStorage.resetForTests();
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
  });

  group('Theme preference', () {
    test('defaults to false when unset', () async {
      expect(await ThemeCubit.loadThemePreference(), isFalse);
    });

    test('persists dark mode preference', () async {
      await ThemeCubit.saveThemePreference(true);
      expect(await ThemeCubit.loadThemePreference(), isTrue);

      await ThemeCubit.saveThemePreference(false);
      expect(await ThemeCubit.loadThemePreference(), isFalse);
    });
  });

  group('OperationalGlnStore', () {
    test('save/get/remove preserves trim and null semantics', () async {
      expect(await OperationalGlnStore.getGln(42), isNull);

      await OperationalGlnStore.setGln(42, '  1234567890123  ');
      expect(await OperationalGlnStore.getGln(42), '1234567890123');

      await OperationalGlnStore.setGln(42, '   ');
      expect(await OperationalGlnStore.getGln(42), isNull);

      await OperationalGlnStore.setGln(42, '9999999999999');
      await OperationalGlnStore.setGln(42, null);
      expect(await OperationalGlnStore.getGln(42), isNull);
    });
  });

  group('RecentLoginUsernamesStore', () {
    test('add/read/deduplicate case-insensitively and cap at 8', () async {
      const store = RecentLoginUsernamesStore();

      expect(await store.getUsernames(), isEmpty);

      await store.rememberUsername('alice');
      await store.rememberUsername('bob');
      await store.rememberUsername('Alice');

      expect(await store.getUsernames(), ['Alice', 'bob']);

      for (var i = 0; i < 10; i++) {
        await store.rememberUsername('user$i');
      }

      final usernames = await store.getUsernames();
      expect(usernames, hasLength(8));
      expect(usernames.first, 'user9');
      expect(usernames.contains('alice') || usernames.contains('Alice'), isFalse);
    });
  });

  group('HiveStorage', () {
    test('typed helpers round-trip bool/int/string', () async {
      await HiveStorage.putBool('dark_mode_preference', true);
      await HiveStorage.putInt('cbv_vocabulary_cache_ts_v1', 1710000000000);
      await HiveStorage.putString('recent_login_usernames', '["ops"]');

      expect(await HiveStorage.getBool('dark_mode_preference'), isTrue);
      expect(await HiveStorage.getInt('cbv_vocabulary_cache_ts_v1'), 1710000000000);
      expect(await HiveStorage.getString('recent_login_usernames'), '["ops"]');
      expect(Hive.isBoxOpen(HiveStorage.boxName), isTrue);
    });
  });
}
