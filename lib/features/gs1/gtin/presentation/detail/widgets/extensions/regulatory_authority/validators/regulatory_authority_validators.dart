class RegulatoryAuthorityValidators {
  RegulatoryAuthorityValidators._();

  // Configurable placeholder until exact MoHAP regex is finalized.
  static final RegExp _defaultRegulatoryAuthorityMaNumberPattern =
      RegExp(r'^[A-Z]+-\d{3,10}-\d{4}$');

  // Configurable placeholder until exact MoHAP regex is finalized.
  static final RegExp _defaultRegulatoryAuthorityLocalDrugCodePattern =
      RegExp(r'^[A-Z0-9][A-Z0-9\-\/]{2,49}$');

  static String? validateLocalDrugCodeForRegulatoryAuthority(
    String? value, {
    required bool isRegulatoryAuthorityMarket,
    RegExp? pattern,
  }) {
    final v = (value ?? '').trim();
    if (!isRegulatoryAuthorityMarket) return null;
    if (v.isEmpty) {
      return 'Local drug code is required when regulatory authority applies';
    }
    if (v.length > 50) {
      return 'Local drug code must be at most 50 characters';
    }
    final rx = pattern ?? _defaultRegulatoryAuthorityLocalDrugCodePattern;
    if (!rx.hasMatch(v)) return 'Invalid local drug code format';
    return null;
  }

  static String? validateMarketingAuthorizationForRegulatoryAuthority(
    String? value, {
    required bool isRegulatoryAuthorityMarket,
    RegExp? pattern,
  }) {
    final v = (value ?? '').trim();
    if (!isRegulatoryAuthorityMarket) return null;
    if (v.isEmpty) {
      return 'Marketing authorization number is required when regulatory authority applies';
    }
    if (v.length > 50) {
      return 'Marketing authorization number must be at most 50 characters';
    }
    final rx = pattern ?? _defaultRegulatoryAuthorityMaNumberPattern;
    if (!rx.hasMatch(v)) return 'Invalid marketing authorization format';
    return null;
  }

  static String? validateLicensedAgentForRegulatoryAuthority(
    String? value, {
    required bool isRegulatoryAuthorityMarket,
    required bool isImportedProduct,
  }) {
    final v = (value ?? '').trim();
    if (!isRegulatoryAuthorityMarket) return null;
    if (isImportedProduct && v.isEmpty) {
      return 'Licensed agent GLN is required for imported products under regulatory authority';
    }
    return null;
  }

  static String? validateProductNameLanguagesForRegulatoryAuthority({
    required bool isRegulatoryAuthorityMarket,
    required String? englishName,
    required String? arabicName,
  }) {
    if (!isRegulatoryAuthorityMarket) return null;
    if ((englishName ?? '').trim().isEmpty) {
      return 'English regulated product name is required when regulatory authority applies';
    }
    if ((arabicName ?? '').trim().isEmpty) {
      return 'Arabic regulated product name is required when regulatory authority applies';
    }
    return null;
  }

  static String? validateEnglishRegulatedNameForRegulatoryAuthority(
    String? value, {
    required bool isRegulatoryAuthorityMarket,
  }) {
    if (!isRegulatoryAuthorityMarket) return null;
    final v = (value ?? '').trim();
    if (v.isEmpty) {
      return 'English regulated product name is required when regulatory authority applies';
    }
    if (v.length > 200) {
      return 'Regulated product name must be at most 200 characters';
    }
    return null;
  }
}
