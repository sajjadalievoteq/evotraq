import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';



class GlnPickerCatalog {
  GlnPickerCatalog({required GLNService glnService}) : _glnService = glnService;

  final GLNService _glnService;
  List<GLN>? _cache;
  Future<List<GLN>>? _inFlight;

  List<GLN> get items => List.unmodifiable(_cache ?? const <GLN>[]);

  bool get isLoaded => _cache != null;

  List<GLN> get activeItems =>
      items.where((gln) => gln.active).toList(growable: false);

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
    final glns = await _glnService.getAllGLNs(page: 0, size: 500);
    _cache = List<GLN>.from(glns);
    return items;
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
    _inFlight = null;
  }

  void clear() => invalidate();
}
