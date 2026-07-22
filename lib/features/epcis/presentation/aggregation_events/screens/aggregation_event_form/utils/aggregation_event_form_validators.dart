import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;

class AggregationEventFormValidators {
  AggregationEventFormValidators._();

  static final RegExp _urnEpc = RegExp(r'^urn:epc:', caseSensitive: false);
  static final RegExp _gs1ElementString = RegExp(r'\(\d{2}\)');
  static final RegExp _digitalLink =
      RegExp(r'^https://id\.gs1\.org/', caseSensitive: false);
  static final RegExp _ssccUrn = RegExp(
    r'^urn:epc:id:sscc:(\d{6,12})\.(\d{1,17})$',
    caseSensitive: false,
  );
  static final RegExp _ssccElementString = RegExp(r'\(00\)(\d{18})');

  static bool isLikelyEpc(String value) {
    final trimmed = value.trim();
    return _urnEpc.hasMatch(trimmed) ||
        _gs1ElementString.hasMatch(trimmed) ||
        _digitalLink.hasMatch(trimmed);
  }

  static String? validateGtin14(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'GTIN is required' : null;
    }
    return GtinFieldValidators.validateGtinCode(value);
  }

  static String? validateSerialNumber(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Serial number is required' : null;
    }
    return sgtin_validators.validateSerialNumber(value.trim());
  }

  static String? validateSsccInput(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'SSCC is required' : null;
    }
    return _validateSsccContent(value.trim());
  }

  static String? _validateSsccContent(String trimmed) {
    if (Gs1CanonicalIdentifier.isSscc(trimmed)) {
      final extracted = Gs1CanonicalIdentifier.extractSscc18(trimmed);
      if (extracted != null && SsccFormat.isValidSscc(extracted)) return null;
      
      if (_ssccUrn.hasMatch(trimmed)) {
        return _validateSsccEpcUri(trimmed);
      }
      return 'Invalid SSCC Digital Link — could not verify 18-digit SSCC';
    }

    final elementMatch = _ssccElementString.firstMatch(trimmed);
    if (elementMatch != null) {
      final sscc = elementMatch.group(1)!;
      if (!SsccFormat.isValidSscc(sscc)) {
        return 'Invalid SSCC check digit in (00) barcode';
      }
      return null;
    }

    if (_gs1ElementString.hasMatch(trimmed)) {
      final parsed = Gs1Parser.parseBarcode(trimmed);
      if (parsed['SSCC'] != null) {
        final sscc = parsed['SSCC'].toString();
        if (SsccFormat.isValidSscc(sscc)) return null;
        return 'Invalid SSCC check digit';
      }
      return 'GS1 barcode must include (00) with an 18-digit SSCC';
    }

    final digits = SsccFormat.stripSsccInput(trimmed);
    if (digits.length == 18) {
      if (!SsccFormat.isValidSscc(digits)) {
        return 'Invalid SSCC check digit';
      }
      return null;
    }

    return 'Enter a valid 18-digit SSCC (with check digit), (00)… barcode, '
        'https://id.gs1.org/00/…, or urn:epc:id:sscc:…';
  }

  static String? _validateSsccEpcUri(String uri) {
    final match = _ssccUrn.firstMatch(uri);
    if (match == null) {
      return 'Invalid SSCC EPC URI — expected urn:epc:id:sscc:<prefix>.<serial>';
    }
    final prefix = match.group(1)!;
    final serial = match.group(2)!;
    if (prefix.length < 6 || prefix.length > 12) {
      return 'SSCC company prefix must be 6–12 digits';
    }
    if (serial.isEmpty || serial.length > 17) {
      return 'SSCC serial reference is invalid';
    }
    return null;
  }

  static String? validateSgtinEpcUri(String? uri) {
    if (uri == null || uri.isEmpty) {
      return 'Could not build a valid SGTIN EPC URI';
    }
    return sgtin_validators.validateEpcUri(uri);
  }

  static String? validateSsccEpcUri(String? uri) {
    if (uri == null || uri.isEmpty) {
      return 'Could not build a valid SSCC EPC URI';
    }
    if (Gs1CanonicalIdentifier.isSscc(uri)) {
      return _validateSsccContent(uri);
    }
    return _validateSsccEpcUri(uri);
  }

  static String? validateChildEpcEntry(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Empty EPC value';

    if (Gs1CanonicalIdentifier.isLgtin(trimmed)) {
      return _validateLgtinUri(trimmed);
    }

    if (Gs1CanonicalIdentifier.isClassGtin(trimmed)) {
      final gtin = Gs1CanonicalIdentifier.extractGtin(trimmed);
      if (gtin != null) {
        return GtinFieldValidators.validateGtinCode(gtin);
      }
      return _validateLgtinUri(
        trimmed.replaceFirst('idpat:sgtin:', 'class:lgtin:'),
      );
    }

    if (Gs1CanonicalIdentifier.isSgtin(trimmed)) {
      return sgtin_validators.validateEpcUri(trimmed);
    }

    if (Gs1CanonicalIdentifier.isSscc(trimmed)) {
      return _validateSsccEpcUri(trimmed);
    }

    if (_digitalLink.hasMatch(trimmed)) {
      final dlError = sgtin_validators.validateGs1DigitalLinkUri(trimmed);
      if (dlError == null) return null;
      if (Gs1CanonicalIdentifier.isSscc(trimmed) || trimmed.contains('/00/')) {
        return _validateSsccContent(trimmed);
      }
      return dlError;
    }

    if (_gs1ElementString.hasMatch(trimmed)) {
      return _validateSgtinElementString(trimmed);
    }

    final ssccDigits = SsccFormat.stripSsccInput(trimmed);
    if (ssccDigits.length == 18 && SsccFormat.isValidSscc(ssccDigits)) {
      return null;
    }

    return 'Invalid child EPC — use SGTIN, SSCC, or GTIN (lot-based) EPC URI, GS1 barcode, or Digital Link';
  }

  static String? _validateLgtinUri(String uri) {
    if (!Gs1CanonicalIdentifier.isLgtin(uri) &&
        !Gs1CanonicalIdentifier.isLotOrClassLevel(uri)) {
      return 'Invalid LGTIN URI';
    }
    final gtin = Gs1CanonicalIdentifier.extractGtin(uri);
    if (gtin == null) {
      return 'LGTIN URI must include company prefix, item reference, and lot';
    }
    final gtinError = GtinFieldValidators.validateGtinCode(gtin);
    if (gtinError != null) return gtinError;
    return null;
  }

  static String? _validateSgtinElementString(String trimmed) {
    final parsed = Gs1Parser.parseBarcode(trimmed);
    if (parsed['valid'] != true) {
      return 'Invalid GS1 element string';
    }
    final gtin = parsed['GTIN']?.toString();
    final serial = parsed['SERIAL']?.toString();
    final lot = parsed['BATCH'] ?? parsed['LOT']?.toString();
    if (gtin == null) {
      return 'Child barcode must include (01) GTIN';
    }
    if (serial != null) {
      final gtinError = GtinFieldValidators.validateGtinCode(gtin);
      if (gtinError != null) return gtinError;
      final serialError = sgtin_validators.validateSerialNumber(serial);
      if (serialError != null) return serialError;
      return null;
    }
    if (lot != null) {
      final gtinError = GtinFieldValidators.validateGtinCode(gtin);
      if (gtinError != null) return gtinError;
      if (lot.trim().isEmpty) return 'Lot number must not be empty';
      return null;
    }
    return 'Child barcode must include (21) serial or (10) lot';
  }

  static String? validateParentEpc(String? value, String action) {
    final requiresParent = action != 'OBSERVE';
    if (requiresParent && (value == null || value.trim().isEmpty)) {
      return 'Please enter the parent EPC';
    }
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validateResolvedParentEpc(value.trim());
  }

  static String? validateResolvedParentEpc(String uri) {
    if (Gs1CanonicalIdentifier.isSgtin(uri)) {
      return validateSgtinEpcUri(uri);
    }
    if (Gs1CanonicalIdentifier.isSscc(uri)) {
      return validateSsccEpcUri(uri);
    }
    if (isLikelyEpc(uri)) {
      if (_gs1ElementString.hasMatch(uri)) {
        if (uri.contains('(00)')) return _validateSsccContent(uri);
        return _validateSgtinElementString(uri);
      }
      return null;
    }
    return 'Parent EPC must be a valid GS1 Digital Link, EPC URI, or barcode';
  }

  static String? validateChildEpcList(String? value, String action) {
    if (action == 'DELETE') {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return 'Please enter at least one child EPC';
    }
    final epcList = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (epcList.isEmpty) {
      return 'Please enter at least one child EPC';
    }
    for (final epc in epcList) {
      final error = validateChildEpcEntry(epc);
      if (error != null) {
        return '$error: $epc';
      }
    }
    return null;
  }

  static String? validateEpcClass(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'EPC class is required';
    }
    final trimmed = value.trim();
    if (Gs1CanonicalIdentifier.isClassGtin(trimmed) ||
        Gs1CanonicalIdentifier.isLotOrClassLevel(trimmed) ||
        isLikelyEpc(trimmed)) {
      return null;
    }
    return 'EPC class must be urn:epc:idpat:… or a valid GS1 URI';
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Quantity must be a positive number';
    }
    return null;
  }

  static String parseGlnToCode(String input) =>
      EpcisGlnValidators.parseGlnToCode(input);

  static String? validateLocationGln(String? value) =>
      EpcisGlnValidators.validateLocationGln(value);
}
