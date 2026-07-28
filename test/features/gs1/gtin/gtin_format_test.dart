import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';

void main() {
  group('GtinFormat delegates to CheckDigitUtils', () {
    test('stripGtinInput removes spaces, hyphens, zero-width', () {
      expect(GtinFormat.stripGtinInput('  123-456  '), '123456');
      expect(GtinFormat.stripGtinInput('1234\u00A05678'), '12345678');
    });

    test('calculateCheckDigitForBody uses CheckDigitUtils mod-10', () {
      expect(GtinFormat.calculateCheckDigitForBody('1234567890123'), 1);
      expect(GtinFormat.calculateCheckDigitForBody('5061414112345'), 7);
      expect(
        GtinFormat.calculateCheckDigitForBody('1234567890123'),
        CheckDigitUtils.calculateMod10('1234567890123'),
      );
    });

    test('isValidGtin for known vectors including GTIN-13', () {
      expect(GtinFormat.isValidGtin('12345678901231'), isTrue);
      expect(GtinFormat.isValidGtin('50614141123457'), isTrue);
      expect(GtinFormat.isValidGtin('50614141123458'), isFalse);
      expect(GtinFormat.isValidGtin('12345678901232'), isFalse);
      expect(GtinFormat.isValidGtin('4006381333931'), isTrue);
      expect(GtinFormat.isValidGtin('12345'), isFalse);
    });

    test('normalizeGtinTo14 pads valid shorter GTINs', () {
      expect(
        GtinFormat.normalizeGtinTo14('12345678901231'),
        '12345678901231',
      );
      expect(
        GtinFormat.normalizeGtinTo14('4006381333931'),
        '04006381333931',
      );
    });

    test('structureLabelForStrippedInput', () {
      expect(
        GtinFormat.structureLabelForStrippedInput('12345678901231'),
        'GTIN-14',
      );
      expect(
        GtinFormat.structureLabelForStrippedInput('4006381333931'),
        'GTIN-13',
      );
    });
  });
}
