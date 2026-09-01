import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/services/world_countries/world_countries_cache.dart';

void main() {
  late WorldCountriesCache cache;

  setUp(() {
    cache = WorldCountriesCache();
  });

  test('loads country translations and flags', () async {
    await cache.ensureLoaded();

    expect(cache.isLoaded, isTrue);
    expect(cache.isoMaps, isNotNull);
    expect(cache.isoMaps!.countryTranslations, isNotEmpty);
    expect(cache.isoMaps!.countryFlags, isNotEmpty);
  });

  test('countryName returns translated label when loaded', () async {
    await cache.ensureLoaded();

    final firstCountry = cache.isoMaps!.countryTranslations.keys.first;
    expect(cache.countryName(firstCountry), isNotNull);
  });

  test('coalesces concurrent ensureLoaded calls', () async {
    final results = await Future.wait([
      cache.ensureLoaded(),
      cache.ensureLoaded(),
      cache.ensureLoaded(),
    ]);

    expect(results.every((_) => cache.isLoaded), isTrue);
    expect(cache.isoMaps, isNotNull);
  });

  test('clear drops cache for logout', () async {
    await cache.ensureLoaded();
    expect(cache.isLoaded, isTrue);

    cache.clear();

    expect(cache.isLoaded, isFalse);
    expect(cache.isoMaps, isNull);
  });
}
