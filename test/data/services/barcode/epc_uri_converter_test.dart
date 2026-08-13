import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/services/barcode/epc_uri_converter.dart';

void main() {
  group('EPCURIConverter.convertToEPCUri bare 18 digits', () {
    test('prefers SGTIN when first 14 digits are a valid GTIN', () {
      // Also a valid SSCC check digit — must not silently become /00/.
      expect(
        EPCURIConverter.convertToEPCUri('462920004419654152'),
        'https://id.gs1.org/01/46292000441965/21/4152',
      );
    });

    test('emits SSCC only when GTIN path does not apply and SSCC is valid', () {
      expect(
        EPCURIConverter.convertToEPCUri('006141411234567890'),
        'https://id.gs1.org/00/006141411234567890',
      );
    });

    test('returns null when neither GTIN+serial nor SSCC is valid', () {
      expect(EPCURIConverter.convertToEPCUri('111111111111111111'), isNull);
    });

    test('preserves typed Digital Links', () {
      const sgtin = 'https://id.gs1.org/01/46292000441965/21/4152';
      const sscc = 'https://id.gs1.org/00/462920004419654152';
      expect(EPCURIConverter.convertToEPCUri(sgtin), sgtin);
      expect(EPCURIConverter.convertToEPCUri(sscc), sscc);
    });

    test('explicit AI (00) still converts to SSCC Digital Link', () {
      expect(
        EPCURIConverter.convertToEPCUri('(00)006141411234567890'),
        'https://id.gs1.org/00/006141411234567890',
      );
    });
  });
}
