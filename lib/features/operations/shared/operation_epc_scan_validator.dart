import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_validator.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';

enum OperationScanItemType { sscc, sgtin, gtin, invalid, unknown }

const String kSerializedEpcRequiredMessage =
    'Only serialised items (SGTIN or SSCC) are valid. '
    'Lot-based GTINs cannot be used for this operation.';

bool isRejectedOperationScanType(OperationScanItemType type) =>
    type == OperationScanItemType.unknown ||
    type == OperationScanItemType.gtin ||
    type == OperationScanItemType.invalid;

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

class OperationEpcScanValidator {
  OperationEpcScanValidator(this._validationService);

  final ReferenceDataValidationService _validationService;

  static OperationEpcScanOutcome? checkDuplicate(
    String rawBarcode,
    Iterable<String> alreadyScanned,
  ) {
    final already = alreadyScanned.any(
      (existing) => Gs1CanonicalIdentifier.areEquivalent(existing, rawBarcode),
    );
    if (already) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: rawBarcode,
        errorMessage: 'Item already scanned: $rawBarcode',
      );
    }
    return null;
  }

  static OperationScanItemType resolveEpcType(String epc) {
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

  OperationEpcScanOutcome parseForOperation(String rawBarcode) {
    if (Gs1CanonicalIdentifier.isLotOrClassLevel(rawBarcode)) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: rawBarcode,
        errorMessage: kSerializedEpcRequiredMessage,
      );
    }

    // Prefer facade extractors for Digital Link / URN instance identities.
    if (Gs1CanonicalIdentifier.isSgtin(rawBarcode)) {
      final serial = _cleanIdentifier(
        Gs1CanonicalIdentifier.extractSerial(rawBarcode),
      );
      if (serial == null || serial.isEmpty) {
        return OperationEpcScanOutcome.failure(
          rawBarcode: rawBarcode,
          errorMessage: 'SGTIN is missing a serial number',
        );
      }
      final gtin = Gs1CanonicalIdentifier.extractGtin(rawBarcode);
      return OperationEpcScanOutcome.success(
        rawBarcode: rawBarcode,
        epcType: OperationScanItemType.sgtin,
        identifierToValidate: serial,
        details: gtin == null
            ? null
            : BarcodeDetails(
                type: Gs1BarcodeType.sgtin,
                rawBarcode: rawBarcode,
                gs1ElementString: rawBarcode,
                isValid: true,
                gtin: gtin,
                serial: serial,
                allFields: {
                  '01': gtin,
                  '21': serial,
                },
              ),
      );
    }

    if (Gs1CanonicalIdentifier.isSscc(rawBarcode)) {
      final sscc =
          Gs1CanonicalIdentifier.extractSscc18(rawBarcode) ?? rawBarcode;
      return OperationEpcScanOutcome.success(
        rawBarcode: rawBarcode,
        epcType: OperationScanItemType.sscc,
        identifierToValidate: sscc,
      );
    }

    final details = extractBarcodeDetails(rawBarcode);
    final parsedBarcode = Gs1Parser.parseBarcode(rawBarcode);

    OperationScanItemType epcType = OperationScanItemType.unknown;
    String? identifierToValidate;

    if (parsedBarcode['valid'] == true) {
      if (parsedBarcode['SSCC'] != null) {
        epcType = OperationScanItemType.sscc;
        identifierToValidate = _cleanIdentifier(parsedBarcode['SSCC'] as String?);
      } else if (parsedBarcode['GTIN'] != null &&
          parsedBarcode['SERIAL'] != null) {
        epcType = OperationScanItemType.sgtin;
        identifierToValidate = _cleanIdentifier(parsedBarcode['SERIAL'] as String?);
      } else if (parsedBarcode['GTIN'] != null &&
          parsedBarcode['LOT'] != null) {
        return OperationEpcScanOutcome.failure(
          rawBarcode: rawBarcode,
          errorMessage: kSerializedEpcRequiredMessage,
        );
      } else if (parsedBarcode['GTIN'] != null) {
        return OperationEpcScanOutcome.failure(
          rawBarcode: rawBarcode,
          errorMessage: 'Barcode missing serial number: $rawBarcode\n\n'
              'For operations, a complete SGTIN with serial number is required.',
        );
      }
    }

    if (epcType == OperationScanItemType.unknown &&
        Gs1Validator.isValidSSCC(rawBarcode)) {
      epcType = OperationScanItemType.sscc;
      identifierToValidate = rawBarcode;
    }

    if (epcType == OperationScanItemType.unknown ||
        identifierToValidate == null ||
        identifierToValidate.isEmpty) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: rawBarcode,
        errorMessage: 'Invalid barcode format: $rawBarcode\n\n'
            'Supported formats:\n'
            '- GS1 element string: (01)GTIN(21)SERIAL(17)EXPIRY(10)BATCH\n'
            '- GS1 Digital Link: https://id.gs1.org/01/…/21/…\n'
            '- SSCC: 18 digits\n'
            '- SGTIN / SSCC URIs',
      );
    }

    return OperationEpcScanOutcome.success(
      rawBarcode: rawBarcode,
      epcType: epcType,
      identifierToValidate: identifierToValidate,
      details: details,
    );
  }

  static String? _cleanIdentifier(String? value) {
    if (value == null) return null;
    final cleaned = value.trim().replaceFirst(RegExp(r'^/+'), '');
    return cleaned.isEmpty ? null : cleaned;
  }

  Future<OperationEpcScanOutcome> validateAndAdd(
    String rawBarcode, {
    required Iterable<String> alreadyScanned,
    required String operationLabel,
    bool allowGtin = false,
  }) async {
    final prepared = _prepareScan(
      rawBarcode,
      alreadyScanned: alreadyScanned,
    );
    if (prepared.outcome != null) return prepared.outcome!;

    final EPCValidationResult validationResult;
    try {
      validationResult = await _validateExists(
        prepared.epcType!,
        prepared.identifier!,
      );
    } catch (e) {
      return OperationEpcScanOutcome.failure(
        rawBarcode: prepared.canonical,
        errorMessage: 'Validation failed for ${prepared.canonical}: $e',
      );
    }

    return _outcomeFromValidation(
      prepared: prepared,
      validationResult: validationResult,
      operationLabel: operationLabel,
    );
  }

  /// Same as [validateAndAdd], but loads EPC status in parallel with existence
  /// validation so successful scans wait for one round-trip instead of two.
  Future<({OperationEpcScanOutcome outcome, T? status})>
      validateAndAddWithStatus<T>(
    String rawBarcode, {
    required Iterable<String> alreadyScanned,
    required String operationLabel,
    required Future<T?> Function(String epc) loadStatus,
    bool allowGtin = false,
  }) async {
    final prepared = _prepareScan(
      rawBarcode,
      alreadyScanned: alreadyScanned,
    );
    if (prepared.outcome != null) {
      return (outcome: prepared.outcome!, status: null);
    }

    late final EPCValidationResult validationResult;
    late final T? status;
    try {
      final results = await Future.wait<Object?>([
        _validateExists(prepared.epcType!, prepared.identifier!),
        () async {
          try {
            return await loadStatus(prepared.canonical);
          } catch (_) {
            return null;
          }
        }(),
      ]);
      validationResult = results[0] as EPCValidationResult;
      status = results[1] as T?;
    } catch (e) {
      return (
        outcome: OperationEpcScanOutcome.failure(
          rawBarcode: prepared.canonical,
          errorMessage: 'Validation failed for ${prepared.canonical}: $e',
        ),
        status: null,
      );
    }

    return (
      outcome: _outcomeFromValidation(
        prepared: prepared,
        validationResult: validationResult,
        operationLabel: operationLabel,
      ),
      status: status,
    );
  }

  _PreparedScan _prepareScan(
    String rawBarcode, {
    required Iterable<String> alreadyScanned,
  }) {
    final canonical =
        Gs1Converter.barcodeToEpc(rawBarcode.trim()) ?? rawBarcode.trim();

    final duplicate = checkDuplicate(canonical, alreadyScanned);
    if (duplicate != null) {
      return _PreparedScan(canonical: canonical, outcome: duplicate);
    }

    final parsed = parseForOperation(canonical);
    if (!parsed.success) {
      return _PreparedScan(canonical: canonical, outcome: parsed);
    }

    final epcType = parsed.epcType!;
    final identifier = parsed.identifierToValidate!;

    if (epcType == OperationScanItemType.unknown ||
        epcType == OperationScanItemType.invalid ||
        epcType == OperationScanItemType.gtin) {
      return _PreparedScan(
        canonical: canonical,
        outcome: OperationEpcScanOutcome.failure(
          rawBarcode: canonical,
          errorMessage: kSerializedEpcRequiredMessage,
        ),
      );
    }

    return _PreparedScan(
      canonical: canonical,
      epcType: epcType,
      identifier: identifier,
      details: parsed.details,
    );
  }

  Future<EPCValidationResult> _validateExists(
    OperationScanItemType epcType,
    String identifier,
  ) {
    if (epcType == OperationScanItemType.sscc) {
      return _validationService.validateSSCC(identifier);
    }
    return _validationService.validateSGTIN(identifier);
  }

  OperationEpcScanOutcome _outcomeFromValidation({
    required _PreparedScan prepared,
    required EPCValidationResult validationResult,
    required String operationLabel,
  }) {
    final epcType = prepared.epcType!;
    final identifier = prepared.identifier!;
    final canonical = prepared.canonical;

    if (validationResult.exists) {
      return OperationEpcScanOutcome.success(
        rawBarcode: canonical,
        epcType: epcType,
        identifierToValidate: identifier,
        details: prepared.details,
      );
    }

    final typeLabel = OperationEpcTypeUtils.label(epcType);

    var errorMessage = '$typeLabel not found in system';
    if (epcType == OperationScanItemType.sgtin) {
      errorMessage += '\nSerial number: $identifier';
      final gtin = prepared.details?.gtin;
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

class _PreparedScan {
  const _PreparedScan({
    required this.canonical,
    this.outcome,
    this.epcType,
    this.identifier,
    this.details,
  });

  final String canonical;
  final OperationEpcScanOutcome? outcome;
  final OperationScanItemType? epcType;
  final String? identifier;
  final BarcodeDetails? details;
}
