import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';

void main() {
  group('parseToEPC', () {
    test('parses GS1 AI SGTIN notation', () {
      final result = parseToEPC(
        '(01)00629200080027(21)Q3W8K5M9X2R7N4P6L1TZ',
      );

      expect(result.type, EPCType.sgtin);
      expect(result.epc, startsWith('https://id.gs1.org/01/'));
      expect(result.epc, contains('/21/Q3W8K5M9X2R7N4P6L1TZ'));
      expect(result.serial, 'Q3W8K5M9X2R7N4P6L1TZ');
      expect(result.gtin, '00629200080027');
    });

    test('parses GS1 AI SSCC notation', () {
      final result = parseToEPC('(00)003664798000000011');

      expect(result.type, EPCType.sscc);
      expect(result.epc, 'https://id.gs1.org/00/003664798000000011');
      expect(result.sscc, '003664798000000011');
    });

    test('parses GS1 AI GTIN-only notation as GTIN', () {
      final result = parseToEPC('(01)00629200080027');

      expect(result.type, EPCType.gtin);
      expect(result.epc, 'https://id.gs1.org/01/00629200080027');
      expect(result.serial, isNull);
      expect(result.gtin, '00629200080027');
    });

    test('normalizes SGTIN URN to Digital Link', () {
      const urn = 'urn:epc:id:sgtin:0629200.008002.SN123';
      final result = parseToEPC(urn);

      expect(result.type, EPCType.sgtin);
      expect(result.epc, 'https://id.gs1.org/01/00629200080027/21/SN123');
      expect(result.serial, 'SN123');
      expect(result.gtin, '00629200080027');
    });

    test('extracts GTIN from SGTIN URN without AI notation', () {
      const urn =
          'urn:epc:id:sgtin:0629200.001000.TQNBH47U88OC10RIRSH8';
      final result = parseToEPC(urn);

      expect(result.type, EPCType.sgtin);
      expect(result.gtin, '00629200010000');
      expect(result.serial, 'TQNBH47U88OC10RIRSH8');
      expect(result.epc, contains('/21/TQNBH47U88OC10RIRSH8'));
    });

    test('normalizes SSCC URN to Digital Link', () {
      const urn = 'urn:epc:id:sscc:0614141.1234567890';
      final result = parseToEPC(urn);

      expect(result.type, EPCType.sscc);
      expect(result.epc, startsWith('https://id.gs1.org/00/'));
      expect(result.epc, hasLength(40));
      expect(result.sscc, isNotNull);
    });

    test('parses GS1 Digital Link SGTIN', () {
      final result = parseToEPC(
        'https://id.gs1.org/01/00629200080027/21/SN123',
      );

      expect(result.type, EPCType.sgtin);
      expect(result.epc, 'https://id.gs1.org/01/00629200080027/21/SN123');
      expect(result.serial, 'SN123');
      expect(result.gtin, '00629200080027');
    });

    test('normalizes plain GTIN-13 to GTIN class Digital Link', () {
      final result = parseToEPC('0629200080027');

      expect(result.type, EPCType.gtin);
      expect(result.gtin, '00629200080027');
      expect(result.epc, 'https://id.gs1.org/01/00629200080027');
    });

    test('parses human-readable GTIN-14 plus serial', () {
      final result = parseToEPC('00629200080027 SN123');

      expect(result.type, EPCType.sgtin);
      expect(result.gtin, '00629200080027');
      expect(result.serial, 'SN123');
      expect(result.epc, 'https://id.gs1.org/01/00629200080027/21/SN123');
    });

    test('parses pipe-delimited GS1 element string from web camera', () {
      const barcode = '|01062911091203601726113010UX9B|2171585936751779';
      final result = parseToEPC(barcode);

      expect(result.type, EPCType.sgtin);
      expect(result.gtin, '06291109120360');
      expect(result.serial, '71585936751779');
      expect(result.epc, contains('/01/06291109120360/'));
      expect(result.epc, contains('/21/71585936751779'));
    });

    test('throws EPCParseException for invalid input', () {
      expect(
        () => parseToEPC('NOTABARCODE'),
        throwsA(isA<EPCParseException>()),
      );
    });
  });
}
