import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/core/utils/gs1_validator.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

enum OperationScanItemType { sscc, sgtin, gtin, unknown }

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
    if (epc.startsWith('urn:epc:id:sgtin:')) return OperationScanItemType.sgtin;
    if (epc.startsWith('urn:epc:id:sscc:')) return OperationScanItemType.sscc;
    if (epc.startsWith('urn:epc:class:lgtin:')) return OperationScanItemType.gtin;
    if (epc.startsWith('urn:epc:idpat:sgtin:')) return OperationScanItemType.gtin;
    final parsedBarcode = GS1BarcodeParser.parseGS1Barcode(epc);
    if (parsedBarcode['SSCC'] != null || GS1Validator.isValidSSCC(epc)) {
      return OperationScanItemType.sscc;
    }
    if (parsedBarcode['GTIN'] != null && parsedBarcode['SERIAL'] != null) {
      return OperationScanItemType.sgtin;
    }
    if (parsedBarcode['GTIN'] != null &&
        parsedBarcode['LOT'] != null &&
        parsedBarcode['SERIAL'] == null) {
      return OperationScanItemType.gtin;
    }
    return OperationScanItemType.unknown;
  }

  OperationEpcScanOutcome parseForOperation(String rawBarcode) {
    if (rawBarcode.startsWith('urn:epc:class:lgtin:')) {
      final tail = rawBarcode.substring('urn:epc:class:lgtin:'.length);
      final parts = tail.split('.');
      if (parts.length == 3) {
        return OperationEpcScanOutcome.success(
          rawBarcode: rawBarcode,
          epcType: OperationScanItemType.gtin,
          identifierToValidate: parts[0] + parts[1],
        );
      }
      return OperationEpcScanOutcome.failure(
        rawBarcode: rawBarcode,
        errorMessage: 'Malformed LGTIN URI — expected '
            'urn:epc:class:lgtin:<companyPrefix>.<itemRef>.<lot>\n\n'
            'Got: $rawBarcode',
      );
    }

    if (rawBarcode.startsWith('urn:epc:idpat:sgtin:')) {
      final tail = rawBarcode.substring('urn:epc:idpat:sgtin:'.length);
      final parts = tail.split('.');
      if (parts.length >= 2) {
        return OperationEpcScanOutcome.success(
          rawBarcode: rawBarcode,
          epcType: OperationScanItemType.gtin,
          identifierToValidate: parts[0] + parts[1],
        );
      }
    }

    if (rawBarcode.startsWith('urn:epc:id:sgtin:')) {
      final tail = rawBarcode.substring('urn:epc:id:sgtin:'.length);
      final parts = tail.split('.');
      if (parts.length == 3 &&
          parts[0].isNotEmpty &&
          parts[1].isNotEmpty &&
          parts[2].isNotEmpty) {
        return OperationEpcScanOutcome.success(
          rawBarcode: rawBarcode,
          epcType: OperationScanItemType.sgtin,
          identifierToValidate: parts[2],
        );
      }
      return OperationEpcScanOutcome.failure(
        rawBarcode: rawBarcode,
        errorMessage: 'Malformed SGTIN URI — expected '
            'urn:epc:id:sgtin:<companyPrefix>.<itemRef>.<serial>\n\n'
            'Got: $rawBarcode',
      );
    }

    if (rawBarcode.startsWith('urn:epc:id:sscc:')) {
      final tail = rawBarcode.substring('urn:epc:id:sscc:'.length);
      final parts = tail.split('.');
      if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return OperationEpcScanOutcome.success(
          rawBarcode: rawBarcode,
          epcType: OperationScanItemType.sscc,
          identifierToValidate: parts[1],
        );
      }
      return OperationEpcScanOutcome.failure(
        rawBarcode: rawBarcode,
        errorMessage: 'Malformed SSCC URI — expected '
            'urn:epc:id:sscc:<companyPrefix>.<serialRef>\n\n'
            'Got: $rawBarcode',
      );
    }

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
      } else if (parsedBarcode['GTIN'] != null &&
          parsedBarcode['LOT'] != null) {
        epcType = OperationScanItemType.gtin;
        identifierToValidate = parsedBarcode['GTIN'] as String?;
      } else if (parsedBarcode['GTIN'] != null) {
        return OperationEpcScanOutcome.failure(
          rawBarcode: rawBarcode,
          errorMessage: 'Barcode missing serial number: $rawBarcode\n\n'
              'For operations, a complete SGTIN with serial number is required.',
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
        errorMessage: 'Invalid barcode format: $rawBarcode\n\n'
            'Supported formats:\n'
            '- GS1 element string: (01)GTIN(21)SERIAL(17)EXPIRY(10)BATCH\n'
            '- Lot-based GTIN: (01)GTIN(10)LOT\n'
            '- SSCC: 18 digits\n'
            '- SGTIN / LGTIN / SSCC URIs',
      );
    }

    return OperationEpcScanOutcome.success(
      rawBarcode: rawBarcode,
      epcType: epcType,
      identifierToValidate: identifierToValidate,
      details: details,
    );
  }

  /// Duplicate-check + parse + backend validation in one call.
  ///
  /// [operationLabel] is shown in error messages, e.g. "shipping" or "receiving".
  /// Set [allowGtin] to true for operations that accept lot-based (LGTIN) scans.
  Future<OperationEpcScanOutcome> validateAndAdd(
    String rawBarcode, {
    required Iterable<String> alreadyScanned,
    required String operationLabel,
    bool allowGtin = false,
  }) async {
    final canonical =
        EPCURIConverter.convertToEPCUri(rawBarcode.trim()) ?? rawBarcode.trim();

    final duplicate = checkDuplicate(canonical, alreadyScanned);
    if (duplicate != null) return duplicate;

    final parsed = parseForOperation(canonical);
    if (!parsed.success) return parsed;

    final epcType = parsed.epcType!;
    final identifier = parsed.identifierToValidate!;

    if (epcType == OperationScanItemType.gtin && !allowGtin) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: canonical,
        errorMessage:
            'Lot-based GTIN scans are not supported for this operation.\n\n'
            'Only SGTIN and SSCC values are allowed.',
      );
    }

    if (epcType == OperationScanItemType.unknown) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: canonical,
        errorMessage:
            'Only SGTIN, SSCC, and GTIN (lot-based) values are allowed.\n\n'
            'Scanned value: $canonical',
      );
    }

    final EPCValidationResult validationResult;
    try {
      if (epcType == OperationScanItemType.sscc) {
        validationResult = await _validationService.validateSSCC(identifier);
      } else if (epcType == OperationScanItemType.gtin) {
        validationResult = await _validationService.validateGTIN(identifier);
      } else {
        validationResult = await _validationService.validateSGTIN(identifier);
      }
    } catch (e) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: canonical,
        errorMessage: 'Validation failed for $canonical: $e',
      );
    }

    if (validationResult.exists) {
      return OperationEpcScanOutcome.success(
        rawBarcode: canonical,
        epcType: epcType,
        identifierToValidate: identifier,
        details: parsed.details,
      );
    }

    final typeLabel = switch (epcType) {
      OperationScanItemType.sscc => 'SSCC',
      OperationScanItemType.gtin => 'GTIN',
      _ => 'SGTIN',
    };

    var errorMessage = '$typeLabel not found in system';
    if (epcType == OperationScanItemType.sgtin) {
      errorMessage += '\nSerial number: $identifier';
      final gtin = parsed.details?.gtin;
      if (gtin != null) errorMessage += '\nGTIN: $gtin';
    } else {
      errorMessage += ': $identifier';
    }
    if (validationResult.errors.isNotEmpty) {
      errorMessage += '\n\nDetails: ${validationResult.errors.join(', ')}';
    }
    errorMessage +=
        '\n\nEnsure the $typeLabel is registered in the system before $operationLabel.';

    return OperationEpcScanOutcome.failure(
      rawBarcode: canonical,
      errorMessage: errorMessage,
    );
  }
}
