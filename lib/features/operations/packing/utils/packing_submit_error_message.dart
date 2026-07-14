import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

/// User-facing packing error text for wizard submit and API failures.
abstract final class PackingSubmitErrorMessage {
  static String epcConversionFailures(List<String> failedBarcodes) =>
      OperationApiErrorMessage.epcConversionFailures(failedBarcodes);

  static String emptyEpcList() =>
      'No valid items to pack. Scan at least one product label with a GTIN and serial number.';

  static String fromResponse(PackingResponse response) {
    final messages = response.messages
        ?.map(OperationApiErrorMessage.cleanLine)
        .whereType<String>()
        .where((m) => m.isNotEmpty && m != 'Validation passed')
        .map(translate)
        .toList();
    if (messages != null && messages.isNotEmpty) {
      return messages.join('\n');
    }

    return switch (response.status) {
      OperationStatus.validationError =>
        'Packing validation failed. Check the parent container, scanned items, and packing location.',
      OperationStatus.failed =>
        'Packing could not be completed. Review the parent container and item list, then try again.',
      _ =>
        'The packing operation could not be completed. Check your inputs and try again.',
    };
  }

  static String fromApiException(ApiException exception) =>
      translate(OperationApiErrorMessage.fromApiException(exception));

  static String translate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Packing could not be completed. Check the parent container, items, and location.';
    }

    final text = raw.trim();
    final lower = text.toLowerCase();

    if (lower.contains('parent container was not found') ||
        lower.contains('parent sgtin not found') ||
        lower.contains('parent container (case or bundle) was not found')) {
      return 'The parent container was not found. Commission the case, bundle, or SSCC in Commissioning before packing into it.';
    }
    if (lower.contains('parent container (sscc) was not found') ||
        lower.contains('commission the carton or pallet')) {
      return 'The parent container (SSCC) was not found. Commission the carton or pallet in the SSCC module before packing into it.';
    }
    if (lower.contains('item to pack was not found') ||
        lower.contains('sgtin not found')) {
      return 'One or more items to pack were not found. Check each barcode and confirm the serial has been commissioned.';
    }
    if (lower.contains('parent container format is not valid') ||
        lower.contains('invalid parent container id format') ||
        lower.contains('must be a valid sscc or sgtin')) {
      return 'The parent container format is not valid. Scan an 18-digit SSCC or a case/bundle SGTIN (GTIN + serial).';
    }
    if (lower.contains('parent container cannot receive items') ||
        (lower.contains('parent') && lower.contains('status is'))) {
      return text;
    }
    if (lower.contains('cannot be packed') && lower.contains('status is')) {
      return text;
    }
    if (lower.contains('already packed into another container') ||
        lower.contains('already aggregated')) {
      return 'One or more items are already packed into another container. Unpack them first, then try again.';
    }
    if (lower.contains('cannot be packed into itself') ||
        lower.contains('own parent')) {
      return 'An item cannot be packed into itself. Choose a different parent container.';
    }
    if (lower.contains('not commissioned')) {
      if (lower.contains('parent')) {
        return 'The parent container has not been commissioned yet. Commission it before packing items into it.';
      }
      return 'One or more items have not been commissioned. Commission the product serials before packing.';
    }
    if (lower.contains('read-point gln is required for commissioning') ||
        lower.contains('xsc-008')) {
      return 'Packing into a newly allocated SSCC requires a packing location with an active GLN '
          '(used as the commissioning read point). Select a packing location, then try again.';
    }
    if (lower.contains('custody') || lower.contains('held by')) {
      return text;
    }
    if (lower.contains('packing location') && lower.contains('not active')) {
      return 'The selected packing location is not active. Ask your administrator to activate this site in master data.';
    }
    if (lower.contains('packing location') && lower.contains('not registered')) {
      return 'The selected packing location is not registered. Ask your administrator to add this GLN to master data.';
    }
    if (lower.contains('invalid packing location gln') ||
        (lower.contains('packing location') && lower.contains('13-digit'))) {
      return 'Select a valid packing location (13-digit GLN) from the list.';
    }
    if (lower.contains('add at least one item') ||
        lower.contains('at least one child epc')) {
      return 'Add at least one item to pack. Scan the GTIN + serial barcode on each product.';
    }
    if (lower.contains('parent container') && lower.contains('required')) {
      return 'Scan or enter the parent container — an SSCC (carton/pallet) or a case-level SGTIN serial.';
    }
    if (lower.contains('packing could not be submitted') ||
        lower.contains('packing validation failed')) {
      return text;
    }
    if (lower.contains('network error')) {
      return 'Could not reach the server. Check your connection and try again.';
    }
    if (lower.contains('unexpected error') || lower.contains('server error occurred')) {
      return text;
    }

    return text;
  }

  static String unexpected(Object error) =>
      OperationApiErrorMessage.unexpected('packing', error);
}
