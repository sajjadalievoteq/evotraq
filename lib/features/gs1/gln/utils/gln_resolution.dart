import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

/// Resolves a stored GLN code to a full [GLN] from a picker catalog when possible.
GLN? resolveGlnInCatalog(String? code, List<GLN> catalog) {
  if (code == null) return null;
  final trimmed = code.trim();
  if (trimmed.isEmpty) return null;

  for (final gln in catalog) {
    if (gln.glnCode == trimmed) return gln;
  }
  return null;
}

/// Prefer a catalog match; otherwise keep [fallback] or build a code-only placeholder.
GLN? resolveGlnForPicker({
  required String? code,
  GLN? fallback,
  List<GLN> catalog = const [],
}) {
  final fromCatalog = resolveGlnInCatalog(code, catalog);
  if (fromCatalog != null) return fromCatalog;
  if (fallback != null) return fallback;
  if (code == null || code.trim().isEmpty) return null;
  return GLN.fromCode(code.trim());
}

bool isPlaceholderGlnLocation(GLN gln) =>
    gln.locationName == 'Unknown Location';
