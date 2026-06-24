import 'package:traqtrace_app/core/utils/gs1_validator.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

enum OperationScanItemType { sscc, sgtin, unknown }

class OperationEpcScanOutcome {
  const OperationEpcScanOutcome._({
    required this.success,
    required this.rawBarcode,
    this.errorMessage,
    this.epcType,
    this.identifierToValidate,
    this.details,
  });

  factory OperationEpcScanOutcome.success({
    required String rawBarcode,
    required OperationScanItemType epcType,
    required String identifierToValidate,
    BarcodeDetails? details,
  }) =>
      OperationEpcScanOutcome._(
        success: true,
        rawBarcode: rawBarcode,
        epcType: epcType,
        identifierToValidate: identifierToValidate,
        details: details,
      );

  factory OperationEpcScanOutcome.failure({
    required String rawBarcode,
    required String errorMessage,
  }) =>
      OperationEpcScanOutcome._(
        success: false,
        rawBarcode: rawBarcode,
        errorMessage: errorMessage,
      );

  final bool success;
  final String rawBarcode;
  final String? errorMessage;
  final OperationScanItemType? epcType;
  final String? identifierToValidate;
  final BarcodeDetails? details;
}

/// Shared scan validation for shipping, receiving, packing, and related flows.
class OperationEpcScanValidator {
  OperationEpcScanValidator(this._validationService);

  final ReferenceDataValidationService _validationService;

  static OperationEpcScanOutcome? checkDuplicate(
    String rawBarcode,
    Iterable<String> alreadyScanned,
  ) {
    if (alreadyScanned.contains(rawBarcode)) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: rawBarcode,
        errorMessage: 'Item already scanned: $rawBarcode',
      );
    }
    return null;
  }

  static OperationScanItemType resolveEpcType(String epc) {
    final parsedBarcode = GS1BarcodeParser.parseGS1Barcode(epc);
    if (parsedBarcode['SSCC'] != null ||
        GS1Validator.isValidSSCC(epc)) {
      return OperationScanItemType.sscc;
    }
    if (parsedBarcode['GTIN'] != null && parsedBarcode['SERIAL'] != null) {
      return OperationScanItemType.sgtin;
    }
    return OperationScanItemType.unknown;
  }

  OperationEpcScanOutcome parseForOperation(String rawBarcode) {
    final details = extractBarcodeDetails(rawBarcode);
    final parsedBarcode = GS1BarcodeParser.parseGS1Barcode(rawBarcode);

    OperationScanItemType epcType = OperationScanItemType.unknown;
    String? identifierToValidate;

    if (parsedBarcode['valid'] == true) {
      if (parsedBarcode['SSCC'] != null) {
        epcType = OperationScanItemType.sscc;
        identifierToValidate = parsedBarcode['SSCC'] as String?;
      } else if (parsedBarcode['GTIN'] != null &&
          parsedBarcode['SERIAL'] != null) {
        epcType = OperationScanItemType.sgtin;
        identifierToValidate = parsedBarcode['SERIAL'] as String?;
      } else if (parsedBarcode['GTIN'] != null) {
        return OperationEpcScanOutcome.failure(
          rawBarcode: rawBarcode,
          errorMessage:
              'Barcode missing serial number: $rawBarcode\n\nFor operations, a complete SGTIN with serial number is required.',
        );
      }
    }

    if (epcType == OperationScanItemType.unknown &&
        GS1Validator.isValidSSCC(rawBarcode)) {
      epcType = OperationScanItemType.sscc;
      identifierToValidate = rawBarcode;
    }

    if (epcType == OperationScanItemType.unknown ||
        identifierToValidate == null) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: rawBarcode,
        errorMessage:
            'Invalid barcode format: $rawBarcode\n\nSupported formats:\n- GS1 element string: (01)GTIN(21)SERIAL(17)EXPIRY(10)BATCH\n- SSCC: 18 digits\n- SGTIN URI: urn:epc:id:sgtin:...',
      );
    }

    return OperationEpcScanOutcome.success(
      rawBarcode: rawBarcode,
      epcType: epcType,
      identifierToValidate: identifierToValidate,
      details: details,
    );
  }

  Future<OperationEpcScanOutcome> validateAndAdd(
    String rawBarcode, {
    required Iterable<String> alreadyScanned,
    required String operationLabel,
  }) async {
    final duplicate = checkDuplicate(rawBarcode, alreadyScanned);
    if (duplicate != null) return duplicate;

    final parsed = parseForOperation(rawBarcode);
    if (!parsed.success) return parsed;

    final epcType = parsed.epcType!;
    final identifier = parsed.identifierToValidate!;

    final EPCValidationResult validationResult;
    if (epcType == OperationScanItemType.sscc) {
      validationResult = await _validationService.validateSSCC(identifier);
    } else {
      validationResult = await _validationService.validateSGTIN(identifier);
    }

    if (validationResult.exists) {
      return OperationEpcScanOutcome.success(
        rawBarcode: rawBarcode,
        epcType: epcType,
        identifierToValidate: identifier,
        details: parsed.details,
      );
    }

    final typeLabel = epcType == OperationScanItemType.sscc ? 'SSCC' : 'SGTIN';
    var errorMessage = '$typeLabel not found in system';
    if (epcType == OperationScanItemType.sgtin) {
      errorMessage += '\nSerial Number: $identifier';
      final gtin = parsed.details?.gtin;
      if (gtin != null) {
        errorMessage += '\nGTIN: $gtin';
      }
    } else {
      errorMessage += ': $identifier';
    }
    if (validationResult.errors.isNotEmpty) {
      errorMessage += '\n\nDetails: ${validationResult.errors.join(', ')}';
    }
    errorMessage +=
        '\n\nPlease ensure the $typeLabel is properly registered in the system before $operationLabel.';

    return OperationEpcScanOutcome.failure(
      rawBarcode: rawBarcode,
      errorMessage: errorMessage,
    );
  }
}
