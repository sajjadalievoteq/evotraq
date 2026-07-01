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
      expect(result.epc, startsWith('urn:epc:id:sgtin:'));
      expect(result.serial, 'Q3W8K5M9X2R7N4P6L1TZ');
      expect(result.gtin, '00629200080027');
    });

    test('parses GS1 AI SSCC notation', () {
      final result = parseToEPC('(00)003664798000000011');

      expect(result.type, EPCType.sscc);
      expect(result.epc, startsWith('urn:epc:id:sscc:'));
      expect(result.sscc, '003664798000000011');
    });

    test('parses GS1 AI GTIN-only notation as GTIN', () {
      final result = parseToEPC('(01)00629200080027');

      expect(result.type, EPCType.gtin);
      expect(result.epc, startsWith('urn:epc:idpat:sgtin:'));
      expect(result.serial, isNull);
      expect(result.gtin, '00629200080027');
    });

    test('passes through SGTIN URN unchanged', () {
      const urn = 'urn:epc:id:sgtin:0629200.008002.SN123';
      final result = parseToEPC(urn);

      expect(result.type, EPCType.sgtin);
      expect(result.epc, urn);
      expect(result.serial, 'SN123');
    });

    test('passes through SSCC URN unchanged', () {
      const urn = 'urn:epc:id:sscc:0629200.108002700000001';
      final result = parseToEPC(urn);

      expect(result.type, EPCType.sscc);
      expect(result.epc, urn);
    });

    test('parses GS1 Digital Link SGTIN', () {
      final result = parseToEPC(
        'https://id.gs1.org/01/00629200080027/21/SN123',
      );

      expect(result.type, EPCType.sgtin);
      expect(result.epc, startsWith('urn:epc:id:sgtin:'));
      expect(result.serial, 'SN123');
      expect(result.gtin, '00629200080027');
    });

    test('normalizes plain GTIN-13 to GTIN class EPC', () {
      final result = parseToEPC('0629200080027');

      expect(result.type, EPCType.gtin);
      expect(result.gtin, '00629200080027');
      expect(result.epc, startsWith('urn:epc:idpat:sgtin:'));
    });

    test('throws EPCParseException for invalid input', () {
      expect(
        () => parseToEPC('NOTABARCODE'),
        throwsA(isA<EPCParseException>()),
      );
    });
  });
}
