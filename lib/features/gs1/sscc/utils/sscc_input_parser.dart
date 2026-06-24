import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/core/utils/gs1_utils.dart';

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
      // SSCC URN structure: urn:epc:id:sscc:<GCP>.<fullSerialRef>
      // where fullSerialRef = extensionDigit (1 char) + serialReference
      //
      // SSCC-18 body (17 digits, before check digit):
      //   extensionDigit + GCP + serialReference
      //   = fullSerialRef[0] + GCP + fullSerialRef[1:]
      //
      // NOTE: do NOT concatenate GCP + fullSerialRef — that reorders extension
      // digit to the middle and produces a completely different SSCC body.
      final gcp = urnMatch.group(1)!;
      final fullSerialRef = urnMatch.group(2)!;
      if (fullSerialRef.isEmpty) return null;
      final ssccBody = fullSerialRef[0] + gcp + fullSerialRef.substring(1);
      if (ssccBody.length == 17) {
        // Use GtinFormat (starts rightmost at ×3) — the same algorithm that
        // SsccFormat.isValidSscc uses. GS1Utils.calculateGS1CheckDigit uses
        // the opposite polarity and produces wrong check digits for SSCC.
        final check = GtinFormat.calculateCheckDigitForBody(ssccBody);
        if (check < 0) return null;
        return _normalize(ssccBody + check.toString());
      }
      if (ssccBody.length == 18) {
        return _normalize(ssccBody);
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
