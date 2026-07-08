import 'package:traqtrace_app/core/utils/operation_error_translator.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

abstract final class UpdateStatusSubmitErrorMessage {
  static String epcConversionFailures(List<String> failedBarcodes) =>
      OperationApiErrorMessage.epcConversionFailures(failedBarcodes);

  static String emptyEpcList() =>
      'No valid items selected. Scan at least one SGTIN serial.';

  static String fromResponse(UpdateStatusResponse response) {
    final messages = response.messages
        ?.map(OperationApiErrorMessage.cleanLine)
        .whereType<String>()
        .where((m) => m.isNotEmpty)
        .map((m) => OperationErrorTranslator.translate(m, fallback: m))
        .toList();
    if (messages != null && messages.isNotEmpty) {
      return messages.join('\n');
    }

    return switch (response.status) {
      OperationStatus.validationError =>
        'Update Status validation failed. Check location GLN, status, and scanned items.',
      OperationStatus.failed =>
        'Update Status could not be completed. Review scanned items and location details.',
      _ =>
        'The Update Status operation could not be completed. Check your inputs and try again.',
    };
  }

  static String fromApiException(ApiException exception) =>
      OperationApiErrorMessage.fromApiException(exception);

  static String unexpected(Object error) =>
      OperationApiErrorMessage.unexpected('Update Status', error);
}
