import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/backend_error_parser.dart';


abstract final class OperationApiErrorMessage {
  static bool isStructuredErrorBody(Map<String, dynamic> json) =>
      BackendErrorParser.isStructuredErrorBody(json);

  static String? fromJsonMap(Map<String, dynamic> json) =>
      BackendErrorParser.parseMap(json).displayMessage;

  static String fromApiException(ApiException exception) {
    final fromBody = BackendErrorParser.parse(exception.responseBody).displayMessage;
    if (fromBody != null && fromBody.isNotEmpty) {
      return fromBody;
    }

    if (exception.validationMessages.isNotEmpty) {
      return exception.validationMessages.join('\n');
    }

    final fallback = BackendErrorParser.cleanLine(exception.message);
    if (fallback != null &&
        !BackendErrorParser.isGenericFallbackMessage(fallback) &&
        exception.statusCode != 500) {
      return fallback;
    }

    return exception.getUserFriendlyMessage();
  }

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

  static String unexpected(String operationName, Object error) =>
      'An unexpected error occurred while submitting $operationName: $error';

  static String? cleanLine(String? raw) => BackendErrorParser.cleanLine(raw);
}
