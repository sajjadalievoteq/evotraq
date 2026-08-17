import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';

void main() {
  test('commissioning submission still includes operational batch/lot', () {
    final request = CommissioningRequest(
      gtinCode: '01234567890128',
      serialNumbers: const ['SN-1'],
      batchLotNumber: 'LOT-99',
      commissioningLocationGLN: '0614141000004',
      expiryDate: DateTime(2027, 1, 1),
      productionDate: DateTime(2026, 1, 1),
    );

    expect(request.toJson()['batchLotNumber'], 'LOT-99');
    expect(request.toJson()['gtinCode'], '01234567890128');
    expect(request.toJson()['serialNumbers'], ['SN-1']);
  });
}
