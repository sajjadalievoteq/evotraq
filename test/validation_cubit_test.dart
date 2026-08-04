import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/validation/validation_status.dart';
import 'package:traqtrace_app/data/services/epcis/validation_service.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';

class _MockValidationService extends Mock implements ValidationService {}

void main() {
  group('ValidationCubit field state', () {
    late ValidationCubit cubit;

    setUp(() {
      cubit = ValidationCubit(validationService: _MockValidationService());
    });

    test('starts with empty field errors', () {
      expect(cubit.state.fieldErrors, isEmpty);
    });

    test('setFieldError stores and clears errors', () {
      cubit.setFieldError('gtin', 'Invalid GTIN');
      expect(cubit.getFieldError('gtin'), 'Invalid GTIN');

      cubit.setFieldError('gtin', null);
      expect(cubit.getFieldError('gtin'), isNull);
    });

    test('validateField returns invalid and valid', () {
      String? validator(String value) => value.isEmpty ? 'Required' : null;

      expect(cubit.validateField('field', '', validator), isFalse);
      expect(cubit.getFieldError('field'), 'Required');

      expect(cubit.validateField('field', 'ok', validator), isTrue);
      expect(cubit.getFieldError('field'), isNull);
    });

    test('status transitions notValidated -> invalid -> valid', () {
      expect(cubit.fieldStatus('bizStep'), ValidationStatus.notValidated);
      cubit.setFieldError('bizStep', 'Bad step');
      expect(cubit.fieldStatus('bizStep'), ValidationStatus.invalid);
      cubit.markFieldAsValid('bizStep');
      expect(cubit.fieldStatus('bizStep'), ValidationStatus.valid);
      expect(cubit.hasBeenValidated('bizStep'), isTrue);
    });

    test('validateAllFields maps errors and returns overall validity', () {
      final isValid = cubit.validateAllFields({
        'gtin': {
          'value': '',
          'validator': (String? v) =>
              (v == null || v.isEmpty) ? 'gtinCode must not be blank' : null,
        },
        'serial': {
          'value': 'ABC',
          'validator': (String? v) => null,
        },
      });

      expect(isValid, isFalse);
      expect(cubit.getFieldError('gtin'), 'gtinCode must not be blank');
      expect(cubit.getFieldError('serial'), isNull);
      expect(cubit.hasBeenValidated('serial'), isTrue);
    });

    test('clearFieldError removes a single field', () {
      cubit.setFieldError('a', 'err');
      cubit.setFieldError('b', 'err');
      cubit.clearFieldError('a');
      expect(cubit.hasBeenValidated('a'), isFalse);
      expect(cubit.getFieldError('b'), 'err');
    });
  });
}
