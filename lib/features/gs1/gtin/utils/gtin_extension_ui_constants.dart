// User-visible copy for GTIN industry extensions (pharmaceutical tile, regulatory authority, etc.).

/// Shared placeholders used by GTIN extension forms (avoid importing GLN-specific constants).
abstract final class GtinExtensionSharedUiConstants {
  static const dateNotSet = 'Not set';
  static const selectState = 'Select State';
  static const selectCountry = 'Select Country';
}

/// [PharmaceuticalExtensionWidget] shell / expansion chrome only (group widgets own section copy).
abstract final class GtinPharmaceuticalExtensionUiConstants {
  static const expansionTitle = 'Pharmaceutical Details';
}

/// Regulatory authority expansion + nested cards for GTIN pharmaceutical extension.
abstract final class GtinRegulatoryAuthorityExtensionUiConstants {
  static const expansionTitle = 'Regulatory authority';

  static const sectionIdentifiers = 'Regulatory authority — identifiers';
  static const labelLocalDrugCode = 'Local drug code (MoHAP) *';
  static const helperLocalDrugCode =
      'Required when regulatory authority applies; configurable MoHAP format';
  static const labelMarketingAuthorizationNumber = 'Marketing authorization number *';
  static const helperMarketingAuthorizationNumber =
      'Example format: MOHAP-12345-2026 (configurable)';

  static const sectionAuthorization = 'Regulatory authority — authorization';
  static const labelLicensedAgentGlns = 'Licensed agent GLNs';
  static const helperLicensedAgentGlns =
      'Required for imported products under regulatory authority; comma/semicolon/newline separated';

  static const sectionDistribution = 'Regulatory authority — distribution';
  static const checkboxRegulatoryAuthorityMarket =
      'Regulatory authority market active (target market = 784)';
  static const checkboxImportedProduct =
      'Imported product (licensed agent required)';
  static const subtitleImportedProduct =
      'Derived from MAH country when regulatory authority market applies';

  static const sectionLabeling = 'Regulatory authority — labeling';
  static const labelRegulatedProductName = 'Regulated product name (English) *';
  static const helperRegulatedProductName =
      'Arabic name is mandatory under regulatory authority labeling; capture in multilingual name records';
}
