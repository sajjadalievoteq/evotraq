import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart';

void main() {
  group('validateBatchLotNumber', () {
    test('requires a value', () {
      expect(validateBatchLotNumber(null), 'Batch/lot number is required');
      expect(validateBatchLotNumber(''), 'Batch/lot number is required');
      expect(validateBatchLotNumber('   '), 'Batch/lot number is required');
    });

    test('accepts a valid GS1 batch lot', () {
      expect(validateBatchLotNumber('LOT-2026-08'), isNull);
    });

    test('rejects invalid or oversized values', () {
      expect(validateBatchLotNumber('LOT~2026'), isNotNull);
      expect(validateBatchLotNumber('123456789012345678901'), isNotNull);
    });
  });
}
