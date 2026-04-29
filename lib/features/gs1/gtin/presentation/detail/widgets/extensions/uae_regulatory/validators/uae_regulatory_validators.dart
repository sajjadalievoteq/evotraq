class UaeRegulatoryValidators {
  UaeRegulatoryValidators._();

  // Configurable placeholder until exact MoHAP regex is finalized.
  static final RegExp _defaultUaeMaNumberPattern =
      RegExp(r'^[A-Z]+-\d{3,10}-\d{4}$');

  // Configurable placeholder until exact MoHAP regex is finalized.
  static final RegExp _defaultUaeLocalDrugCodePattern =
      RegExp(r'^[A-Z0-9][A-Z0-9\-\/]{2,49}$');

  static String? validateUaeLocalDrugCode(
    String? value, {
    required bool isUaeMarket,
    RegExp? pattern,
  }) {
    final v = (value ?? '').trim();
    if (!isUaeMarket) return null;
    if (v.isEmpty) return 'UAE local drug code is required for UAE market';
    if (v.length > 50) return 'UAE local drug code must be at most 50 characters';
    final rx = pattern ?? _defaultUaeLocalDrugCodePattern;
    if (!rx.hasMatch(v)) return 'Invalid UAE local drug code format';
    return null;
  }

  static String? validateUaeMarketingAuthorization(
    String? value, {
    required bool isUaeMarket,
    RegExp? pattern,
  }) {
    final v = (value ?? '').trim();
    if (!isUaeMarket) return null;
    if (v.isEmpty) return 'Marketing authorization number is required for UAE market';
    if (v.length > 50) return 'Marketing authorization number must be at most 50 characters';
    final rx = pattern ?? _defaultUaeMaNumberPattern;
    if (!rx.hasMatch(v)) return 'Invalid UAE marketing authorization format';
    return null;
  }

  static String? validateUaeLicensedAgent(
    String? value, {
    required bool isUaeMarket,
    required bool isImportedProduct,
  }) {
    final v = (value ?? '').trim();
    if (!isUaeMarket) return null;
    if (isImportedProduct && v.isEmpty) {
      return 'Licensed agent GLN is required for imported UAE products';
    }
    return null;
  }

  static String? validateUaeProductNameLanguages({
    required bool isUaeMarket,
    required String? englishName,
    required String? arabicName,
  }) {
    if (!isUaeMarket) return null;
    if ((englishName ?? '').trim().isEmpty) {
      return 'English regulated product name is required for UAE market';
    }
    if ((arabicName ?? '').trim().isEmpty) {
      return 'Arabic regulated product name is required for UAE market';
    }
    return null;
  }

  static String? validateUaeEnglishRegulatedName(
    String? value, {
    required bool isUaeMarket,
  }) {
    if (!isUaeMarket) return null;
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'English regulated product name is required for UAE market';
    if (v.length > 200) return 'Regulated product name must be at most 200 characters';
    return null;
  }
}
