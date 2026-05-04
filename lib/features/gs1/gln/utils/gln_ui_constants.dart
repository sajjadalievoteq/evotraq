import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

/// Filter, sort, pagination, and user-visible copy for GLN master data.
abstract final class GlnUiConstants {
  // --- Filter / sort ---
  static const filterAll = 'All';
  static const statusActive = 'Active';
  static const statusInactive = 'Inactive';
  static const sortAscendingLabel = 'A–Z';
  static const sortDescendingLabel = 'Z–A';
  static const sortFieldFallback = 'location name';
  static const sortLabelLocationName = 'location name';
  static const sortLabelGlnCode = 'GLN code';
  static const sortLabelAddress = 'address';
  static const sortLabelCity = 'city';
  static const sortLabelLicenseNumber = 'license number';

  static const listSearchHint =
      'Search by GLN code, location name, address, or contact info...';

  static const List<String> statusOptions = [
    filterAll,
    statusActive,
    statusInactive,
  ];

  static const locationTypeManufacturing = 'Manufacturing Site';
  static const locationTypeWarehouse = 'Warehouse';
  static const locationTypeDistribution = 'Distribution Center';
  static const locationTypePharmacy = 'Pharmacy';
  static const locationTypeHospital = 'Hospital';
  static const locationTypeWholesaler = 'Wholesaler';
  static const locationTypeClinic = 'Clinic';
  static const locationTypeRegulatory = 'Regulatory Body';
  static const locationTypeOther = 'Other';

  static const List<String> locationTypeOptions = [
    filterAll,
    locationTypeManufacturing,
    locationTypeWarehouse,
    locationTypeDistribution,
    locationTypePharmacy,
    locationTypeHospital,
    locationTypeWholesaler,
    locationTypeClinic,
    locationTypeRegulatory,
    locationTypeOther,
  ];

  /// [locationTypeOptions] without the "All" sentinel (detail form subtype dropdown).
  static const List<String> locationTypeDetailOptions = [
    locationTypeManufacturing,
    locationTypeWarehouse,
    locationTypeDistribution,
    locationTypePharmacy,
    locationTypeHospital,
    locationTypeWholesaler,
    locationTypeClinic,
    locationTypeRegulatory,
    locationTypeOther,
  ];

  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;

  /// API [sortBy] values → short labels for the sort row.
  static const Map<String, String> sortFieldLabels = {
    'locationName': sortLabelLocationName,
    'glnCode': sortLabelGlnCode,
    'addressLine1': sortLabelAddress,
    'city': sortLabelCity,
    'licenseNumber': sortLabelLicenseNumber,
  };

  // --- List & navigation ---
  static const appBarManagement = 'GLN Management';
  static const fabAddNew = 'Add New GLN';
  static const fabCloseCreate = 'Close create form';
  static const emptyNoMatchSearch = 'No GLNs match your search.';
  static const emptyListTitle = 'No GLNs found';
  static const entityPluralGlns = 'GLNs';
  static const listCardGlnPrefix = 'GLN: ';
  static const menuTooltipActions = 'Actions';
  static const menuViewDetails = 'View Details';
  static const menuEdit = 'Edit';
  static const menuDelete = 'Delete';

  static const splitCreateHeader = 'Create GLN';
  static const tooltipClose = 'Close';

  static const dialogAdvancedFiltersTitle = 'Advanced Filters';
  static const buttonClose = 'Close';
  static const dialogConfirmDeletionTitle = 'Confirm Deletion';
  static const dialogCancel = 'CANCEL';
  static const dialogDelete = 'DELETE';
  static String deleteGlnConfirm(String locationName) =>
      'Are you sure you want to delete the GLN for "$locationName"?';
  static String sortByLine(String fieldLabel, String orderSpan) =>
      'Sort by $fieldLabel ($orderSpan)';

  static const quickFiltersTitle = 'Quick Filters';
  static const filterSectionLocationName = 'Location Name';
  static const hintLocationNameExample =
      'e.g., Main Warehouse, Central Pharmacy';
  static const filterSectionStatus = 'Status';
  static const filterSectionLocationType = 'Location Type';
  static const quickFiltersFooterHint =
      'For more advanced filters, use the tune icon on the search bar.';
  static const buttonCancel = 'Cancel';
  static const buttonApply = 'Apply';
  static const buttonClearFilters = 'Clear Filters';

  static const advancedFiltersHeader = 'Advanced Filters (Database Filters)';
  static const advancedFiltersNote =
      'Note: These filters are applied at database level for precise results';
  static const labelLocationNameField = 'Location Name';
  static const labelGlnCode = 'GLN Code';
  static const hintGlnCodeExample = 'e.g., 1234567890123';
  static const labelLocationType = 'Location Type';
  static const labelStatus = 'Status';
  static const labelAddress = 'Address';
  static const hintAddress = 'Street, city, state, country';
  static const labelLicenseNumberField = 'License Number';
  static const hintLicenseNumber = 'Regulatory license number';
  static const labelContactEmail = 'Contact Email';
  static const labelContactNameField = 'Contact Name';
  static const labelSortResultsBy = 'Sort results by';
  static const buttonApplyFilters = 'Apply Filters';
  static const buttonClearAll = 'Clear All';
  static const advancedFiltersSuccessBanner =
      'Database-level filtering is now active! These filters are applied directly at the database for optimal performance with large datasets.';

  static const detailSaveButton = 'SAVE GLN';
  static const detailTitleCreate = 'Create GLN';
  static const detailTitleEdit = 'Edit GLN';
  static const detailTitleView = 'GLN Details';
  static const errorSelectGlnType = 'Select at least one GLN type';
  static const errorFixForm = 'Please correct the errors in the form';
  static const errorGeneric = 'An error occurred';
  static const successGlnSaved = 'GLN saved successfully';

  static const errorDeleteGlnFailed = 'Failed to delete GLN';

  static const sectionIdentificationStructure = 'Identification & structure';
  static const sectionGlnTypesClassification = 'GLN types * & classification';
  static const sectionLegalEntity = 'Legal entity attributes';
  static const sectionLocationAddress = 'Location & address';
  static const sectionDigitalLocation = 'Digital location';
  static const sectionLicense = 'License';
  static const sectionContact = 'Contact';
  static const sectionGeospatial = 'Geospatial coordinates (EPCIS 2.0)';
  static const sectionOperationalLocationType = 'Operational location type';
  static const sectionLifecycleStatus = 'Lifecycle & status';

  static const labelGlnThirteenDigits = 'GLN (13 digits) *';
  static const hintGlnThirteen = 'Enter 13-digit GLN';
  static const labelGcpLength = 'GCP length';
  static const labelGcp = 'GCP';
  static const labelLocationReference = 'Location reference';
  static const labelParentGln = 'Parent GLN';
  static const hintParentGln =
      '13-digit parent (e.g. legal entity for a function)';
  static const labelGlnExtensionAi254 = 'GLN extension component (AI 254)';
  static const helperGlnExtensionAi254 =
      'Internal sub-location — max 20 chars; pairs with physical GLN';

  static const labelIndustryClassification = 'Industry classification';
  static const labelGlnSource = 'GLN source';
  static const industryHealthcare = 'HEALTHCARE';
  static const industryCpg = 'CPG';
  static const industryApparel = 'APPAREL';
  static const industryFoodservice = 'FOODSERVICE';
  static const industryOther = 'OTHER';
  static const glnSourceSelfAllocatedValue = 'SELF_ALLOCATED';
  static const glnSourceSelfAllocatedLabel = 'Self allocated';
  static const glnSourcePartnerValue = 'PARTNER_PROVIDED';
  static const glnSourcePartnerLabel = 'Partner provided';
  static const glnSourceGs1Value = 'GS1_MANAGED_GLN';
  static const glnSourceGs1Label = 'GS1 managed';
  static const glnSourceRegulatorValue = 'REGULATOR_ASSIGNED';
  static const glnSourceRegulatorLabel = 'Regulatory authority assigned';
  static const labelSupplyChainRoles = 'Supply-chain roles';
  static const helperSupplyChainRoles =
      'Comma-separated (e.g. MANUFACTURER, DISTRIBUTOR)';
  static const labelLocationRoles = 'Location roles';
  static const helperLocationRoles =
      'Comma-separated (e.g. WAREHOUSE, PHARMACY)';

  static const labelRegisteredLegalName = 'Registered legal name';
  static const labelTradingName = 'Trading / brand name';
  static const labelLei = 'LEI (20 chars)';
  static const labelTaxVat = 'Tax / VAT registration';
  static const labelCountryIncorporationNumeric =
      'Country of incorporation (ISO 3166-1 numeric)';
  static const helperCountryIncorporationNumeric =
      'Tap to choose (stores numeric code, e.g. 784)';
  static const labelWebsite = 'Website';

  static const labelLocationNameRequired = 'Location name *';
  static const labelFixedVsMobile = 'Fixed vs mobile';
  static const mobilityFixed = 'FIXED';
  static const mobilityMobile = 'MOBILE';
  static const labelMobileLocationId = 'Mobile location ID';
  static const helperMobileLocationId = 'Vehicle reg, IMO, tail number…';
  static const labelAddressLine1 = 'Address line 1 *';
  static const labelAddressLine2 = 'Address line 2';
  static const labelCityRequired = 'City *';
  static const labelStateProvince = 'State / province *';
  static const labelPostalCode = 'Postal code *';
  static const labelCountryRequired = 'Country *';

  static const labelDigitalAddressType = 'Digital address type';
  static const digitalTypeEdiGateway = 'EDI_GATEWAY';
  static const digitalTypeEdiGatewayLabel = 'EDI gateway';
  static const digitalTypeUrl = 'URL';
  static const digitalTypeAs2 = 'AS2_ENDPOINT';
  static const digitalTypeAs2Label = 'AS2 endpoint';
  static const digitalTypeSftp = 'SFTP';
  static const digitalTypeApi = 'API';
  static const digitalTypeEmail = 'EMAIL';
  static const digitalTypeEmailLabel = 'Email';
  static const digitalTypeOther = 'OTHER';
  static const digitalTypeOtherLabel = 'Other';
  static const labelDigitalAddressValue = 'Digital address value';

  static const labelLicenseValidFrom = 'License valid from';
  static const labelLicenseValidUntil = 'License valid until';
  static const labelLicenseNumber = 'License number';
  static const labelLicenseType = 'License type';

  static const labelContactName = 'Contact name';
  static const labelEmail = 'Email';
  static const labelPhone = 'Phone';

  static const labelOperatingStatus = 'Operating status';
  static const operatingDraft = 'DRAFT';
  static const operatingActive = 'ACTIVE';
  static const operatingInactive = 'INACTIVE';
  static const operatingDiscontinued = 'DISCONTINUED';
  static const labelEffectiveFrom = 'Effective from';
  static const labelEffectiveTo = 'Effective to';
  static const labelNonReuseWaiting = 'Non-reuse waiting until';
  static const helperNonReuseReadonly =
      'Read-only — set by backend when discontinued';

  static const labelLegacyLocationSubtype = 'Legacy location subtype';
  static const helperOperationalCategory =
      'Operational category (warehouse, pharmacy, …)';
  static const operationalFallbackOther = 'Other';
}

/// GLN form validation messages ([GlnFieldValidators]).
abstract final class GlnValidationConstants {
  static String invalidControlChars(String field) =>
      '$field contains invalid control characters';

  static String mustBeAtMostChars(String field, int max) =>
      '$field must be at most $max characters';

  static const glnCodeRequired = 'GLN Code is required';
  static const glnMustBe13Digits = 'GLN must be exactly 13 digits';
  static const glnInvalidCheckDigit =
      'Invalid check digit. Verify the GLN or use a GS1 check-digit calculator.';

  static const locationNameRequired = 'Location Name is required';
  static const fieldLocationName = 'Location Name';
  static const fieldCity = 'City';
  static const fieldCountry = 'Country';
  static const addressLine1Required = 'Address Line 1 is required';
  static const cityRequired = 'City is required';
  static const stateProvinceRequired = 'State/Province is required';
  static const postalCodeRequired = 'Postal Code is required';
  static const countryRequired = 'Country is required';

  static const emailMaxLength = 'Email must be at most 254 characters';
  static const emailInvalidChars = 'Email contains invalid characters';
  static const emailInvalidFormat = 'Enter a valid email';

  static const phoneInvalidControl = 'Phone contains invalid control characters';
  static String phoneMaxLen(int max) => 'Phone must be at most $max characters';
  static const phoneTooShort = 'Phone number is too short';
  static const phoneFormatHint =
      'Use digits with optional + prefix (spaces/parentheses allowed)';

  static String extensionAi254Max(int max) =>
      'Extension component must be at most $max characters (GS1 AI 254)';
  static const extensionAi254Charset =
      'Use letters, digits, and - _ . / & + only (GS1 character set)';

  static const leiLength = 'LEI must be exactly 20 characters';
  static const leiAlphanumeric = 'LEI must be alphanumeric (A–Z, 0–9) only';
  static const leiInvalidCheck =
      'Invalid LEI check characters (ISO 7064 Mod 97-10)';

  static const taxVatField = 'Tax / VAT registration';

  static const urlMax = 'URL must be at most 2000 characters';
  static const urlValidWithScheme =
      'Enter a valid URL (include http:// or https://)';
  static const urlHttpHttpsOnly = 'URL must use http or https';
  static const urlHostRequired = 'URL must include a host name';

  static String rolesMaxLen(int max) => 'Must be at most $max characters';
  static const rolesTokenFormat =
      'Each role must be a code like MANUFACTURER (letters, digits, underscore)';

  static const gs1PrefixDigitsOnly =
      'GS1 Company Prefix must contain only digits';
  static const gs1PrefixLength = 'GS1 Company Prefix must be 4–12 digits';
  static const locationRefDigits = 'Location reference must be 1–11 digits';
  static const checkDigitSingle = 'Check digit must be a single digit (0–9)';

  static const fieldContactName = 'Contact name';
  static const fieldRegisteredLegalName = 'Registered legal name';
  static const fieldTradingName = 'Trading name';
  static const fieldLicenseNumber = 'License number';
  static const fieldLicenseType = 'License type';
  static const fieldAddressLine1 = 'Address Line 1';
  static const fieldAddressLine2 = 'Address Line 2';
  static const fieldStateProvince = 'State/Province';
  static const fieldPostalCode = 'Postal Code';
  static const fieldMobileLocationId = 'Mobile location ID';
  static const fieldDigitalAddress = 'Digital address';

  static String digitalAddressMaxLen(int max) =>
      'Digital address must be at most $max characters';
}
