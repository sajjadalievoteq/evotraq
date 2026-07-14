import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/backend_error_parser.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

void main() {
  group('BackendErrorParser', () {
    test('parses messages array (Format A)', () {
      final details = BackendErrorParser.parse({
        'status': 'VALIDATION_ERROR',
        'messages': [
          'sourceEventId is required. A return shipment must reference the original receiving event.',
        ],
      });

      expect(
        details.displayMessage,
        'sourceEventId is required. A return shipment must reference the original receiving event.',
      );
      expect(details.validationMessages, hasLength(1));
    });

    test('parses errors array over generic message (Format B)', () {
      final details = BackendErrorParser.parse({
        'status': 400,
        'code': 'DATA_INTEGRITY_VIOLATION',
        'message': 'Data validation failed. Please check your input.',
        'errors': ['ERROR: value too long for type character(13)'],
      });

      expect(
        details.displayMessage,
        'ERROR: value too long for type character(13)',
      );
      expect(details.code, 'DATA_INTEGRITY_VIOLATION');
    });

    test('falls back to message field (Format C)', () {
      final details = BackendErrorParser.parse({
        'message': 'Operation failed',
      });

      expect(details.displayMessage, 'Operation failed');
    });

    test('parses nested error.messages (Format D)', () {
      final details = BackendErrorParser.parse({
        'error': {
          'messages': ['Invalid location'],
        },
      });

      expect(details.displayMessage, 'Invalid location');
    });

    test('joins multiple messages with newlines', () {
      final details = BackendErrorParser.parse({
        'messages': [
          'Invalid EPC',
          'GTIN not registered',
          'Location mismatch',
        ],
      });

      expect(
        details.displayMessage,
        'Invalid EPC\nGTIN not registered\nLocation mismatch',
      );
      expect(details.validationMessages, hasLength(3));
    });

    test('prefers messages over errors when both exist', () {
      final details = BackendErrorParser.parse({
        'messages': ['EPC is not ACTIVE'],
        'errors': ['should not appear'],
        'message': 'generic',
      });

      expect(details.displayMessage, 'EPC is not ACTIVE');
    });

    test('parses JSON string bodies', () {
      final details = BackendErrorParser.parse(
        '{"messages":["Shipment has already been received"]}',
      );

      expect(details.displayMessage, 'Shipment has already been received');
    });

    test('detects VALIDATION_ERROR structured body', () {
      expect(
        BackendErrorParser.isStructuredErrorBody({
          'status': 'VALIDATION_ERROR',
          'messages': ['sourceEventId is required'],
        }),
        isTrue,
      );
    });
  });

  group('ApiException.getUserFriendlyMessage', () {
    test('surfaces messages from responseBody over generic fallback', () {
      final exception = ApiException(
        statusCode: 422,
        message: 'Failed to create receiving operation',
        responseBody:
            '{"status":"VALIDATION_ERROR","messages":["sourceEventId is required. A return shipment must reference the original receiving event."]}',
      );

      expect(
        exception.getUserFriendlyMessage(),
        'sourceEventId is required. A return shipment must reference the original receiving event.',
      );
    });

    test('surfaces errors array for data integrity violations', () {
      final exception = ApiException(
        statusCode: 400,
        code: 'DATA_INTEGRITY_VIOLATION',
        message: 'Failed to create operation',
        responseBody:
            '{"status":400,"code":"DATA_INTEGRITY_VIOLATION","message":"Data validation failed. Please check your input.","errors":["ERROR: value too long for type character(13)"]}',
      );

      expect(
        exception.getUserFriendlyMessage(),
        'ERROR: value too long for type character(13)',
      );
    });

    test('uses validationMessages when body is empty', () {
      final exception = ApiException(
        statusCode: 400,
        message: 'Failed to create shipping operation',
        validationMessages: const ['EPC is not ACTIVE'],
      );

      expect(exception.getUserFriendlyMessage(), 'EPC is not ACTIVE');
    });
  });

  group('OperationApiErrorMessage', () {
    test('fromApiException prefers parsed backend text', () {
      final exception = ApiException(
        statusCode: 400,
        message: 'Failed to create shipping operation',
        responseBody: '{"messages":["EPC is not ACTIVE"]}',
      );

      expect(
        OperationApiErrorMessage.fromApiException(exception),
        'EPC is not ACTIVE',
      );
    });
  });
}
