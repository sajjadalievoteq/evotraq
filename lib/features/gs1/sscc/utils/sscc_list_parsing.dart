import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';

final RegExp _ssccCodePattern = RegExp(r'^\d{18}$');

/// True when [json] looks like an SSCC row (not a GLN or other master-data shape).
bool isLikelySsccRecord(Map<String, dynamic> json) {
  final code = (json['sscc'] ?? json['ssccCode'] ?? '').toString().trim();
  if (!_ssccCodePattern.hasMatch(code)) return false;
  // GLN payloads also use 13-digit codes in glnCode — never treat those as SSCC.
  if (json.containsKey('glnCode') && !json.containsKey('sscc') && !json.containsKey('ssccCode')) {
    return false;
  }
  return true;
}

List<SSCC> parseSsccListFromContent(List<dynamic> contentList) {
  final ssccs = <SSCC>[];
  for (final item in contentList) {
    if (item is! Map<String, dynamic>) continue;
    if (!isLikelySsccRecord(item)) continue;
    try {
      ssccs.add(SSCC.fromJson(item));
    } catch (_) {
      // Skip malformed rows.
    }
  }
  return ssccs;
}

String userFacingSsccErrorMessage(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return 'Failed to load SSCC data.';
  }
  final trimmed = raw.trim();
  if (trimmed.contains('"glnCode"') ||
      trimmed.contains('licenseValidFrom') ||
      trimmed.contains('locationName')) {
    return 'Failed to load SSCC data. Please refresh the list.';
  }
  if (trimmed.length > 240) {
    return '${trimmed.substring(0, 240)}…';
  }
  return trimmed;
}
