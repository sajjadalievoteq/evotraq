import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';

final RegExp _ssccCodePattern = RegExp(r'^\d{18}$');

bool isLikelySsccRecord(Map<String, dynamic> json) {
  final code = (json['sscc'] ?? json['ssccCode'] ?? '').toString().trim();
  if (!_ssccCodePattern.hasMatch(code)) return false;
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
    }
  }
  return ssccs;
}

String userFacingSsccErrorMessage(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return 'Failed to save SSCC. Please try again.';
  }
  final trimmed = raw.trim();
  if (trimmed.contains('"glnCode"') ||
      trimmed.contains('licenseValidFrom') ||
      trimmed.contains('locationName')) {
    return 'Failed to load SSCC data. Please refresh the list.';
  }

  final lower = trimmed.toLowerCase();
  const fieldHints = <String, String>{
    'issuing gln': 'Issuing GLN',
    'issuinggln': 'Issuing GLN',
    'extension digit': 'Extension Digit',
    'sscc code': 'SSCC Code',
    'sscc must': 'SSCC Code',
    'sscc gcp': 'SSCC Code',
    'gs1 company prefix': 'SSCC Code / Issuing GLN',
    'contained gtin': 'Contained GTIN',
    'contained quantity': 'Contained Quantity',
    'content homogeneity': 'Content Homogeneity',
    'gsin': 'GSIN',
    'purchase order': 'Purchase Order',
    'ship-from gln': 'Ship From GLN',
    'ship-to gln': 'Ship To GLN',
    'packing date': 'Packing Date',
    'xsc-002': 'Issuing GLN / SSCC Code',
    'xsc-004': 'Classification & Content',
  };

  for (final entry in fieldHints.entries) {
    if (lower.contains(entry.key)) {
      if (trimmed.startsWith('${entry.value}:')) {
        return trimmed;
      }
      return '${entry.value}: $trimmed';
    }
  }

  if (trimmed.length > 240) {
    return '${trimmed.substring(0, 240)}…';
  }
  return trimmed;
}
