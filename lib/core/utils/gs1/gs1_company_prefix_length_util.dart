import 'dart:convert';

import 'package:flutter/services.dart';

/// Resolves GS1 Company Prefix length from the official prefix format list.
///
/// The list is loaded once from the shared backend resource bundled as a Flutter asset.
abstract final class Gs1CompanyPrefixLengthUtil {
  static const _assetPath =
      '../backend/src/main/resources/gs1/gcpprefixformatlist.json';

  static Map<String, int>? _prefixToLength;

  static Future<void> ensureLoaded() async {
    if (_prefixToLength != null) return;
    await _loadPrefixMap();
  }

  static int? resolveGs1CompanyPrefixLength(String gtin14) {
    final map = _prefixToLength;
    if (map == null || map.isEmpty) return null;

    final s = gtin14.trim();
    if (!RegExp(r'^\d{14}$').hasMatch(s)) return null;

    final first13 = s.substring(0, 13);
    for (var prefixLen = first13.length.clamp(4, 12); prefixLen >= 4; prefixLen--) {
      final candidate = first13.substring(0, prefixLen);
      final gcpLen = map[candidate];
      if (gcpLen != null && gcpLen > 0) {
        return gcpLen;
      }
    }
    return null;
  }

  static int? resolveSsccGs1CompanyPrefixLength(String sscc18) {
    final map = _prefixToLength;
    if (map == null || map.isEmpty) return null;

    final s = sscc18.trim();
    if (!RegExp(r'^\d{18}$').hasMatch(s)) return null;

    final gcpAndSerial = s.substring(1, 17);
    for (var prefixLen = 12; prefixLen >= 4; prefixLen--) {
      if (prefixLen > gcpAndSerial.length) continue;
      final candidate = gcpAndSerial.substring(0, prefixLen);
      final gcpLen = map[candidate];
      if (gcpLen != null && gcpLen > 0 && gcpLen <= 12) {
        return gcpLen;
      }
    }
    return null;
  }

  static Future<void> _loadPrefixMap() async {
    try {
      const path = _assetPath;
      final jsonText = await rootBundle.loadString(path);
      final root = jsonDecode(jsonText) as Map<String, dynamic>;
      final entries =
          (root['GCPPrefixFormatList'] as Map<String, dynamic>?)?['entry']
              as List<dynamic>?;

      final out = <String, int>{};
      if (entries != null) {
        for (final entry in entries) {
          final map = entry as Map<String, dynamic>;
          final prefix = map['prefix']?.toString();
          final len = map['gcpLength'];
          if (prefix == null || prefix.isEmpty) continue;
          final gcpLen = len is int ? len : int.tryParse('$len');
          if (gcpLen == null || gcpLen <= 0) continue;
          out[prefix.trim()] = gcpLen;
        }
      }
      _prefixToLength = out;
    } catch (_) {
      _prefixToLength = const {};
    }
  }
}
