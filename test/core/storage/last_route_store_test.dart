import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/core/storage/last_route_store.dart';

void main() {
  setUp(() async {
    await HiveStorage.initForTests('.dart_tool/last_route_store_test_hive');
  });

  tearDown(() async {
    await HiveStorage.resetForTests();
  });

  test('saves and reads in-app locations; rejects splash/auth', () async {
    final store = LastRouteStore(debounce: Duration.zero);
    store.saveLocation('/dashboards/journey?epc=abc');
    expect(store.readLocation(), '/dashboards/journey?epc=abc');

    store.saveLocation(Constants.splashRoute);
    expect(store.readLocation(), '/dashboards/journey?epc=abc');

    store.saveLocation(Constants.loginRoute);
    expect(store.readLocation(), '/dashboards/journey?epc=abc');

    await store.clear();
    expect(store.readLocation(), isNull);
  });

  test('debugSetLocation filters public routes', () {
    final store = LastRouteStore(debounce: Duration.zero);
    store.debugSetLocation(Constants.loginRoute);
    expect(store.readLocation(), isNull);
    store.debugSetLocation('/home');
    expect(store.readLocation(), '/home');
  });
}
