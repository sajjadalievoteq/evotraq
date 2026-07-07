import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';

/// Unified GS1 conversion facade.
///
/// Delegates to `EPCURIConverter` to preserve exact conversion outputs.
abstract final class Gs1Converter {
  static String? barcodeToEpc(String barcode) {
    return EPCURIConverter.convertToEPCUri(barcode);
  }

  static Map<String, List<String>> barcodeBatchToEpc(List<String> values) {
    return EPCURIConverter.convertBatchToEPCUri(values);
  }

  static String? gtinSerialToEpc(String gtin, String serialNumber) {
    return EPCURIConverter.convertGTINSerialToEPCUri(gtin, serialNumber);
  }

  static String? gtinToClassEpc(String gtin) {
    return EPCURIConverter.convertGTINToClassEPCUri(gtin);
  }

  static String? gtinLotToLgtinEpc(String gtin, String lotNumber) {
    return EPCURIConverter.convertGTINLotToLGTINEpcUri(gtin, lotNumber);
  }

  static String? ssccToEpc(String sscc) {
    return EPCURIConverter.convertSSCCToEPCUri(sscc);
  }

  static String? glnToEpc(String gln, {String extension = '0'}) {
    return EPCURIConverter.convertGLNToEPCUri(gln, extension: extension);
  }

  static String? epcToGTIN(String epcUri) {
    return EPCURIConverter.extractGTINFromEPCUri(epcUri);
  }

  static String? epcToSerial(String epcUri) {
    return EPCURIConverter.extractSerialFromEPCUri(epcUri);
  }
}
