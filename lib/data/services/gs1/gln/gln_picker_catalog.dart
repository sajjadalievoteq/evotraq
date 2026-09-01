import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';

class GlnPickerCatalog {
  GlnPickerCatalog({required GLNService glnService}) : _glnService = glnService;

  final GLNService _glnService;

  @visibleForTesting
  static const int maxCachedEntriesAdvisory = 10000;

  List<GLN>? _cache;
  List<GLN>? _activeCache;
  Future<List<GLN>>? _inFlight;
  bool _usedSummaryEndpoint = false;

  List<GLN> get items => List.unmodifiable(_cache ?? const <GLN>[]);

  bool get isLoaded => _cache != null;

  @visibleForTesting
  bool get usedSummaryEndpoint => _usedSummaryEndpoint;

  List<GLN> get activeItems {
    if (_activeCache != null) return _activeCache!;
    final filtered = items.where((gln) => gln.active).toList(growable: false);
    _activeCache = filtered;
    return filtered;
  }

  Future<List<GLN>> ensureLoaded({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return items;
    }
    if (!forceRefresh && _inFlight != null) {
      return _inFlight!;
    }
    _inFlight = _fetch();
    try {
      return await _inFlight!;
    } finally {
      _inFlight = null;
    }
  }

  Future<List<GLN>> _fetch() async {
    List<GLN> glns;
    var usedSummary = false;
    try {
      glns = await _glnService.fetchPickerSummaries();
      usedSummary = true;
    } on ApiException catch (e) {
      if (_isUnavailableSummaryEndpoint(e)) {
        debugPrint(
          '[GlnPickerCatalog] picker-summaries unavailable '
          '(${e.statusCode}); falling back to full GLN list',
        );
        glns = await _glnService.fetchAllGLNs();
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint(
        '[GlnPickerCatalog] picker-summaries failed ($e); '
        'falling back to full GLN list',
      );
      glns = await _glnService.fetchAllGLNs();
    }

    if (glns.length > maxCachedEntriesAdvisory) {
      debugPrint(
        '[GlnPickerCatalog] large catalog size=${glns.length} '
        '(advisory bound $maxCachedEntriesAdvisory)',
      );
    }

    _cache = List<GLN>.unmodifiable(glns);
    _activeCache = null;
    _usedSummaryEndpoint = usedSummary;
    return items;
  }

  bool _isUnavailableSummaryEndpoint(ApiException e) {
    final code = e.statusCode;
    return code == 404 || code == 405 || code == 501;
  }

  Future<void> preload() async {
    try {
      await ensureLoaded();
    } catch (e) {
      debugPrint('[GlnPickerCatalog] preload failed: $e');
    }
  }

  Future<void> refresh() => ensureLoaded(forceRefresh: true);

  void invalidate() {
    _cache = null;
    _activeCache = null;
    _inFlight = null;
    _usedSummaryEndpoint = false;
  }

  void clear() => invalidate();
}