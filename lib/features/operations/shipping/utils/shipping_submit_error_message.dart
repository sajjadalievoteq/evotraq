import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_status.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

/// User-facing error text for the create-shipping flow.
abstract final class ShippingSubmitErrorMessage {
  static String epcConversionFailures(List<String> failedBarcodes) {
    if (failedBarcodes.isEmpty) {
      return 'One or more scanned values could not be converted to EPC URIs.';
    }
    final preview = failedBarcodes.take(5).join('\n• ');
    final suffix = failedBarcodes.length > 5
        ? '\n… and ${failedBarcodes.length - 5} more'
        : '';
    return 'Could not convert ${failedBarcodes.length} scan(s) to EPC URIs. '
        'Use a registered SGTIN (GTIN + serial), SSCC, or lot-based GTIN barcode.\n'
        '• $preview$suffix';
  }

  static String emptyEpcList() =>
      'No valid items to ship. Scan at least one SGTIN, SSCC, or lot-based GTIN.';

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
      ShippingStatus.validationError =>
        'Shipping validation failed. Check ship-from and ship-to GLNs and scanned items.',
      ShippingStatus.failed =>
        'Shipping could not be completed. Review scanned items and location details.',
      _ =>
        'The shipping operation could not be completed. Check your inputs and try again.',
    };
  }

  static String fromApiException(ApiException exception) =>
      OperationApiErrorMessage.fromApiException(exception);

  static String unexpected(Object error) =>
      'An unexpected error occurred while submitting shipping: $error';
}
