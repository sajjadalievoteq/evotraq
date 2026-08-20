import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_validator.dart';

enum OperationScanItemType { sscc, sgtin, gtin, invalid, unknown }

bool isRejectedOperationScanType(OperationScanItemType type) =>
    type == OperationScanItemType.unknown ||
    type == OperationScanItemType.gtin ||
    type == OperationScanItemType.invalid;

OperationScanItemType resolveOperationEpcType(String epc) {
  if (Gs1CanonicalIdentifier.isSgtin(epc)) {
    return OperationScanItemType.sgtin;
  }
  if (Gs1CanonicalIdentifier.isSscc(epc)) {
    return OperationScanItemType.sscc;
  }
  if (Gs1CanonicalIdentifier.isLotOrClassLevel(epc)) {
    return OperationScanItemType.invalid;
  }
  final parsedBarcode = Gs1Parser.parseBarcode(epc);
  if (parsedBarcode['SSCC'] != null || Gs1Validator.isValidSSCC(epc)) {
    return OperationScanItemType.sscc;
  }
  if (parsedBarcode['GTIN'] != null && parsedBarcode['SERIAL'] != null) {
    return OperationScanItemType.sgtin;
  }
  if (parsedBarcode['GTIN'] != null &&
      parsedBarcode['LOT'] != null &&
      parsedBarcode['SERIAL'] == null) {
    return OperationScanItemType.invalid;
  }
  return OperationScanItemType.unknown;
}
