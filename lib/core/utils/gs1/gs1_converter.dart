import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';

abstract final class Gs1Converter {
  static String? barcodeToEpc(String barcode) {
    return EPCURIConverter.convertToEPCUri(barcode);
  }

  static Map<String, List<String>> barcodeBatchToEpc(List<String> values) {
    return EPCURIConverter.convertBatchToEPCUri(values);
  }

  static String? gtinSerialToEpc(
    String gtin,
    String serialNumber, {
    int? gcpLength,
  }) {
    return EPCURIConverter.convertGTINSerialToEPCUri(
      gtin,
      serialNumber,
      gcpLength: gcpLength,
    );
  }

  static String? gtinToClassEpc(String gtin, {int? gcpLength}) {
    return EPCURIConverter.convertGTINToClassEPCUri(
      gtin,
      gcpLength: gcpLength,
    );
  }

  static String? gtinLotToLgtinEpc(
    String gtin,
    String lotNumber, {
    int? gcpLength,
  }) {
    return EPCURIConverter.convertGTINLotToLGTINEpcUri(
      gtin,
      lotNumber,
      gcpLength: gcpLength,
    );
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

  static String? epcType(String epcUri) {
    return EPCURIConverter.getEPCType(epcUri);
  }
}
