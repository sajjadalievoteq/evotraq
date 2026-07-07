import 'package:traqtrace_app/features/operations/shared/utils/operation_ui_constants.dart';

abstract final class ReturnReceivingUiConstants {
  static const entityPluralOperations = 'ReturnReceiving operations';
  static const listSearchHint =
      'Search by reference, source GLN, or receiving GLN…';
  static const quickFiltersFooterHint =
      'Status filters apply to loaded results. Use Advanced Filters for tracking and sort options.';

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
    'returnReceivingReference': 'Reference',
    'sourceGLN': 'Returned From GLN',
    'receivingGLN': 'ReturnReceiving GLN',
    'status': 'Status',
    'processedEpcsCount': 'Received EPCs',
  };

  static String sortByLine(String fieldLabel, String orderSpan) =>
      OperationUiConstants.sortByLine(fieldLabel, orderSpan);
}
