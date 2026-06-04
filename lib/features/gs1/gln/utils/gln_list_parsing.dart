import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_api_consts.dart';

/// Parses a paginated or raw GLN list API payload without failing the whole batch.
List<GLN> parseGlnListFromResponseData(dynamic responseData) {
  if (responseData == null) return const [];

  if (responseData is List) {
    return _parseGlnMaps(responseData);
  }

  if (responseData is Map<String, dynamic>) {
    final content = responseData[GlnApiHttpConsts.jsonKeyContent];
    if (content is List) {
      return _parseGlnMaps(content);
    }
    if (_looksLikeGlnMap(responseData)) {
      return _parseGlnMaps([responseData]);
    }
  }

  return const [];
}

List<GLN> _parseGlnMaps(List<dynamic> raw) {
  final glns = <GLN>[];
  for (final item in raw) {
    if (item is! Map<String, dynamic>) continue;
    try {
      glns.add(GLN.fromJson(item));
    } catch (_) {
      // Skip malformed rows; keep the rest of the catalog usable.
    }
  }
  return glns;
}

bool _looksLikeGlnMap(Map<String, dynamic> json) {
  final code = json['glnCode']?.toString() ?? '';
  return code.length == 13 && RegExp(r'^\d{13}$').hasMatch(code);
}
