import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

void main() {
  group('GS1BarcodeParser Tests', () {
    test('Parse GS1 barcode with parentheses', () {
      final result = GS1BarcodeParser.parseGS1Barcode('(01)18902411114026(17)210228(10)AFG8007A(21)0SIATXTA39607034P');
      
      expect(result['valid'], isTrue);
      expect(result['GTIN'], '18902411114026');
      expect(result['EXPIRY'], '210228');
      expect(result['BATCH'], 'AFG8007A');
      expect(result['SERIAL'], '0SIATXTA39607034P');
      expect(result['EXPIRY_FORMATTED'], '2021-02-28');
    });

    test('Parse raw concatenated barcode', () {
      final result = GS1BarcodeParser.parseGS1Barcode('01189024111140261721022810AFG8007A210SIATXTA39607034P');
      
      expect(result['valid'], isTrue);
      expect(result['GTIN'], '18902411114026');
      expect(result['EXPIRY'], '210228');
      expect(result['BATCH'], 'AFG8007A');
      expect(result['SERIAL'], '0SIATXTA39607034P');
    });

    test('Parse barcode with FNC1 separator', () {
      // Simulate FNC1 character (ASCII 29)
      String barcode = '01189024111140261721022810AFG8007A';
      barcode += String.fromCharCode(29);
      barcode += '210SIATXTA39607034P';
      
      final result = GS1BarcodeParser.parseGS1Barcode(barcode);
      
      expect(result['valid'], isTrue);
      expect(result['GTIN'], '18902411114026');
      expect(result['EXPIRY'], '210228');
      expect(result['BATCH'], 'AFG8007A');
      expect(result['SERIAL'], '0SIATXTA39607034P');
    });

    test('Parse barcode with pipe as FNC1 (web/HID scanners)', () {
      const barcode = '|01062911091203601726113010UX9B|2171585936751779';

      final result = GS1BarcodeParser.parseGS1Barcode(barcode);

      expect(result['valid'], isTrue);
      expect(result['GTIN'], '06291109120360');
      expect(result['EXPIRY'], '261130');
      expect(result['BATCH'], 'UX9B');
      expect(result['SERIAL'], '71585936751779');
    });

    test('Parse invalid barcode', () {
      final result = GS1BarcodeParser.parseGS1Barcode('INVALID_CODE');
      
      expect(result['valid'], isFalse);
      expect(result['GTIN'], isNull);
    });
  });
}
