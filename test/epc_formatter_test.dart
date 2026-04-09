import 'package:flutter_test/flutter_test.dart';
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
      expect(result, 'urn:epc:id:sgtin:5415062.32581.70005188444899');
    });

    test('Empty string returns empty string', () {
      const input = '';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, '');
    });

    test('Invalid format returns original input', () {
      const input = 'not-a-valid-format';
      final result = EPCFormatter.formatToEPCUri(input);
      expect(result, input);
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
        '(01)05415062325810(21)70005188444900'
      ];
      final results = EPCFormatter.formatListToEPCUri(inputs);
      
      expect(results[0], 'urn:epc:id:sgtin:5415062.32581.70005188444899');
      expect(results[1], 'urn:epc:id:sgtin:5415062.32581.70005188444899');
      expect(results[2], 'urn:epc:id:sgtin:5415062.32581.70005188444900');
    });
  });
}
