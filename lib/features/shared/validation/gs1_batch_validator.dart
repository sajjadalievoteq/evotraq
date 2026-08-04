import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/data/services/barcode/gs1_barcode_parser.dart';

/// One row from user-supplied batch / CSV / paste input.
class Gs1BatchValidationRow {
  const Gs1BatchValidationRow({
    required this.lineNumber,
    required this.type,
    required this.value,
    required this.isValid,
    required this.message,
  });

  final int lineNumber;
  final String type;
  final String value;
  final bool isValid;
  final String message;
}

/// Parses user paste/CSV and validates each row with [CheckDigitUtils] / parsers.
///
/// Accepted line forms (blank lines and `#` comments ignored):
/// - `GTIN,12345678901231` or `GTIN:12345678901231` or `GTIN 12345678901231`
/// - `GLN,…` / `SSCC,…` / `EPC,…` / `BARCODE,…`
/// - `SGTIN,<gtin>,<serial>` or `SGTIN:<gtin>+<serial>`
/// - Bare digits: length 8/12/14 → GTIN; 18 → SSCC; 13 → GTIN‑13 (same mod‑10 as GLN)
/// - Element string / Digital Link starting with `(` or `http` / `urn:` → barcode/EPC parse
abstract final class Gs1BatchValidator {
  static List<Gs1BatchValidationRow> validatePaste(String input) {
    final lines = input.split(RegExp(r'\r?\n'));
    final results = <Gs1BatchValidationRow>[];
    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i].trim();
      if (raw.isEmpty || raw.startsWith('#')) continue;
      results.add(_validateLine(i + 1, raw));
    }
    return results;
  }

  static Gs1BatchValidationRow _validateLine(int lineNumber, String raw) {
    final typed = _parseTyped(raw);
    if (typed != null) {
      return _validateTyped(lineNumber, typed.$1, typed.$2, typed.$3);
    }

    final lower = raw.toLowerCase();
    if (raw.startsWith('(') ||
        lower.startsWith('http') ||
        lower.startsWith('urn:')) {
      return _validateTyped(lineNumber, 'BARCODE', raw, null);
    }

    final digits = CheckDigitUtils.digitsOnly(raw);
    if (digits.length == 18) {
      return _validateTyped(lineNumber, 'SSCC', digits, null);
    }
    if (CheckDigitUtils.gtinLengths.contains(digits.length)) {
      return _validateTyped(lineNumber, 'GTIN', digits, null);
    }

    return Gs1BatchValidationRow(
      lineNumber: lineNumber,
      type: 'UNKNOWN',
      value: raw,
      isValid: false,
      message:
          'Unrecognized format. Use TYPE,value (GTIN/GLN/SSCC/SGTIN/EPC/BARCODE) '
          'or bare digits of length 8/12/13/14/18.',
    );
  }

  /// Returns (type, primary, serialOrNull).
  static (String, String, String?)? _parseTyped(String raw) {
    final colon = RegExp(
      r'^(GTIN|GLN|SSCC|SGTIN|EPC|EPCURI|BARCODE|AI)\s*[:=]\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(raw);
    if (colon != null) {
      return _splitPrimarySerial(colon.group(1)!.toUpperCase(), colon.group(2)!.trim());
    }

    final csv = RegExp(
      r'^(GTIN|GLN|SSCC|SGTIN|EPC|EPCURI|BARCODE|AI)\s*[,;\t]\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(raw);
    if (csv != null) {
      return _splitPrimarySerial(csv.group(1)!.toUpperCase(), csv.group(2)!.trim());
    }

    final spaced = RegExp(
      r'^(GTIN|GLN|SSCC|SGTIN|EPC|EPCURI|BARCODE|AI)\s+(\S.*)$',
      caseSensitive: false,
    ).firstMatch(raw);
    if (spaced != null) {
      return _splitPrimarySerial(
        spaced.group(1)!.toUpperCase(),
        spaced.group(2)!.trim(),
      );
    }
    return null;
  }

  static (String, String, String?) _splitPrimarySerial(String type, String rest) {
    if (type == 'SGTIN') {
      final plus = rest.split('+');
      if (plus.length >= 2) {
        return (type, plus.first.trim(), plus.sublist(1).join('+').trim());
      }
      final parts = rest.split(RegExp(r'[,;\t]'));
      if (parts.length >= 2) {
        return (type, parts.first.trim(), parts.sublist(1).join(',').trim());
      }
    }
    return (type == 'EPCURI' ? 'EPC' : type, rest, null);
  }

  static Gs1BatchValidationRow _validateTyped(
    int lineNumber,
    String type,
    String primary,
    String? serial,
  ) {
    switch (type) {
      case 'GTIN':
        final err = CheckDigitUtils.validateGtin(primary);
        return Gs1BatchValidationRow(
          lineNumber: lineNumber,
          type: 'GTIN',
          value: CheckDigitUtils.digitsOnly(primary),
          isValid: err == null,
          message: err ?? 'Valid GTIN',
        );
      case 'GLN':
        final err = CheckDigitUtils.validateGln(primary);
        return Gs1BatchValidationRow(
          lineNumber: lineNumber,
          type: 'GLN',
          value: CheckDigitUtils.digitsOnly(primary),
          isValid: err == null,
          message: err ?? 'Valid GLN',
        );
      case 'SSCC':
        final err = CheckDigitUtils.validateSscc(primary);
        return Gs1BatchValidationRow(
          lineNumber: lineNumber,
          type: 'SSCC',
          value: CheckDigitUtils.digitsOnly(primary),
          isValid: err == null,
          message: err ?? 'Valid SSCC',
        );
      case 'SGTIN':
        return _validateSgtin(lineNumber, primary, serial);
      case 'EPC':
        final ok = Gs1CanonicalIdentifier.isValid(primary);
        return Gs1BatchValidationRow(
          lineNumber: lineNumber,
          type: 'EPC',
          value: primary,
          isValid: ok,
          message: ok ? 'Valid EPC / Digital Link URI' : 'Invalid EPC / Digital Link URI',
        );
      case 'BARCODE':
      case 'AI':
        return _validateBarcode(lineNumber, primary);
      default:
        return Gs1BatchValidationRow(
          lineNumber: lineNumber,
          type: type,
          value: primary,
          isValid: false,
          message: 'Unknown type "$type"',
        );
    }
  }

  static Gs1BatchValidationRow _validateSgtin(
    int lineNumber,
    String primary,
    String? serial,
  ) {
    if (serial != null && serial.isNotEmpty) {
      final err = CheckDigitUtils.validateSgtin(primary, serial);
      return Gs1BatchValidationRow(
        lineNumber: lineNumber,
        type: 'SGTIN',
        value: '${CheckDigitUtils.digitsOnly(primary)} + $serial',
        isValid: err == null,
        message: err ?? 'Valid SGTIN',
      );
    }

    final parsed = GS1BarcodeParser.parseGS1Barcode(primary);
    final gtin = parsed['GTIN']?.toString();
    final ser = parsed['SERIAL']?.toString();
    if (gtin != null && ser != null && ser.isNotEmpty) {
      final err = CheckDigitUtils.validateSgtin(gtin, ser);
      return Gs1BatchValidationRow(
        lineNumber: lineNumber,
        type: 'SGTIN',
        value: primary,
        isValid: err == null,
        message: err ?? 'Valid SGTIN',
      );
    }

    return Gs1BatchValidationRow(
      lineNumber: lineNumber,
      type: 'SGTIN',
      value: primary,
      isValid: false,
      message:
          'Expected SGTIN,<gtin>,<serial> or (01)GTIN(21)SERIAL / Digital Link',
    );
  }

  static Gs1BatchValidationRow _validateBarcode(int lineNumber, String primary) {
    final parsed = GS1BarcodeParser.parseGS1Barcode(primary);
    if (parsed['valid'] == true) {
      return Gs1BatchValidationRow(
        lineNumber: lineNumber,
        type: 'BARCODE',
        value: primary,
        isValid: true,
        message: 'Valid GS1 element string',
      );
    }
    final checkErrors = (parsed['checkDigitErrors'] as List?)
        ?.map((e) => '$e')
        .where((e) => e.isNotEmpty)
        .toList();
    if (checkErrors != null && checkErrors.isNotEmpty) {
      return Gs1BatchValidationRow(
        lineNumber: lineNumber,
        type: 'BARCODE',
        value: primary,
        isValid: false,
        message: checkErrors.join('; '),
      );
    }
    final ais = parsed['parsedData'];
    if (ais is! Map || ais.isEmpty) {
      return Gs1BatchValidationRow(
        lineNumber: lineNumber,
        type: 'BARCODE',
        value: primary,
        isValid: false,
        message: 'Invalid barcode format: missing Application Identifiers',
      );
    }
    return Gs1BatchValidationRow(
      lineNumber: lineNumber,
      type: 'BARCODE',
      value: primary,
      isValid: false,
      message: 'Invalid GS1 barcode data',
    );
  }
}
