import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

/// Filter, sort, pagination, list navigation, and user-visible copy for GTIN master data.
abstract final class GtinUiConstants {
  // --- Filter / sort ---
  static const filterAll = 'All';
  static const sortAscendingLabel = 'A–Z';
  static const sortDescendingLabel = 'Z–A';
  static const sortLabelProductName = 'product name';

  static String sortByProductNameLine(bool ascending) =>
      'Sort by $sortLabelProductName '
      '(${ascending ? sortAscendingLabel : sortDescendingLabel})';

  static const List<String> statusOptions = [
    filterAll,
    'Active',
    'Withdrawn',
    'Suspended',
    'Discontinued',
  ];

  static const List<String> packagingLevelOptions = [
    filterAll,
    'ITEM',
    'INNER_PACK',
    'PACK',
    'CASE',
    'PALLET',
  ];

  /// Packaging levels for forms (no "All" sentinel).
  static const List<String> packagingLevelValues = [
    'ITEM',
    'INNER_PACK',
    'PACK',
    'CASE',
    'PALLET',
  ];

  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;

  static const String listSearchHint =
      'Search by GTIN code, product name, or manufacturer...';

  // --- List & navigation ---
  static const appBarManagement = 'GTIN Management';
  static const fabAddNew = 'Add New GTIN';
  static const fabCloseCreate = 'Close create form';
  static const emptyNoMatchSearch = 'No GTINs match your search.';
  static const emptyListTitle = 'No GTINs found';
  static const entityPluralGtins = 'GTINs';
  static const listCardGtinPrefix = 'GTIN: ';
  static const listCardManufacturerPrefix = 'Manufacturer: ';
  static const listCardLevelPrefix = 'Level: ';
  static const listCardRegisteredPrefix = 'Registered: ';
  static const listCardPackPrefix = 'Pack: ';

  static const splitCreateHeader = 'Create GTIN';
  static const tooltipClose = 'Close';

  static const dialogAdvancedFiltersTitle = 'Advanced Filters';
  static const buttonClose = 'Close';

  static const quickFiltersTitle = 'Quick Filters';
  static const filterSectionManufacturer = 'Manufacturer';
  static const hintManufacturerExample = 'e.g., Pfizer, Johnson & Johnson';
  static const filterSectionStatus = 'Status';
  static const filterSectionPackagingLevel = 'Packaging Level';
  static const quickFiltersFooterHint =
      'For more advanced filters, use the "Show Advanced Filters" option below the search bar.';
  static const buttonCancel = 'Cancel';
  static const buttonApply = 'Apply';
  static const buttonClearFilters = 'Clear Filters';

  static const advancedFiltersHeader = 'Advanced Filters (Database Filters)';
  static const advancedFiltersNote =
      'Note: These filters are applied at database level for precise results';
  static const labelProductNameField = 'Product Name';
  static const hintProductNameExample = 'e.g., Aspirin, Paracetamol';
  static const labelGtinCodeField = 'GTIN Code';
  static const hintGtinCodeExample = 'e.g., 1234567890123';
  static const labelPackagingLevelField = 'Packaging Level';
  static const labelManufacturerField = 'Manufacturer';
  static const labelRegDateFrom = 'Reg. Date From';
  static const labelRegDateTo = 'Reg. Date To';
  static const tooltipPickFromDate = 'Pick from date';
  static const tooltipPickToDate = 'Pick to date';
  static const buttonApplyFilters = 'Apply Filters';
  static const buttonClearAll = 'Clear All';
  static const advancedFiltersSuccessBanner =
      'Database-level filtering is now active! These filters are applied directly at the database for optimal performance with large datasets.';

  static const showAdvancedFilters = 'Show Advanced Filters';
  static const hideAdvancedFilters = 'Hide Advanced Filters';
  static const clearAllFiltersButton = 'Clear All Filters';

  static String chipManufacturer(String value) => 'Manufacturer: $value';
  static String chipStatus(String value) => 'Status: $value';
  static String chipLevel(String value) => 'Level: $value';
  static String chipProduct(String value) => 'Product: $value';
  static String chipGtinCode(String value) => 'GTIN: $value';

  // --- Detail scaffold ---
  static const detailTitleView = 'GTIN Details';
  static const detailTitleEdit = 'Edit GTIN';
  static const detailTitleCreate = 'Create GTIN';
  static const submitUpdateGtin = 'Update GTIN';
  static const submitCreateGtin = 'Create GTIN';

  static String successGtinUpdated(String gtinCode) =>
      'GTIN $gtinCode updated successfully';
  static String successGtinCreated(String gtinCode) =>
      'GTIN $gtinCode created successfully';

  // --- Identification & structure ---
  static const sectionIdentificationStructure = 'Identification & Structure';
  static const labelGtinRequired = 'GTIN *';
  static const helperGtinDigits = '8, 12, 13, or 14 digits';
  static const labelGcpLengthChip = 'GCP length';
  static const labelGcpChip = 'GCP';
  static const labelItemReferenceChip = 'Item reference';
  static const messageEnterValidGtin = 'Enter a valid GTIN';

  // --- Packaging hierarchy & trade item roles ---
  static const sectionPackagingHierarchyTradeItemRoles =
      'Packaging Hierarchy & Trade Item Roles';
  static const labelNextLowerLevelGtin = 'Next Lower Level GTIN';
  static const helperWhenBaseUnitFalse = 'Required when Base unit = false';
  static const labelNextLowerLevelQuantity = 'Next Lower Level Quantity';
  static const labelQuantityOfChildren = 'Quantity of Children';
  static const labelTotalQtyNextLower =
      'Total Quantity of Next Lower Level Trade Items';
  static const labelLaunchDate = 'Launch Date';
  static const sectionTradeItemRoleFlags = 'Trade Item Role Flags';
  static const switchTradeItemBaseUnit = 'Is Trade Item a Base Unit?';
  static const switchTradeItemConsumerUnit = 'Is Trade Item a Consumer Unit?';
  static const switchTradeItemOrderableUnit = 'Is Trade Item an Orderable Unit?';
  static const switchTradeItemDespatchUnit =
      'Is Trade Item a Despatch (Shipping) Unit?';
  static const switchTradeItemInvoiceUnit = 'Is Trade Item an Invoice Unit?';
  static const switchTradeItemVariableUnit = 'Is Trade Item a Variable Unit?';

  // --- Lifecycle, availability & status ---
  static const sectionLifecycleAvailabilityStatus =
      'Lifecycle, Availability & Status';
  static const labelTradeItemStatus = 'Trade Item Status';
  static const helperTradeItemStatusCodes = 'ADD / CHN / COR';
  static const tradeItemStatusAdd = 'ADD';
  static const tradeItemStatusChn = 'CHN';
  static const tradeItemStatusCor = 'COR';
  static const labelEffectiveDateTime = 'Effective Date / Time';
  static const labelStartAvailabilityDateTime =
      'Start Availability Date / Time';
  static const labelEndAvailabilityDateTime = 'End Availability Date / Time';
  static const labelPublicationDate = 'Publication Date';
  static const errorEffectiveDateRequired = 'effective_date is required';

  // --- Production, batch, serial ---
  static const sectionProductionBatchSerialDateAssociations =
      'Production, Batch, Serial & Date Associations';
  static const labelHasBatchNumberIndicator = 'Has Batch Number Indicator';
  static const helperBatchIndicatorPharma =
      'Required for traceability in pharmaceutical products';
  static const labelHasSerialNumberIndicator = 'Has Serial Number Indicator';
  static const helperSerialIndicatorPharma =
      'Required for pharmaceutical serialization and traceability';
  static const batchSerialRequestedByLaw = 'REQUESTED BY LAW';
  static const batchSerialNotRequestedButAllocated =
      'NOT REQUESTED BUT ALLOCATED';
  static const batchSerialNotAllocated = 'NOT ALLOCATED';
  static const batchSerialValueRequestedByLaw = 'REQUESTED_BY_LAW';
  static const batchSerialValueNotRequestedButAllocated =
      'NOT_REQUESTED_BUT_ALLOCATED';
  static const batchSerialValueNotAllocated = 'NOT_ALLOCATED';

  // --- Trade item descriptive ---
  static const sectionTradeItemDescriptiveAttributes =
      'Trade Item Descriptive Attributes';
  static const labelFunctionalName = 'Functional Name';
  static const labelTradeItemDescription = 'Trade Item Description';
  static const labelGpcBrickCode = 'GPC Brick Code';
  static const helperGpcBrickCode = "8 digits, must start with '1000'";
  static const labelTargetMarketCountryCode = 'Target Market Country Code';
  static const helperIso3166Numeric3 = 'ISO 3166-1 numeric (3 digits)';

  // --- Trade item masterdata (bound group) ---
  static const sectionTradeItemData = 'Trade Item Data';
  static const labelBrandNameRequired = 'Brand Name *';
  static const labelManufacturerRequired = 'Manufacturer *';
  static const labelTradeItemUnitDescriptor = 'Trade Item Unit Descriptor *';
  static const helperGdsnUnitDescriptor = 'GDSN tradeItemUnitDescriptorCode';
  static const labelPackSize = 'Pack Size';
  static const helperPackSizeExamples = 'e.g., 30, 100, 500';
  static const labelProductLifecycleStatus = 'Status';

  // --- Classification, market & origin ---
  static const sectionClassificationMarketOrigin =
      'Classification, Market & Origin';
  static const labelCountryOfOrigin = 'Country of Origin';

  // --- Information provider & manufacturer ---
  static const sectionInformationProviderManufacturer =
      'Information Provider & Manufacturer';
  static const labelInformationProviderGln = 'Information Provider GLN';
  static const helperInformationProviderGln =
      'Enter a 13-digit barcode (numbers only, last digit is auto-verified)';
  static const labelInformationProviderName = 'Information Provider Name';
  static const labelManufacturerGlnField = 'Manufacturer GLN';
  static const helperManufacturerGlnField =
      'Enter a 13-digit GLN (provided by your organization)';

  // --- Net content & measurements ---
  static const sectionNetContentMeasurements = 'Net Content & Measurements';
  static const labelNetContentValue = 'Net Content Value';
  static const labelNetContentUom = 'Net Content UOM';
  static const helperUneceRec20 = 'UN/ECE Rec 20 code (2–3 chars, uppercase)';
  static const labelGrossWeightValue = 'Gross Weight Value';
  static const labelGrossWeightUom = 'Gross Weight UOM';
  static const labelHeight = 'Height';
  static const labelWidth = 'Width';
  static const labelDepth = 'Depth';
  static const labelDimensionUom = 'Dimension UOM';

  // --- Marketing authorization (bound group) ---
  static const sectionMarketingAuthorization = 'Marketing Authorization';
  static const labelMarketingAuthorizationNumber =
      'Marketing Authorization Number';
  static const helperMarketingAuthorizationNumber =
      'Regulator-issued; market-specific format (max 50 characters)';
  static const labelAuthorizationValidityFromDate =
      'Authorization Validity From Date';
  static const labelAuthorizationValidityToDate =
      'Authorization Validity To Date';

  // --- Audit ---
  static const sectionAudit = 'Audit';
  static const labelCreatedBy = 'Created By';
  static const labelUpdatedBy = 'Updated By';
}
