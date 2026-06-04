import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

abstract final class SsccUiConstants {
  static const filterAll = 'All';
  static const sortNewestLabel = 'Newest First';
  static const sortOldestLabel = 'Oldest First';

  static const List<String> statusOptions = [
    filterAll,
    'DRAFT',
    'ALLOCATED',
    'ACTIVE',
    'IN_TRANSIT',
    'RECEIVED',
    'DECOMMISSIONED',
    'VOIDED',
  ];

  static const List<String> containerTypeOptions = [
    'PALLET',
    'CASE',
    'CARTON',
    'TOTE',
    'CONTAINER',
    'DRUM',
    'AIR_ULD',
    'PARCEL',
    'ROLL_CAGE',
    'OTHER',
  ];

  static const List<String> sortFieldOptions = [
    'createdAt',
    'ssccCode',
    'unitType',
    'status',
    'shippingDate',
  ];

  static const Map<String, String> sortFieldLabels = {
    'createdAt': 'Date Created',
    'ssccCode': 'SSCC Code',
    'unitType': 'Unit Type',
    'status': 'Status',
    'shippingDate': 'Shipping Date',
    'containerType': 'Unit Type',
    'containerStatus': 'Status',
  };

  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;

  static const String listSearchHint = 'Search by SSCC code...';

  static const appBarManagement = 'SSCC Management';
  static const fabAddNew = 'Add New SSCC';
  static const fabCloseCreate = 'Close create form';
  static const emptyNoMatchSearch = 'No SSCCs match your search.';
  static const emptyListTitle = 'No SSCCs found';
  static const entityPluralSsccs = 'SSCCs';

  static const listCardTypePrefix = 'Type: ';
  static const listCardStatusPrefix = 'Status: ';
  static const listCardIssuingGlnPrefix = 'Issuing GLN: ';
  static const listCardShippedPrefix = 'Shipped: ';
  static const listCardFromPrefix = 'From: ';
  static const listCardToPrefix = 'To: ';

  static const splitCreateHeader = 'Create SSCC';
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
  static const filterSectionContainerType = 'Container Type';
  static const quickFiltersFooterHint =
      'For more advanced filters, use the "Show Advanced Filters" option below the search bar.';

  static const labelSsccCodeField = 'SSCC Code';
  static const labelContainerTypeField = 'Unit Type';
  static const labelStatusField = 'Status';
  static const labelSourceLocationField = 'Source Location';
  static const labelDestinationLocationField = 'Destination Location';
  static const labelCompanyPrefixField = 'GS1 Company Prefix';
  static const labelExtensionDigitField = 'Extension Digit';
  static const labelIssuingGlnField = 'Issuing GLN';
  static const labelSortByField = 'Sort By';

  static const sortFieldFallback = 'Date Created';

  static const detailCreateTitle = 'Create New SSCC';
  static const detailEditTitle = 'Edit SSCC';
  static const detailViewTitle = 'SSCC Details';
  static const detailAwaitSelection = 'Select an SSCC from the list';
  static const detailSaveButton = 'Save SSCC';
  static const successSsccSaved = 'SSCC saved successfully';
  static const errorGeneric = 'Something went wrong';
  static const errorFixForm = 'Please fix the errors in the form';

  static const menuTooltipActions = 'Actions';
  static const menuViewDetails = 'View details';
  static const menuEdit = 'Edit';
  static const menuDelete = 'Delete';

  static const dialogConfirmDeletionTitle = 'Confirm deletion';
  static const dialogCancel = 'Cancel';
  static const dialogDelete = 'Delete';

  static String deleteSsccConfirm(String ssccCode) =>
      'Delete SSCC $ssccCode? This cannot be undone.';
}
