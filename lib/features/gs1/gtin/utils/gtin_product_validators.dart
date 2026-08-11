part of 'gtin_field_validators.dart';

abstract final class _GtinProductValidators {
  static String? validateBrandName(String? value) {
    if (value == null || value.trim().isEmpty) return 'brand_name is required';
    final v = value.trim();
    if (v.length > 70) return 'brand_name must be at most 70 characters';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'brand_name contains invalid control characters';
    }
    return null;
  }

  static String? validateFunctionalName(
    String? value, {
    required bool hasGpcBrickCode,
  }) {
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
    if (v.length > 200) {
      return 'trade_item_description must be at most 200 characters';
    }
    return null;
  }

  static String? validateGpcBrickCode(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'gpc_brick_code is required';
    if (!RegExp(r'^\d{8}$').hasMatch(v)) {
      return 'gpc_brick_code must be exactly 8 digits';
    }
    if (!v.startsWith('1000')) return "gpc_brick_code must start with '1000'";
    return null;
  }

  static String? validateIso3166Numeric3(
    String? value, {
    required String fieldName,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';
    if (!RegExp(r'^\d{3}$').hasMatch(v)) {
      return '$fieldName must be exactly 3 digits';
    }
    return null;
  }

  static String? validateTargetMarketCountry(String? value) =>
      validateIso3166Numeric3(value, fieldName: 'target_market_country');

  static String? validateCountryOfOrigin(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d{3}$').hasMatch(v)) {
      return 'country_of_origin must be exactly 3 digits';
    }
    return null;
  }

  static String? validateNetContentValueRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'net_content_value is required';

    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(v)) {
      return 'net_content_value must be a numeric value (e.g. 10 or 10.5)';
    }
    final n = double.tryParse(v);
    if (n == null) {
      return 'net_content_value must be a numeric value (e.g. 10 or 10.5)';
    }
    if (n <= 0) return 'net_content_value must be > 0';
    return null;
  }

  static String? validateUomCode3Required(
    String? value, {
    required String fieldName,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';

    if (!RegExp(r'^[A-Z0-9]{2,3}$').hasMatch(v)) {
      return '$fieldName must be 2–3 characters';
    }
    return null;
  }

  static String? validateNetContentUomRequired(String? value) =>
      validateUomCode3Required(value, fieldName: 'net_content_uom');

  static String? validateOptionalDecimalNonNegative(
    String? value, {
    required String fieldName,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return '$fieldName must be numeric';
    if (n < 0) return '$fieldName must be >= 0';
    return null;
  }

  static String? validateOptionalDecimalPositive(
    String? value, {
    required String fieldName,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(v)) {
      return '$fieldName must be a numeric value (e.g. 10 or 10.5)';
    }
    final n = double.tryParse(v);
    if (n == null) {
      return '$fieldName must be a numeric value (e.g. 10 or 10.5)';
    }
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
    if (v.isEmpty) {
      return 'quantity_of_children is required when is_base_unit is false';
    }
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
    if (v.isEmpty) {
      return 'total_qty_next_lower is required when is_base_unit is false';
    }
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
    if (v.isEmpty) {
      return 'next_lower_level_gtin is required when is_base_unit is false';
    }
    final gtinErr = _GtinCoreValidators.validateGtinCodeOptional(v);
    if (gtinErr != null) {
      return gtinErr.replaceFirst('GTIN', 'next_lower_level_gtin');
    }

    final curStripped = GtinFormat.stripGtinInput(currentGtinRaw);
    if (GtinFormat.isValidGtin(curStripped)) {
      final curCanon = GtinFormat.normalizeGtinTo14(curStripped);
      final childCanon = GtinFormat.normalizeGtinTo14(
        GtinFormat.stripGtinInput(v),
      );
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

    if (child.isEmpty && v.isNotEmpty) {
      return 'next_lower_level_quantity requires next_lower_level_gtin';
    }
    if (v.isEmpty) {
      return 'next_lower_level_quantity is required when is_base_unit is false';
    }
    if (!RegExp(r'^\d{1,6}$').hasMatch(v)) {
      return 'next_lower_level_quantity must be 1–6 digits';
    }
    final n = int.tryParse(v);
    if (n == null) return 'next_lower_level_quantity must be numeric';
    if (n <= 0) return 'next_lower_level_quantity must be > 0';
    return null;
  }
}
