import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/core/utils/epc_uri_validators.dart' as epc_validators;

abstract final class Gs1Parser {
  static Map<String, dynamic> parseBarcode(String rawBarcode) {
    return GS1BarcodeParser.parseGS1Barcode(rawBarcode);
  }

  static Map<String, String>? parseAiString(String input) {
    return GS1BarcodeParser.parseAIString(input);
  }

  static String? parseDigitalLinkToEpc(String input) {
    if (!input.startsWith('https://id.gs1.org/')) return null;
    return EPCURIConverter.convertToEPCUri(input);
  }

  static String? parseEpcUriType(String input) {
    return epc_validators.epcUriType(input);
  }
}
