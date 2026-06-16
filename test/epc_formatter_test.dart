import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';

void main() {
  group('EPCFormatter Tests', () {
    test('Format URI EPC - already in correct format', () {
      const input = 'urn:epc:id:sgtin:5415062.32581.70005188444899';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, input);
    });

    test('Format GS1 barcode format with parentheses to URI', () {
      const input = '(01)05415062325810(21)70005188444899';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, 'urn:epc:id:sgtin:5415062.032581.70005188444899');
    });

    test('Format GS1 barcode with AI (00) GTIN to URI', () {
      const input = '(00)00629200080027(21)VKIH2AWX9KN8RIHED75T';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, 'urn:epc:id:sgtin:062920.0008002.VKIH2AWX9KN8RIHED75T');
    });

    test('Format bare SGTIN body to URI', () {
      const input = '062920.0008002.VKIH2AWX9KN8RIHED75T';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, 'urn:epc:id:sgtin:$input');
    });

    test('Empty string returns null', () {
      const input = '';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, isNull);
    });

    test('Invalid format returns null', () {
      const input = 'not-a-valid-format';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, isNull);
    });

    test('AI string without serial returns null', () {
      const input = '(01)00629200080027';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, isNull);
    });

    test('isLikelyGS1Barcode detects GS1 barcode format with parentheses', () {
      const input = '(01)05415062325810(21)70005188444899';
      final result = EPCFormatter.isLikelyGS1Barcode(input);
      expect(result, true);
    });

    test('isLikelyGS1Barcode detects GS1 barcode format without parentheses', () {
      const input = '0105415062325810217000518844489';
      final result = EPCFormatter.isLikelyGS1Barcode(input);
      expect(result, true);
    });

    test('isLikelyGS1Barcode returns false for URI format', () {
      const input = 'urn:epc:id:sgtin:5415062.32581.70005188444899';
      final result = EPCFormatter.isLikelyGS1Barcode(input);
      expect(result, false);
    });

    test('formatListToEPCUri handles mixed format list', () {
      final inputs = [
        'urn:epc:id:sgtin:5415062.32581.70005188444899',
        '(01)05415062325810(21)70005188444899',
        '(01)05415062325810(21)70005188444900',
      ];
      final results = EPCFormatter.formatListToEPCUri(inputs);

      expect(results[0], 'urn:epc:id:sgtin:5415062.32581.70005188444899');
      expect(results[1], 'urn:epc:id:sgtin:5415062.032581.70005188444899');
      expect(results[2], 'urn:epc:id:sgtin:5415062.032581.70005188444900');
    });
  });

  group('GS1BarcodeParser.parseAIString', () {
    test('parses AI (01) GTIN and serial', () {
      final parsed = GS1BarcodeParser.parseAIString(
        '(01)05415062325810(21)70005188444899',
      );
      expect(parsed, isNotNull);
      expect(parsed!['GTIN'], '05415062325810');
      expect(parsed['SERIAL'], '70005188444899');
    });

    test('parses AI (00) GTIN and serial', () {
      final parsed = GS1BarcodeParser.parseAIString(
        '(00)00629200080027(21)VKIH2AWX9KN8RIHED75T',
      );
      expect(parsed, isNotNull);
      expect(parsed!['GTIN'], '00629200080027');
      expect(parsed['SERIAL'], 'VKIH2AWX9KN8RIHED75T');
    });

    test('returns null when serial AI is missing', () {
      final parsed = GS1BarcodeParser.parseAIString('(01)00629200080027');
      expect(parsed, isNull);
    });
  });
}
