import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_epc_validators.dart';

void main() {
  group('EpcisEpcValidators', () {
    const dlSgtin =
        'https://id.gs1.org/01/00629200010000/21/TQNBH47N88OC10RISSH8';
    const urnSgtin =
        'urn:epc:id:sgtin:062920.0010000.TQNBH47N88OC10RISSH8';
    const dlSscc = 'https://id.gs1.org/00/062920000000009013';

    test('accepts Digital Link SGTIN', () {
      expect(EpcisEpcValidators.validateEpcOrBarcode(dlSgtin), isNull);
    });

    test('accepts URN SGTIN', () {
      expect(EpcisEpcValidators.validateEpcOrBarcode(urnSgtin), isNull);
    });

    test('accepts GS1 AI element string after normalization', () {
      const aiSgtin = '(01)00629200010000(21)TQNBH47N88OC10RISSH8';
      final normalized = Gs1CanonicalIdentifier.forStorage(aiSgtin);
      expect(EpcisEpcValidators.validateEpcOrBarcode(normalized), isNull);
    });

    test('accepts Digital Link SSCC', () {
      expect(EpcisEpcValidators.validateEpcOrBarcode(dlSscc), isNull);
    });

    test('rejects invalid identity', () {
      expect(
        EpcisEpcValidators.validateEpcOrBarcode('not-an-epc'),
        isNotNull,
      );
    });

    test('Digital Link and AI normalize to equivalent storage', () {
      const aiSgtin = '(01)00629200010000(21)TQNBH47N88OC10RISSH8';
      expect(
        Gs1CanonicalIdentifier.areEquivalent(dlSgtin, aiSgtin),
        isTrue,
      );
    });
  });
}
