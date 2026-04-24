import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';

void main() {
  group('GtinFormat', () {
    test('stripGtinInput removes spaces, hyphens, zero-width', () {
      expect(GtinFormat.stripGtinInput('  123-456  '), '123456');
      expect(GtinFormat.stripGtinInput('1234\u00A05678'), '12345678');
    });

    test('calculateCheckDigitForBody (GS1 Mod-10, matches GtinValidationUtil)', () {
      expect(GtinFormat.calculateCheckDigitForBody('1234567890123'), 1);
      expect(GtinFormat.calculateCheckDigitForBody('5061414112345'), 7);
    });

    test('isValidGtin for known 14-digit vectors (GS1 Mod-10)', () {
      expect(GtinFormat.isValidGtin('12345678901231'), isTrue);
      expect(GtinFormat.isValidGtin('50614141123457'), isTrue);
      expect(GtinFormat.isValidGtin('50614141123458'), isFalse);
      expect(GtinFormat.isValidGtin('12345678901232'), isFalse);
      expect(GtinFormat.isValidGtin('12345'), isFalse);
    });

    test('normalizeGtinTo14 pads valid shorter GTINs', () {
      expect(
        GtinFormat.normalizeGtinTo14('12345678901231'),
        '12345678901231',
      );
    });

    test('structureLabelForStrippedInput', () {
      expect(
        GtinFormat.structureLabelForStrippedInput('12345678901231'),
        'GTIN-14',
      );
    });
  });
}
