import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
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

  group('HiveStorage', () {
    test('typed helpers round-trip bool/int/string', () async {
      await HiveStorage.putBool('dark_mode_preference', true);
      await HiveStorage.putInt('cbv_vocabulary_cache_ts_v1', 1710000000000);
      await HiveStorage.putString('recent_login_usernames', '["ops"]');

      expect(await HiveStorage.getBool('dark_mode_preference'), isTrue);
      expect(
        await HiveStorage.getInt('cbv_vocabulary_cache_ts_v1'),
        1710000000000,
      );
      expect(await HiveStorage.getString('recent_login_usernames'), '["ops"]');
      expect(Hive.isBoxOpen(HiveStorage.boxName), isTrue);
    });
  });
}
