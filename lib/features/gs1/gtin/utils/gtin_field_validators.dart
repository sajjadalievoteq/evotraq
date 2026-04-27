import 'gtin_format.dart';

/// All GTIN **input** validation for forms and related UI. Use [validateGtinCode] on the GTIN field.
///
/// Pure functions only: no `BuildContext`, cubits, or side effects.
abstract final class GtinFieldValidators {
  // --- GTIN code (single source of truth for rules) ---

  /// Required GTIN: strip, length 8/12/13/14, GS1 Mod-10. Use as [FormField.validator].
  static String? validateGtinCode(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (s.isEmpty) {
      return 'GTIN Code is required';
    }
    if (!GtinFormat.isValidGtin(s)) {
      if (!RegExp(r'^\d+$').hasMatch(s)) {
        return 'GTIN must contain only digits (spaces and hyphens are ignored)';
      }
      if (!RegExp(r'^(?:\d{8}|\d{12}|\d{13}|\d{14})$').hasMatch(s)) {
        return 'Invalid length. Use 8, 12, 13, or 14 digits (GS1).';
      }
      return 'Invalid check digit. Verify the GTIN or use a GS1 check-digit calculator.';
    }
    return null;
  }

  /// Optional GTIN (e.g. search filters). Empty is valid.
  static String? validateGtinCodeOptional(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (s.isEmpty) return null;
    return validateGtinCode(s);
  }

  /// `true` when [validateGtinCode] passes and the stripped value is non-empty.
  static bool isGtinCodeValid(String? value) => validateGtinCode(value) == null;

  /// 14-digit canonical form. Call only when [validateGtinCode] is already `null`.
  static String canonicalGtin14FromInput(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (!GtinFormat.isValidGtin(s)) {
      throw StateError('canonicalGtin14FromInput: invalid or empty GTIN');
    }
    return GtinFormat.normalizeGtinTo14(s);
  }

  /// Data for the “valid GTIN” chip row. `null` if invalid or empty.
  static GtinCodeChipsData? validGtinChipsData(String? raw) {
    if (!isGtinCodeValid(raw)) return null;
    final s = GtinFormat.stripGtinInput(raw);
    final canon = GtinFormat.normalizeGtinTo14(s);
    final label = GtinFormat.structureLabelForStrippedInput(s);
    final ind = GtinFormat.indicatorFromCanonical14(canon);
    if (label == null || ind == null) return null;
    final check = s.isNotEmpty ? s[s.length - 1] : '';
    return (
      structureLabel: label,
      indicatorDigit: ind,
      canonical14: canon,
      checkDigit: check,
    );
  }

  // --- Other GTIN form fields ---

  /// Validator for the primary GTIN UI "Product Name" field.
  /// Note: the documentation calls this `brand_name` (max 70) — we enforce the same constraints here.
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product Name is required';
    }
    final v = value.trim();
    if (v.length > 70) {
      return 'Product Name must be at most 70 characters';
    }
    // Reject ASCII control characters (doc: reject control characters).
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'Product Name contains invalid control characters';
    }
    return null;
  }

  /// Validator for the primary GTIN UI "Manufacturer" field.
  static String? validateManufacturer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Manufacturer is required';
    }
    // Documentation focuses on manufacturer GLN; this UI field is a human-readable name.
    // Align to the doc's party name guidance (free text, trim, reject control chars, <= 200 chars).
    final v = value.trim();
    if (v.length > 200) {
      return 'Manufacturer must be at most 200 characters';
    }
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'Manufacturer contains invalid control characters';
    }
    return null;
  }

  /// Validator for the primary GTIN UI "Pack Size" field (optional int).
  static String? validatePackSizeOptionalInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = value.trim();
    final n = int.tryParse(v);
    if (n == null) {
      return 'Pack Size must be numeric';
    }
    // Doc: "Numeric" with INTEGER storage; disallow 0/negative.
    if (n <= 0) {
      return 'Pack Size must be greater than 0';
    }
    return null;
  }

  // --- Backwards-compatible aliases (keep until all call sites updated) ---

  static String? productNameRequired(String? value) => validateProductName(value);

  static String? manufacturerRequired(String? value) => validateManufacturer(value);

  static String? packSizeOptionalInt(String? value) =>
      validatePackSizeOptionalInt(value);

  // ---------------------------------------------------------------------------
  // Documentation-named validators (core_gtin_master)
  // ---------------------------------------------------------------------------

  static String? validateBrandName(String? value) {
    // Same rule as Brand Name table: required, max 70, trim, reject control chars.
    if (value == null || value.trim().isEmpty) return 'brand_name is required';
    final v = value.trim();
    if (v.length > 70) return 'brand_name must be at most 70 characters';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'brand_name contains invalid control characters';
    }
    return null;
  }

  static String? validateFunctionalName(String? value, {required bool hasGpcBrickCode}) {
    // Doc: required unless GPC Brick is supplied.
    final v = (value ?? '').trim();
    if (v.isEmpty && !hasGpcBrickCode) {
      return 'functional_name is required when gpc_brick_code is empty';
    }
    if (v.length > 35) return 'functional_name must be at most 35 characters';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'functional_name contains invalid control characters';
    }
    return null;
  }

  static String? validateTradeItemDescription(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 200) return 'trade_item_description must be at most 200 characters';
    return null;
  }

  static String? validateGpcBrickCode(String? value) {
    // Doc: 8 digits always starting '1000' and required.
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'gpc_brick_code is required';
    if (!RegExp(r'^\d{8}$').hasMatch(v)) return 'gpc_brick_code must be exactly 8 digits';
    if (!v.startsWith('1000')) return "gpc_brick_code must start with '1000'";
    return null;
  }

  static String? validateIso3166Numeric3(String? value, {required String fieldName}) {
    // Doc uses CHAR(3) and references ISO 3166-1; treat as numeric-3 for this UI.
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';
    if (!RegExp(r'^\d{3}$').hasMatch(v)) return '$fieldName must be exactly 3 digits';
    return null;
  }

  static String? validateTargetMarketCountry(String? value) =>
      validateIso3166Numeric3(value, fieldName: 'target_market_country');

  static String? validateCountryOfOrigin(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d{3}$').hasMatch(v)) return 'country_of_origin must be exactly 3 digits';
    return null;
  }

  static String? validateNetContentValueRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'net_content_value is required';
    // Doc intent: decimal number (no units), non-zero.
    // Keep parsing strict: digits with optional decimal separator '.'.
    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(v)) {
      return 'net_content_value must be a numeric value (e.g. 10 or 10.5)';
    }
    final n = double.tryParse(v);
    if (n == null) return 'net_content_value must be a numeric value (e.g. 10 or 10.5)';
    if (n <= 0) return 'net_content_value must be > 0';
    return null;
  }

  static String? validateUomCode3Required(String? value, {required String fieldName}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';
    // UN/ECE Rec 20 codes are typically uppercase alphanumeric.
    if (!RegExp(r'^[A-Z0-9]{2,3}$').hasMatch(v)) {
      return '$fieldName must be 2–3 characters';
    }
    return null;
  }

  static String? validateNetContentUomRequired(String? value) =>
      validateUomCode3Required(value, fieldName: 'net_content_uom');

  static String? validateOptionalDecimalNonNegative(String? value, {required String fieldName}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return '$fieldName must be numeric';
    if (n < 0) return '$fieldName must be >= 0';
    return null;
  }

  static String? validateOptionalDecimalPositive(String? value, {required String fieldName}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(v)) {
      return '$fieldName must be a numeric value (e.g. 10 or 10.5)';
    }
    final n = double.tryParse(v);
    if (n == null) return '$fieldName must be a numeric value (e.g. 10 or 10.5)';
    if (n <= 0) return '$fieldName must be > 0';
    return null;
  }

  static String? validateGrossWeightValue(String? value) =>
      validateOptionalDecimalPositive(value, fieldName: 'gross_weight_value');

  static String? validateGrossWeightUom(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return validateUomCode3Required(v, fieldName: 'gross_weight_uom');
  }

  static String? validateHeightValue(String? value) =>
      validateOptionalDecimalPositive(value, fieldName: 'height_value');
  static String? validateWidthValue(String? value) =>
      validateOptionalDecimalPositive(value, fieldName: 'width_value');
  static String? validateDepthValue(String? value) =>
      validateOptionalDecimalPositive(value, fieldName: 'depth_value');

  static String? validateDimUom(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return validateUomCode3Required(v, fieldName: 'dim_uom');
  }

  static String? validateQuantityOfChildren(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'quantity_of_children must be numeric';
    if (n <= 0) return 'quantity_of_children must be > 0';
    return null;
  }

  static String? validateTotalQtyNextLower(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'total_qty_next_lower must be numeric';
    if (n <= 0) return 'total_qty_next_lower must be > 0';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Packaging hierarchy cross-field rules (doc: Section 4.3)
  // ---------------------------------------------------------------------------

  static String? validateQuantityOfChildrenConditional(
    String? value, {
    required bool isBaseUnit,
  }) {
    final v = (value ?? '').trim();
    if (isBaseUnit) {
      if (v.isNotEmpty) {
        return 'quantity_of_children must be empty when is_base_unit is true';
      }
      return null;
    }
    if (v.isEmpty) return 'quantity_of_children is required when is_base_unit is false';
    if (!RegExp(r'^\d{1,6}$').hasMatch(v)) {
      return 'quantity_of_children must be 1–6 digits';
    }
    final n = int.tryParse(v);
    if (n == null) return 'quantity_of_children must be numeric';
    if (n <= 0) return 'quantity_of_children must be > 0';
    return null;
  }

  static String? validateTotalQtyNextLowerConditional(
    String? value, {
    required bool isBaseUnit,
  }) {
    final v = (value ?? '').trim();
    if (isBaseUnit) {
      if (v.isNotEmpty) {
        return 'total_qty_next_lower must be empty when is_base_unit is true';
      }
      return null;
    }
    if (v.isEmpty) return 'total_qty_next_lower is required when is_base_unit is false';
    if (!RegExp(r'^\d{1,6}$').hasMatch(v)) {
      return 'total_qty_next_lower must be 1–6 digits';
    }
    final n = int.tryParse(v);
    if (n == null) return 'total_qty_next_lower must be numeric';
    if (n <= 0) return 'total_qty_next_lower must be > 0';
    return null;
  }

  static String? validateNextLowerLevelGtinConditional(
    String? value, {
    required bool isBaseUnit,
    required String currentGtinRaw,
  }) {
    final v = (value ?? '').trim();
    if (isBaseUnit) {
      if (v.isNotEmpty) {
        return 'next_lower_level_gtin must be empty when is_base_unit is true';
      }
      return null;
    }
    if (v.isEmpty) return 'next_lower_level_gtin is required when is_base_unit is false';
    final gtinErr = validateGtinCodeOptional(v);
    if (gtinErr != null) return gtinErr.replaceFirst('GTIN', 'next_lower_level_gtin');

    // Doc: disallow self-reference in hierarchy.
    final curStripped = GtinFormat.stripGtinInput(currentGtinRaw);
    if (GtinFormat.isValidGtin(curStripped)) {
      final curCanon = GtinFormat.normalizeGtinTo14(curStripped);
      final childCanon = GtinFormat.normalizeGtinTo14(GtinFormat.stripGtinInput(v));
      if (childCanon == curCanon) {
        return 'next_lower_level_gtin must not equal the current GTIN';
      }
    }
    return null;
  }

  static String? validateNextLowerLevelQuantityConditional(
    String? value, {
    required bool isBaseUnit,
    required String? nextLowerLevelGtin,
  }) {
    final v = (value ?? '').trim();
    final child = (nextLowerLevelGtin ?? '').trim();
    if (isBaseUnit) {
      if (v.isNotEmpty) {
        return 'next_lower_level_quantity must be empty when is_base_unit is true';
      }
      return null;
    }
    // If not base unit, Next Lower Level GTIN is required by doc, so quantity must also be present.
    if (child.isEmpty && v.isNotEmpty) {
      return 'next_lower_level_quantity requires next_lower_level_gtin';
    }
    if (v.isEmpty) return 'next_lower_level_quantity is required when is_base_unit is false';
    if (!RegExp(r'^\d{1,6}$').hasMatch(v)) {
      return 'next_lower_level_quantity must be 1–6 digits';
    }
    final n = int.tryParse(v);
    if (n == null) return 'next_lower_level_quantity must be numeric';
    if (n <= 0) return 'next_lower_level_quantity must be > 0';
    return null;
  }

  static const Set<String> _aiIndicatorCodes = {
    'REQUESTED BY LAW',
    'NOT REQUESTED BUT ALLOCATED',
    'NOT ALLOCATED',
  };

  // Doc: Table 79
  static String? validateHasBatchNumberIndicator(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'has_batch_number_indicator is required';
    if (!_aiIndicatorCodes.contains(v)) return 'Invalid Has Batch Number Indicator';
    return null;
  }

  // Doc: Table 80 + XF-004 (serial implies batch for regulated pharma)
  static String? validateHasSerialNumberIndicator(
    String? value, {
    required String? batchIndicator,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'has_serial_number_indicator is required';
    if (!_aiIndicatorCodes.contains(v)) return 'Invalid Has Serial Number Indicator';

    // When serial is requested by law, batch must not be NOT_ALLOCATED.
    // (Spec: regulated pharma uses the four data elements; at minimum this prevents serial-only.)
    final b = (batchIndicator ?? '').trim();
    if (v == 'REQUESTED BY LAW' && b == 'NOT ALLOCATED') {
      return 'Batch indicator cannot be NOT ALLOCATED when Serial is REQUESTED BY LAW';
    }
    return null;
  }

  static String? validateTradeItemRoleFlags({
    required bool isBaseUnit,
    required bool isConsumerUnit,
    required bool isOrderableUnit,
    required bool isDespatchUnit,
    required bool isInvoiceUnit,
    required bool isVariableUnit,
    required String? unitDescriptor,
    required String? indicatorDigit,
    required bool isReadOnly,
  }) {
    if (isReadOnly) return null;

    // Doc (Table 21): at least one level in the hierarchy must be true.
    if (!(isBaseUnit ||
        isConsumerUnit ||
        isOrderableUnit ||
        isDespatchUnit ||
        isInvoiceUnit ||
        isVariableUnit)) {
      return 'At least one Trade Item Role Flag must be set to true';
    }

    // Doc (Table 18): if Base Unit is true -> Unit Descriptor must be BASE_UNIT_OR_EACH.
    final ud = (unitDescriptor ?? '').trim();
    if (isBaseUnit && ud.isNotEmpty && ud != 'BASE_UNIT_OR_EACH') {
      return "When 'Is Trade Item a Base Unit?' is true, Unit Descriptor must be BASE_UNIT_OR_EACH";
    }

    // Doc (Table 23 + XF-007): if Variable Unit is true -> Indicator Digit must be 9.
    final ind = (indicatorDigit ?? '').trim();
    if (isVariableUnit && ind.isNotEmpty && ind != '9') {
      return "When 'Is Trade Item a Variable Unit?' is true, Indicator Digit must be 9";
    }
    if (ind == '9' && !isVariableUnit) {
      return "Indicator Digit = 9 requires 'Is Trade Item a Variable Unit?' to be true";
    }

    return null;
  }

  static String? validatePackagingType(String? value) {
    // Doc: free-text packaging type; treat as optional trimmed text.
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 70) return 'packaging_type must be at most 70 characters';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'packaging_type contains invalid control characters';
    }
    return null;
  }

  static String? validateUnitOfMeasureTradeItem(String? value) {
    // Doc intent: UN/ECE Rec 20 code.
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (!RegExp(r'^[A-Z0-9]{2,3}$').hasMatch(v)) {
      return 'unit_of_measure must be a UN/ECE Rec 20 code (2–3 chars)';
    }
    return null;
  }

  static String? validateParentGtin(String? value) {
    // Doc: parent GTIN in hierarchy; optional, but must be a valid GTIN if provided.
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return validateGtinCodeOptional(v);
  }

  static String? validateQuantityPerParent(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'quantity_per_parent must be numeric';
    if (n <= 0) return 'quantity_per_parent must be > 0';
    return null;
  }

  static String? validateGln13(String? value, {required String fieldName, bool required = false}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return required ? '$fieldName is required' : null;
    if (!RegExp(r'^\d{13}$').hasMatch(v)) return '$fieldName must be exactly 13 digits';
    // Mod-10: validate check digit (last digit).
    final body = v.substring(0, 12);
    final want = int.parse(v[12]);
    final got = GtinFormat.calculateCheckDigitForBody(body);
    if (want != got) return '$fieldName has invalid check digit';
    return null;
  }

  static String? validateInformationProviderGln(String? value) =>
      validateGln13(value, fieldName: 'information_provider_gln', required: true);
  static String? validateManufacturerGln(String? value) =>
      validateGln13(value, fieldName: 'manufacturer_gln', required: true);

  static String? validateInformationProviderName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 200) return 'information_provider_name must be at most 200 characters';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'information_provider_name contains invalid control characters';
    }
    return null;
  }

  static String? validateCreatedBy(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 64) return 'created_by must be at most 64 characters';
    return null;
  }

  static String? validateUpdatedBy(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 64) return 'updated_by must be at most 64 characters';
    return null;
  }

  static String? validateTradeItemStatus(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Trade Item Status is required';
    if (v != 'ADD' && v != 'CHN' && v != 'COR') {
      return "Trade Item Status must be one of: ADD, CHN, COR";
    }
    return null;
  }

  static String? validateProductStatus(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Status is required';
    // Backend enum.
    const allowed = {'ACTIVE', 'WITHDRAWN', 'SUSPENDED', 'DISCONTINUED'};
    if (!allowed.contains(v)) return 'Invalid Status value';
    return null;
  }

  // --- Marketing Authorization Number (doc: Pharma Field 5) ---

  static String? validateMarketingAuthorizationNumber(String? value) {
    // Doc: required; regex configurable per market; max 50 chars; trim; reject control chars.
    if (value == null || value.trim().isEmpty) {
      return 'Marketing Authorization Number is required';
    }
    final v = value.trim();
    if (v.length > 50) {
      return 'Marketing Authorization Number must be at most 50 characters';
    }
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'Marketing Authorization Number contains invalid control characters';
    }
    // Market-specific regex is not yet wired; allow common regulator formats.
    if (!RegExp(r"^[A-Za-z0-9][A-Za-z0-9 \-\/_\.]*$").hasMatch(v)) {
      return 'Marketing Authorization Number contains invalid characters';
    }
    return null;
  }

  // --- GS1 Company Prefix / Item Reference (doc: derived, read-only) ---

  static String? validateGs1CompanyPrefixLengthHelper(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'GS1 Company Prefix length must be numeric';
    // Doc: 4-12 digits (most commonly 7-10).
    if (n < 4 || n > 12) return 'GS1 Company Prefix length must be 4–12';
    return null;
  }

  static String? validateGs1CompanyPrefix(String? value, {int? prefixLength}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'GS1 Company Prefix must be numeric';
    if (v.length < 4 || v.length > 12) {
      return 'GS1 Company Prefix must be 4–12 digits';
    }
    if (prefixLength != null && v.length != prefixLength) {
      return 'GS1 Company Prefix must be $prefixLength digits';
    }
    return null;
  }

  static String? validateItemReference(String? value, {int? prefixLength}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'Item Reference must be numeric';
    if (prefixLength != null) {
      final wantLen = 12 - prefixLength; // canonical14 without indicator & check = 12 digits
      if (wantLen <= 0) return 'Invalid GS1 Company Prefix length';
      if (v.length != wantLen) {
        return 'Item Reference must be $wantLen digits for prefix length $prefixLength';
      }
    } else {
      // Doc: variable; bound it to a sane range.
      if (v.isEmpty || v.length > 12) {
        return 'Item Reference must be 1–12 digits';
      }
    }
    return null;
  }

  // --- Authorization validity dates (doc: Pharma Field 6) ---

  static DateTime? _parseIsoDate(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    // Expect YYYY-MM-DD (same as our UI date display format).
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(v);
    if (m == null) return null;
    final y = int.tryParse(m.group(1)!);
    final mo = int.tryParse(m.group(2)!);
    final d = int.tryParse(m.group(3)!);
    if (y == null || mo == null || d == null) return null;
    try {
      return DateTime(y, mo, d);
    } catch (_) {
      return null;
    }
  }

  static String? validateAuthorizationValidityFromDate(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Authorization Validity From Date is required';
    if (_parseIsoDate(v) == null) {
      return 'Authorization Validity From Date must be YYYY-MM-DD';
    }
    return null;
  }

  static String? validateAuthorizationValidityToDate(
    String? toValue, {
    required String? fromValue,
  }) {
    final to = (toValue ?? '').trim();
    if (to.isEmpty) return 'Authorization Validity To Date is required';
    final toDate = _parseIsoDate(to);
    if (toDate == null) {
      return 'Authorization Validity To Date must be YYYY-MM-DD';
    }
    final fromDate = _parseIsoDate(fromValue);
    if (fromDate == null) {
      return 'Authorization Validity From Date must be set first';
    }
    if (toDate.isBefore(fromDate)) {
      return 'Authorization Validity To Date must be ≥ From Date';
    }
    return null;
  }

  // --- unit_descriptor (doc: tradeItemUnitDescriptorCode) and backend mapping ---

  static const Set<String> _docUnitDescriptorAllowed = {
    'BASE_UNIT_OR_EACH',
    'PACK_OR_INNER_PACK',
    'CASE',
    'PALLET',
    'DISPLAY_SHIPPER',
    'MIXED_MODULE',
    'PREPACK_ASSORTMENT',
  };

  /// Maps documentation `unit_descriptor` values to backend `packagingLevel` enum values.
  /// Returns null when there is no safe mapping (UI should block submit).
  static String? mapUnitDescriptorToBackendPackagingLevel(String? unitDescriptor) {
    final v = (unitDescriptor ?? '').trim();
    if (v.isEmpty) return null;
    return switch (v) {
      'BASE_UNIT_OR_EACH' => 'ITEM',
      'PACK_OR_INNER_PACK' => 'PACK',
      'CASE' => 'CASE',
      'PALLET' => 'PALLET',
      // These exist in GS1 code lists but are not supported by backend enum today.
      'DISPLAY_SHIPPER' => null,
      'MIXED_MODULE' => null,
      'PREPACK_ASSORTMENT' => null,
      _ => null,
    };
  }

  /// Validator for the primary dropdown (doc: `unit_descriptor`) while backend still expects `packagingLevel`.
  static String? validateUnitDescriptor(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'unit_descriptor is required';
    if (!_docUnitDescriptorAllowed.contains(v)) {
      return 'unit_descriptor must be a valid GS1 code list value';
    }
    final mapped = mapUnitDescriptorToBackendPackagingLevel(v);
    if (mapped == null) {
      return 'unit_descriptor value is not supported by backend packagingLevel yet';
    }
    return null;
  }
}

/// Return type for [GtinFieldValidators.validGtinChipsData].
typedef GtinCodeChipsData = ({
  String structureLabel,
  String indicatorDigit,
  String canonical14,
  String checkDigit,
});
