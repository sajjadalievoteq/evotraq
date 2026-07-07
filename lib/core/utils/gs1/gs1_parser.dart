import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/core/utils/epc_uri_validators.dart' as epc_validators;

/// Unified GS1 parsing facade.
///
/// This class intentionally delegates to existing mature parsers to preserve
/// compatibility and output behavior.
abstract final class Gs1Parser {
  /// Delegates to `GS1BarcodeParser.parseGS1Barcode`.
  static Map<String, dynamic> parseBarcode(String rawBarcode) {
    return GS1BarcodeParser.parseGS1Barcode(rawBarcode);
  }

  /// Delegates to `GS1BarcodeParser.parseAIString`.
  static Map<String, String>? parseAiString(String input) {
    return GS1BarcodeParser.parseAIString(input);
  }

  /// Parses GS1 Digital Link by converting to EPC URI through the existing
  /// converter behavior.
  static String? parseDigitalLinkToEpc(String input) {
    if (!input.startsWith('https://id.gs1.org/')) return null;
    return EPCURIConverter.convertToEPCUri(input);
  }

  /// Returns EPC URI type label for known EPC URIs.
  static String? parseEpcUriType(String input) {
    return epc_validators.epcUriType(input);
  }
}
