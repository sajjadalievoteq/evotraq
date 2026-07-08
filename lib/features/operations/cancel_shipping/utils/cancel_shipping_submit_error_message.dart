import 'package:traqtrace_app/core/utils/operation_error_translator.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

abstract final class CancelShippingSubmitErrorMessage {
  static String missingCancelReason() =>
      'A cancellation reason is required (DSCSA §582 / FMD Art. 22).';

  static String missingGinc() =>
      'Original shipping reference (GINC) is required for DSCSA compliance.';

  static String epcConversionFailures(List<String> failedBarcodes) =>
      OperationApiErrorMessage.epcConversionFailures(failedBarcodes);

  static String emptyEpcList() =>
      'No valid items to cancel. Scan at least one SGTIN or SSCC.';

  static String fromResponse(CancelShippingResponse response) {
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
        'Cancel shipping validation failed. Check locations, cancellation reason, and scanned items.',
      OperationStatus.failed =>
        'Cancel shipping could not be completed. Review scanned items and location details.',
      _ =>
        'The cancel shipping operation could not be completed. Check your inputs and try again.',
    };
  }

  static String fromApiException(ApiException exception) =>
      OperationApiErrorMessage.fromApiException(exception);

  static String unexpected(Object error) =>
      OperationApiErrorMessage.unexpected('cancel shipping', error);
}
