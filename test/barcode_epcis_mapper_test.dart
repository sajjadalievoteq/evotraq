import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/barcode/services/barcode_epcis_mapper.dart';

class _FakeBarcodeFormat {
  _FakeBarcodeFormat(this.name);
  final String name;
}

class _FakeBarcode {
  _FakeBarcode(this.rawValue, {this.formatName = 'qrCode'});
  final String? rawValue;
  final String formatName;

  _FakeBarcodeFormat get format => _FakeBarcodeFormat(formatName);
}

void main() {
  group('BarcodeToEPCISMapper', () {
    const dlSgtin =
        'https://id.gs1.org/01/00629200010000/21/TQNBH47N88OC10RISSH8';
    const urnSgtin =
        'urn:epc:id:sgtin:062920.0010000.TQNBH47N88OC10RISSH8';
    const dlSscc = 'https://id.gs1.org/00/062920000000009013';
    const urnSscc = 'urn:epc:id:sscc:0614141.1234567890';

    late BarcodeToEPCISMapper mapper;

    setUp(() {
      mapper = BarcodeToEPCISMapper();
    });

    Future<String?> epcTypeFor(String rawValue) async {
      final event = await mapper.mapBarcodeToEPCISEvent(
        _FakeBarcode(rawValue),
        'urn:epcglobal:cbv:bizstep:observing',
        'urn:epcglobal:cbv:disp:in_progress',
        '0614141007776',
        '0614141007776',
      );
      expect(event, isA<ObjectEvent>());
      return (event as ObjectEvent).bizData?['epcType'] as String?;
    }

    test('classifies Digital Link SGTIN', () async {
      expect(await epcTypeFor(dlSgtin), 'SGTIN');
    });

    test('classifies URN SGTIN equivalently', () async {
      expect(await epcTypeFor(urnSgtin), 'SGTIN');
    });

    test('URN and Digital Link map to same canonical epcList', () async {
      final fromDl = await mapper.mapBarcodeToEPCISEvent(
        _FakeBarcode(dlSgtin),
        'urn:epcglobal:cbv:bizstep:observing',
        'urn:epcglobal:cbv:disp:in_progress',
        '0614141007776',
        '0614141007776',
      ) as ObjectEvent;
      final fromUrn = await mapper.mapBarcodeToEPCISEvent(
        _FakeBarcode(urnSgtin),
        'urn:epcglobal:cbv:bizstep:observing',
        'urn:epcglobal:cbv:disp:in_progress',
        '0614141007776',
        '0614141007776',
      ) as ObjectEvent;
      expect(fromDl.epcList, isNotEmpty);
      expect(fromUrn.epcList, isNotEmpty);
      expect(fromDl.epcList!.first.startsWith('https://id.gs1.org/'), isTrue);
      expect(fromUrn.epcList!.first.startsWith('https://id.gs1.org/'), isTrue);
    });

    test('classifies Digital Link SSCC', () async {
      expect(await epcTypeFor(dlSscc), 'SSCC');
    });

    test('classifies URN SSCC equivalently', () async {
      expect(await epcTypeFor(urnSscc), 'SSCC');
    });

    test('classifies GS1 AI SGTIN via element strings', () async {
      const aiSgtin = '(01)00629200010000(21)TQNBH47N88OC10RISSH8';
      final event = await mapper.mapBarcodeToEPCISEvent(
        _FakeBarcode(aiSgtin),
        'urn:epcglobal:cbv:bizstep:observing',
        'urn:epcglobal:cbv:disp:in_progress',
        '0614141007776',
        '0614141007776',
      );
      expect(event, isA<ObjectEvent>());
      final objectEvent = event as ObjectEvent;
      expect(objectEvent.epcList, isNotEmpty);
      expect(objectEvent.bizData?['scanSource'], 'gs1_barcode');
    });
  });
}
