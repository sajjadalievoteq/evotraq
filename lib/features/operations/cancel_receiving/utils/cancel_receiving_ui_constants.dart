import 'package:traqtrace_app/features/operations/shared/utils/operation_ui_constants.dart';

abstract final class CancelReceivingUiConstants {
  static const String operationLabel = 'Cancel Receiving';
  static const String gs1BizStep = 'void_receiving';

  static const entityPluralOperations = 'cancel receiving';
  static const listSearchHint =
      'Search by reference, GINC, cancel reason, sender, receive-at...';
  static const quickFiltersFooterHint =
      'Status filters apply to loaded results. Use Advanced Filters for GINC and sort options.';

  static const List<int> pageSizeOptions = OperationUiConstants.pageSizeOptions;
  static const filterAll = OperationUiConstants.filterAll;

  static const quickFiltersTitle = OperationUiConstants.quickFiltersTitle;
  static const advancedFiltersTitle = OperationUiConstants.advancedFiltersTitle;
  static const filterSectionStatus = OperationUiConstants.filterSectionStatus;

  static const buttonApply = OperationUiConstants.buttonApply;
  static const buttonCancel = OperationUiConstants.buttonCancel;
  static const buttonClearFilters = OperationUiConstants.buttonClearFilters;

  static const statusFilterOptions =
      OperationUiConstants.standardStatusFilterOptions;
  static String statusFilterLabel(String v) =>
      OperationUiConstants.standardStatusFilterLabel(v);

  static const sortAscendingLabel = OperationUiConstants.sortAscendingLabel;
  static const sortDescendingLabel = OperationUiConstants.sortDescendingLabel;
  static const sortFieldFallback = 'date processed';
  static const labelSortResultsBy = OperationUiConstants.labelSortResultsBy;

  static const Map<String, String> sortFieldLabels = {
    'processedAt': 'Date Processed',
    'cancelReceivingReference': 'Reference',
    'sourceGLN': 'Sender GLN',
    'receivingGLN': 'Receive-At GLN',
    'status': 'Status',
    'cancelledEpcsCount': 'Cancelled EPCs',
  };

  static String sortByLine(String fieldLabel, String orderSpan) =>
      OperationUiConstants.sortByLine(fieldLabel, orderSpan);
}
