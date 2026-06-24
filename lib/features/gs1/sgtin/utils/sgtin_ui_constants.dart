import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

abstract final class SgtinUiConstants {
  static const filterAll = 'All';
  static const sortNewestLabel = 'Newest First';
  static const sortOldestLabel = 'Oldest First';

  static const List<String> statusOptions = [
    filterAll,
    'COMMISSIONED',
    'PACKED',
    'SHIPPED',
    'IN_TRANSIT',
    'RECEIVED',
    'DISPENSED',
    'DAMAGED',
    'RECALLED',
    'DECOMMISSIONED',
  ];

  static const List<String> sortFieldOptions = [
    'createdAt',
    'serialNumber',
    'gtinCode',
    'batchLotNumber',
    'expiryDate',
  ];

  static const Map<String, String> sortFieldLabels = {
    'createdAt': 'Date Created',
    'serialNumber': 'Serial Number',
    'gtinCode': 'GTIN Code',
    'batchLotNumber': 'Batch/Lot',
    'expiryDate': 'Expiry Date',
  };

  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;

  static const String listSearchHint =
      'Search by serial number, GTIN, or batch/lot...';

  static const appBarManagement = 'SGTIN Management';
  static const fabAddNew = 'Add New SGTIN';
  static const fabCloseCreate = 'Close create form';
  static const emptyNoMatchSearch = 'No SGTINs match your search.';
  static const emptyListTitle = 'No SGTINs found';
  static const entityPluralSgtins = 'SGTINs';

  static const listCardSerialPrefix = 'Serial: ';
  static const listCardGtinPrefix = 'GTIN: ';
  static const listCardBatchPrefix = 'Batch/Lot: ';
  static const listCardExpiryPrefix = 'Expiry: ';
  static const listCardLocationPrefix = 'Location: ';

  static const splitCreateHeader = 'Create SGTIN';
  static const tooltipClose = 'Close';

  static const dialogAdvancedFiltersTitle = 'Advanced Filters';
  static const buttonClose = 'Close';
  static const buttonCancel = 'Cancel';
  static const buttonApply = 'Apply';
  static const buttonApplyFilters = 'Apply Filters';
  static const buttonClearAll = 'Clear All';
  static const buttonClearFilters = 'Clear Filters';

  static const advancedFiltersHeader = 'Advanced Filters (Database Filters)';
  static const advancedFiltersNote =
      'Note: These filters are applied at database level for precise results';

  static const quickFiltersTitle = 'Quick Filters';
  static const filterSectionStatus = 'Status';
  static const filterSectionGtin = 'GTIN Code';
  static const quickFiltersFooterHint =
      'For more advanced filters, use the "Show Advanced Filters" option below the search bar.';

  static const labelSerialNumberField = 'Serial Number';
  static const labelGtinCodeField = 'GTIN Code';
  static const labelBatchLotField = 'Batch/Lot Number';
  static const labelStatusField = 'Status';
  static const labelSortByField = 'Sort By';

  static const detailTitleView = 'SGTIN Details';
  static const detailTitleEdit = 'Edit SGTIN';
  static const detailTitleCreate = 'Create SGTIN';
  static const submitUpdateSgtin = 'Update SGTIN';
  static const submitCreateSgtin = 'Create SGTIN';

  static const awaitingSelectionTitle = 'Select an SGTIN';
  static const awaitingSelectionSubtitle =
      'Select an SGTIN from the list to view its details.';

  static String successSgtinUpdated(String serial) =>
      'SGTIN $serial updated successfully';
  static String successSgtinCreated(String serial) =>
      'SGTIN $serial created successfully';

  static String chipStatus(String value) => 'Status: $value';
  static String chipGtin(String value) => 'GTIN: $value';

  static String sortByLine(String field, String order) =>
      'Sort by $field ($order)';
  static const sortFieldFallback = 'Date Created';
}
