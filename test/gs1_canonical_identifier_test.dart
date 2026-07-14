import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';

void main() {
  group('Gs1CanonicalIdentifier', () {
    const dlSgtin =
        'https://id.gs1.org/01/00629200010000/21/TQNBH47N88OC10RISSH8';
    const aiSgtin = '(01)00629200010000(21)TQNBH47N88OC10RISSH8';
    const dlSscc = 'https://id.gs1.org/00/062920000000009013';
    const lgtin = 'https://id.gs1.org/01/00629200010000/10/LOT123';

    test('forStorage keeps Digital Link SGTIN', () {
      final stored = Gs1CanonicalIdentifier.forStorage(dlSgtin);
      expect(stored.startsWith('https://id.gs1.org/01/'), isTrue);
      expect(Gs1CanonicalIdentifier.isSgtin(stored), isTrue);
    });

    test('AI input classifies as SGTIN after normalize', () {
      expect(Gs1CanonicalIdentifier.isSgtin(aiSgtin), isTrue);
      expect(
        Gs1CanonicalIdentifier.areEquivalent(dlSgtin, aiSgtin),
        isTrue,
      );
    });

    test('SSCC Digital Link', () {
      expect(Gs1CanonicalIdentifier.isSscc(dlSscc), isTrue);
      expect(Gs1CanonicalIdentifier.isSerializedInstance(dlSscc), isTrue);
    });

    test('LGTIN is lot/class level not serialized', () {
      expect(Gs1CanonicalIdentifier.isLgtin(lgtin), isTrue);
      expect(Gs1CanonicalIdentifier.isLotOrClassLevel(lgtin), isTrue);
      expect(Gs1CanonicalIdentifier.isSerializedInstance(lgtin), isFalse);
    });

    test('extractSerial from Digital Link', () {
      expect(
        Gs1CanonicalIdentifier.extractSerial(dlSgtin),
        'TQNBH47N88OC10RISSH8',
      );
    });
  });
}
