import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

/// User-facing error text for the create-shipping flow.
abstract final class ShippingSubmitErrorMessage {
  static String epcConversionFailures(List<String> failedBarcodes) =>
      OperationApiErrorMessage.epcConversionFailures(failedBarcodes);

  static String emptyEpcList() =>
      'No valid items to ship. Scan at least one SGTIN or SSCC.';

  static String fromResponse(ShippingResponse response) {
    final messages = response.messages
        ?.map(OperationApiErrorMessage.cleanLine)
        .whereType<String>()
        .where((m) => m.isNotEmpty)
        .toList();
    if (messages != null && messages.isNotEmpty) {
      return messages.join('\n');
    }

    return switch (response.status) {
      OperationStatus.validationError =>
        'Shipping validation failed. Check ship-from and ship-to GLNs and scanned items.',
      OperationStatus.failed =>
        'Shipping could not be completed. Review scanned items and location details.',
      _ =>
        'The shipping operation could not be completed. Check your inputs and try again.',
    };
  }

  static String fromApiException(ApiException exception) =>
      OperationApiErrorMessage.fromApiException(exception);

  static String unexpected(Object error) =>
      OperationApiErrorMessage.unexpected('shipping', error);
}
