import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_status.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

abstract final class CancelReceivingSubmitErrorMessage {
  static String missingCancelReason() =>
      'A cancellation reason is required (DSCSA §582 / FMD Art. 22).';

  static String missingGinc() =>
      'Original receiving reference (GINC) is required for DSCSA compliance.';

  static String epcConversionFailures(List<String> failedBarcodes) {
    if (failedBarcodes.isEmpty) {
      return 'One or more scanned values could not be converted to EPC URIs.';
    }
    final preview = failedBarcodes.take(5).join('\n• ');
    final suffix = failedBarcodes.length > 5
        ? '\n… and ${failedBarcodes.length - 5} more'
        : '';
    return 'Could not convert ${failedBarcodes.length} scan(s) to EPC URIs. '
        'Use a registered SGTIN (GTIN + serial) or SSCC.\n'
        '• $preview$suffix';
  }

  static String emptyEpcList() =>
      'No valid items to cancel. Scan at least one SGTIN or SSCC.';

  static String fromResponse(CancelReceivingResponse response) {
    final messages = response.messages
        ?.map(OperationApiErrorMessage.cleanLine)
        .whereType<String>()
        .where((m) => m.isNotEmpty)
        .toList();
    if (messages != null && messages.isNotEmpty) {
      return messages.join('\n');
    }

    return switch (response.status) {
      CancelReceivingStatus.validationError =>
        'Cancel receiving validation failed. Check locations, cancellation reason, and scanned items.',
      CancelReceivingStatus.failed =>
        'Cancel receiving could not be completed. Review scanned items and location details.',
      _ =>
        'The cancel receiving operation could not be completed. Check your inputs and try again.',
    };
  }

  static String fromApiException(ApiException exception) =>
      OperationApiErrorMessage.fromApiException(exception);

  static String unexpected(Object error) =>
      'An unexpected error occurred while submitting cancel receiving: $error';
}
