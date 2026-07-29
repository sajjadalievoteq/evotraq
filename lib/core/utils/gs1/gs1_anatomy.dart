import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

/// Identifier anatomy (GCP / reference / check digit) using the bundled GCP table.
abstract final class Gs1Anatomy {
  static List<_GcpRange>? _ranges;
  static Future<void>? _loading;

  static Future<void> ensureLoaded() {
    return _loading ??= _load();
  }

  static Future<void> _load() async {
    try {
      final raw =
          await rootBundle.loadString('assets/gs1/gcp-length-table.json');
      final decoded = jsonDecode(raw);
      final list = decoded is Map ? decoded['ranges'] : decoded;
      if (list is! List) {
        _ranges = const [];
        return;
      }
      _ranges = [
        for (final e in list)
          if (e is Map)
            _GcpRange(
              start: '${e['start']}',
              end: '${e['end']}',
              length: e['length'] is int
                  ? e['length'] as int
                  : int.tryParse('${e['length']}') ?? 0,
            ),
      ].where((r) => r.length >= 6 && r.length <= 12).toList();
    } catch (_) {
      _ranges = const [];
    }
  }

  /// Resolves GCP length for a numeric identifier body (without requiring check digit).
  static int? gcpLengthFor(String digits) {
    final d = CheckDigitUtils.digitsOnly(digits);
    if (d.length < 6) return null;
    final ranges = _ranges;
    if (ranges == null || ranges.isEmpty) return null;
    for (final r in ranges) {
      final prefix = d.length >= r.start.length
          ? d.substring(0, r.start.length)
          : d;
      if (prefix.compareTo(r.start) >= 0 && prefix.compareTo(r.end) <= 0) {
        return r.length;
      }
    }
    return null;
  }

  /// Decompose GTIN / GLN / SSCC into GCP + reference + check digit.
  static Map<String, String> decompose(String? value, {required String kind}) {
    final digits = CheckDigitUtils.digitsOnly(value);
    final fields = <String, String>{
      'Kind': kind.toUpperCase(),
      'Digits': digits,
    };
    if (digits.length < 2) {
      fields['Note'] = 'Enter a full identifier to decompose';
      return fields;
    }

    final body = digits.substring(0, digits.length - 1);
    final check = digits[digits.length - 1];
    final expected = CheckDigitUtils.calculateMod10String(body);
    fields['Check digit'] = check;
    fields['Check digit valid'] = check == expected ? 'Yes' : 'No (expected $expected)';

    final gcpLen = gcpLengthFor(body);
    if (gcpLen == null) {
      fields['GS1 Company Prefix'] = 'unknown GCP length';
      fields['Reference'] = body;
      fields['Note'] =
          'Prefix not found in bundled GCP length table — showing full body as reference';
      return fields;
    }

    // SSCC body: extension(1) + GCP + serial ref
    if (kind.toLowerCase() == 'sscc' && body.length == 17) {
      final ext = body[0];
      final gcp = body.substring(1, 1 + gcpLen);
      final serialRef = body.substring(1 + gcpLen);
      fields['Extension digit'] = ext;
      fields['GS1 Company Prefix'] = gcp;
      fields['Serial reference'] = serialRef;
      return fields;
    }

    // GTIN-14 body may include indicator
    if (kind.toLowerCase() == 'gtin' && body.length == 13) {
      final indicator = body[0];
      final rest = body.substring(1);
      final gcp = rest.length >= gcpLen ? rest.substring(0, gcpLen) : rest;
      final itemRef =
          rest.length > gcpLen ? rest.substring(gcpLen) : '';
      fields['Indicator'] = indicator;
      fields['GS1 Company Prefix'] = gcp;
      fields['Item reference'] = itemRef;
      return fields;
    }

    // GLN / shorter GTINs: GCP from left of body
    final gcp = body.length >= gcpLen ? body.substring(0, gcpLen) : body;
    final reference =
        body.length > gcpLen ? body.substring(gcpLen) : '';
    fields['GS1 Company Prefix'] = gcp;
    fields['Reference'] = reference;
    return fields;
  }
}

class _GcpRange {
  const _GcpRange({
    required this.start,
    required this.end,
    required this.length,
  });
  final String start;
  final String end;
  final int length;
}
