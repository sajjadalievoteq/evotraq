import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:world_countries/world_countries.dart';

class WorldCountriesCache {
  static final TypedLocaleDelegate _delegate = TypedLocaleDelegate.selectiveCache(
    isoCollections: IsoCollections(
      currenciesForTranslationCache: const [],
      languagesForTranslationCache: const [],
    ),
  );

  IsoMaps? _isoMaps;
  Future<void>? _inFlight;

  bool get isLoaded => _isoMaps != null;

  IsoMaps? get isoMaps => _isoMaps;

  String? countryName(WorldCountry country) =>
      _isoMaps?.countryTranslations[country];

  Future<void> ensureLoaded({Locale? locale}) async {
    if (_isoMaps != null) return;
    if (_inFlight != null) {
      await _inFlight;
      return;
    }
    _inFlight = _warmUp(locale);
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _warmUp(Locale? locale) async {
    try {
      final resolved = locale ?? PlatformDispatcher.instance.locale;
      final typedLocale = await _delegate.load(resolved);
      _isoMaps = typedLocale?.maps;
    } catch (e) {
      debugPrint('[WorldCountriesCache] warmup failed: $e');
    }
  }

  Future<void> preload({Locale? locale}) => ensureLoaded(locale: locale);

  void clear() {
    _isoMaps = null;
    _inFlight = null;
  }
}