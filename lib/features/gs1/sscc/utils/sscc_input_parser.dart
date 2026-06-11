import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';

/// Parses SSCC codes from barcodes, element strings, URIs, or plain 18-digit input.
abstract final class SsccInputParser {
  static final RegExp _ssccDigitalLink = RegExp(
    r'^https://id\.gs1\.org/00/(\d{18})$',
    caseSensitive: false,
  );

  static final RegExp _ssccUrn = RegExp(
    r'^urn:epc:id:sscc:([0-9]{4,12})\.([0-9]{1,13})$',
    caseSensitive: false,
  );

  static final RegExp _elementStringSscc = RegExp(r'\(00\)(\d{18})');

  /// Returns a validated 18-digit SSCC, or null if the input cannot be resolved.
  static String? parseToSsccCode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();

    final dlMatch = _ssccDigitalLink.firstMatch(trimmed);
    if (dlMatch != null) {
      return _normalize(dlMatch.group(1)!);
    }

    final urnMatch = _ssccUrn.firstMatch(trimmed);
    if (urnMatch != null) {
      final combined = '${urnMatch.group(1)!}${urnMatch.group(2)!}';
      if (combined.length == 17) {
        return _normalize(combined + GS1Utils.calculateGS1CheckDigit(combined));
      }
      if (combined.length == 18) {
        return _normalize(combined);
      }
    }

    final elementMatch = _elementStringSscc.firstMatch(trimmed);
    if (elementMatch != null) {
      return _normalize(elementMatch.group(1)!);
    }

    if (trimmed.contains('(00)') ||
        RegExp(r'^00\d').hasMatch(trimmed.replaceAll(RegExp(r'[\s\u00A0]'), ''))) {
      final parsed = GS1BarcodeParser.parseGS1Barcode(trimmed);
      if (parsed['valid'] == true && parsed['SSCC'] != null) {
        final sscc = parsed['SSCC'].toString();
        if (sscc.length == 18) {
          return _normalize(sscc);
        }
        if (sscc.length == 17) {
          return _normalize(sscc + GS1Utils.calculateGS1CheckDigit(sscc));
        }
      }
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 18) {
      final candidate = digitsOnly.substring(digitsOnly.length - 18);
      return _normalize(candidate);
    }
    if (digitsOnly.length == 17) {
      return GS1Utils.validateAndFixSSCC(digitsOnly);
    }

    final stripped = SsccFormat.stripSsccInput(trimmed);
    if (stripped.length == 18 && RegExp(r'^\d{18}$').hasMatch(stripped)) {
      return _normalize(stripped);
    }

    return null;
  }

  static String? _normalize(String candidate) {
    final fixed = GS1Utils.validateAndFixSSCC(candidate);
    if (fixed != null && SsccFormat.isValidSscc(fixed)) {
      return fixed;
    }
    if (SsccFormat.isValidSscc(candidate)) {
      return candidate;
    }
    return null;
  }
}
