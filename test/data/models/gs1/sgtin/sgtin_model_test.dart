import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';

void main() {
  test('serializes calendar dates without timezone conversion', () {
    final sgtin = SGTIN(
      gtinCode: '06291107791319',
      serialNumber: 'SERIAL-1',
      expiryDate: DateTime(2029, 8, 26),
      productionDate: DateTime(2026, 8, 26),
      bestBeforeDate: DateTime(2029, 7, 26),
      retentionExpiry: DateTime(2030, 8, 26),
      status: ItemStatus.ALLOCATED,
      createdAt: DateTime.utc(2026, 8, 26, 10, 28),
    );

    final json = sgtin.toJson();

    expect(json['expiryDate'], '2029-08-26');
    expect(json['productionDate'], '2026-08-26');
    expect(json['bestBeforeDate'], '2029-07-26');
    expect(json['retentionExpiry'], '2030-08-26');
    expect(json['createdAt'], '2026-08-26T10:28:00.000Z');
  });
}
