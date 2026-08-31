import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';

void main() {
  test('commissioning submission still includes operational batch/lot', () {
    final request = CommissioningRequest(
      gtinCode: '01234567890128',
      serialNumbers: const ['SN-1'],
      batchLotNumber: 'LOT-99',
      commissioningLocationGLN: '0614141000004',
      manufacturingOrigin: 'L',
      expiryDate: DateTime(2027, 1, 1),
      productionDate: DateTime(2026, 1, 1),
    );

    expect(request.toJson()['batchLotNumber'], 'LOT-99');
    expect(request.toJson()['gtinCode'], '01234567890128');
    expect(request.toJson()['serialNumbers'], ['SN-1']);
  });

  test('SSCC commissioning carries available lot and date information', () {
    final request = SsccCommissioningRequest(
      epcUris: const ['urn:epc:id:sscc:62951511511.000074'],
      commissioningLocationGLN: '6295151151105',
      manufacturingOrigin: 'L',
      batchLotNumber: 'LOT-SSCC-1',
      productionDate: DateTime(2026, 8, 27),
      expiryDate: DateTime(2028, 8, 27),
      eventTime: '2026-08-27T09:14:50+04:00',
      eventTimeZoneOffset: '+04:00',
    );

    expect(request.toJson()['batchLotNumber'], 'LOT-SSCC-1');
    expect(request.toJson()['productionDate'], '2026-08-27');
    expect(request.toJson()['expiryDate'], '2028-08-27');
    expect(request.toJson()['eventTime'], '2026-08-27T09:14:50+04:00');
    expect(request.toJson()['eventTimeZoneOffset'], '+04:00');
  });

  test('SSCC commissioning omits blank SGTIN-only fields', () {
    final request = SsccCommissioningRequest(
      epcUris: const ['urn:epc:id:sscc:62951511511.000079'],
      commissioningLocationGLN: '6295151151105',
      manufacturingOrigin: '',
    );

    expect(request.toJson().containsKey('manufacturingOrigin'), isFalse);
    expect(request.toJson().containsKey('shipmentPermit'), isFalse);
  });
}
