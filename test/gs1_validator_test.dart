import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1_validator.dart';
import 'package:traqtrace_app/features/shared/validation/gs1_batch_validator.dart';

void main() {
  group('CheckDigitUtils — GS1 mod-10', () {
    test('calculates known check digits', () {
      
      expect(CheckDigitUtils.calculateMod10('1234567890123'), 1);
      
      expect(CheckDigitUtils.calculateMod10('5061414112345'), 7);
      
      expect(CheckDigitUtils.calculateMod10('123456789012'), 8);
      
      expect(CheckDigitUtils.calculateMod10('10614141234567890'), 8);
    });

    test('valid GTIN-8/12/13/14 pass; wrong check digit fails', () {
      
      expect(CheckDigitUtils.isValidGtin('12345678901231'), isTrue);
      expect(CheckDigitUtils.isValidGtin('50614141123457'), isTrue);
      expect(CheckDigitUtils.isValidGtin('12345678901232'), isFalse);

      expect(CheckDigitUtils.isValidGtin('4006381333931'), isTrue);
      expect(CheckDigitUtils.isValidGtin('9501101530003'), isTrue);
      expect(CheckDigitUtils.validateGtin('4006381333931'), isNull);
      expect(
        CheckDigitUtils.validateGtin('4006381333932'),
        contains('check digit'),
      );

      expect(CheckDigitUtils.isValidGtin('042100005264'), isTrue);
      expect(CheckDigitUtils.isValidGtin('042100005265'), isFalse);

      expect(
        CheckDigitUtils.validateGtin('12345'),
        contains('invalid length'),
      );
      expect(
        CheckDigitUtils.validateGtin('123456789012345'),
        contains('invalid length'),
      );
    });

    test('valid GLN-13 passes; mutated digit fails', () {
      expect(CheckDigitUtils.isValidGln('1234567890128'), isTrue);
      expect(CheckDigitUtils.isValidGln('6141411000006'), isTrue);
      expect(CheckDigitUtils.isValidGln('1234567890127'), isFalse);
      expect(CheckDigitUtils.isValidGln('123456789012'), isFalse);
    });

    test('valid SSCC-18 passes; mutated digit fails', () {
      expect(CheckDigitUtils.isValidSscc('106141412345678908'), isTrue);
      expect(CheckDigitUtils.isValidSscc('000123456000000005'), isTrue);
      expect(CheckDigitUtils.isValidSscc('106141412345678909'), isFalse);
      expect(CheckDigitUtils.isValidSscc('10614141234567890'), isFalse);
    });

    test('SGTIN = GTIN + AI-21 serial', () {
      expect(
        CheckDigitUtils.isValidSgtin('12345678901231', 'ABC123'),
        isTrue,
      );
      expect(
        CheckDigitUtils.isValidSgtin('50614141123457', 'SN001'),
        isTrue,
      );
      expect(
        CheckDigitUtils.isValidSgtin('12345678901232', 'ABC123'),
        isFalse,
      );
      expect(CheckDigitUtils.isValidSgtin('12345678901231', ''), isFalse);
      expect(CheckDigitUtils.isValidSgtin('12345678901231', null), isFalse);
      expect(
        CheckDigitUtils.isValidSgtin(
          '12345678901231',
          '123456789012345678901',
        ),
        isFalse,
      );
    });
  });

  group('GS1Validator facade delegates to CheckDigitUtils', () {
    test('GTIN / GLN / SSCC / SGTIN', () {
      expect(GS1Validator.isValidGTIN('4006381333931'), isTrue);
      expect(GS1Validator.isValidGTIN('12345678901231'), isTrue);
      expect(GS1Validator.isValidGTIN('12345678901232'), isFalse);
      expect(GS1Validator.isValidGLN('1234567890128'), isTrue);
      expect(GS1Validator.isValidSSCC('106141412345678908'), isTrue);
      expect(
        GS1Validator.isValidSGTIN('12345678901231', 'ABC123'),
        isTrue,
      );
    });

    test('barcode element string uses parser + check digits', () {
      expect(
        GS1Validator.validateBarcodeData('(01)12345678901231(21)ABC123'),
        isNull,
      );
      expect(
        GS1Validator.validateBarcodeData(null),
        'Barcode data cannot be empty',
      );
      
      expect(GS1Validator.validateBarcodeData('0112345678901231'), isNull);
      
      expect(
        GS1Validator.validateBarcodeData('(01)12345678901232'),
        contains('check digit'),
      );
      expect(
        GS1Validator.validateBarcodeData('not-a-gs1-string'),
        contains('Application Identifiers'),
      );
    });
  });

  group('Gs1BatchValidator — user-supplied input only', () {
    test('validates typed CSV / paste lines', () {
      const paste = '''
# comment ignored
GTIN,4006381333931
GTIN,4006381333932
GLN,1234567890128
SSCC,106141412345678908
SGTIN,12345678901231,ABC123
''';
      final rows = Gs1BatchValidator.validatePaste(paste);
      expect(rows.length, 5);
      expect(rows[0].isValid, isTrue);
      expect(rows[0].type, 'GTIN');
      expect(rows[1].isValid, isFalse);
      expect(rows[1].message, contains('check digit'));
      expect(rows[2].isValid, isTrue);
      expect(rows[3].isValid, isTrue);
      expect(rows[4].isValid, isTrue);
    });

    test('bare digits auto-detect length (incl. GTIN-13)', () {
      final rows = Gs1BatchValidator.validatePaste(
        '4006381333931\n106141412345678908\n12345',
      );
      expect(rows[0].type, 'GTIN');
      expect(rows[0].isValid, isTrue);
      expect(rows[1].type, 'SSCC');
      expect(rows[1].isValid, isTrue);
      expect(rows[2].isValid, isFalse);
    });
  });
}