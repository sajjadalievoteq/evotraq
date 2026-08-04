import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/validation/validation_error_mapper.dart';

void main() {
  group('ValidationErrorMapper', () {
    test('maps backend field to frontend field', () {
      final result = ValidationErrorMapper.mapErrors([
        {'field': 'gtinCode', 'message': 'gtinCode must not be blank'},
      ], {
        'gtincode': 'gtin',
      });

      expect(result['gtin'], 'gtinCode must not be blank');
    });

    test('extracts field name from validation message', () {
      final result = ValidationErrorMapper.mapErrors([
        'The field "eventTime" is required',
      ], {
        'eventtime': 'eventTimeField',
      });

      expect(result['eventTimeField'], 'The field "eventTime" is required');
    });

    test('falls back to general error when no field found', () {
      final result = ValidationErrorMapper.mapErrors([
        'Validation failed due to unknown constraint',
      ], const {});

      expect(result['_general'], 'Validation failed due to unknown constraint');
    });
  });
}
