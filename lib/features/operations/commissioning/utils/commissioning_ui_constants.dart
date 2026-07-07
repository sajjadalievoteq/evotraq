import 'package:traqtrace_app/features/operations/shared/utils/operation_ui_constants.dart';

abstract final class CommissioningUiConstants {
  static const entityPluralOperations = 'operations';
  static const listSearchHint =
      'Search by reference, GTIN, lot number, location...';
  static const quickFiltersFooterHint =
      'Status filters apply to loaded results. Use Advanced Filters to filter by GTIN on the server.';

  static const List<int> pageSizeOptions = OperationUiConstants.pageSizeOptions;
  static const filterAll = OperationUiConstants.filterAll;

  static const quickFiltersTitle = OperationUiConstants.quickFiltersTitle;
  static const advancedFiltersTitle = OperationUiConstants.advancedFiltersTitle;
  static const filterSectionStatus = OperationUiConstants.filterSectionStatus;

  static const buttonApply = OperationUiConstants.buttonApply;
  static const buttonCancel = OperationUiConstants.buttonCancel;
  static const buttonClearFilters = OperationUiConstants.buttonClearFilters;

  static const statusFilterOptions = <String>[
    filterAll,
    'success',
    'partialSuccess',
    'failed',
    'pending',
    'inProgress',
  ];

  static String statusFilterLabel(String value) {
    return switch (value) {
      filterAll => 'All',
      'success' => 'Success',
      'partialSuccess' => 'Partial',
      'failed' => 'Failed',
      'pending' => 'Pending',
      'inProgress' => 'In Progress',
      _ => value,
    };
  }

  static const sortAscendingLabel = OperationUiConstants.sortAscendingLabel;
  static const sortDescendingLabel = OperationUiConstants.sortDescendingLabel;
  static const sortFieldFallback = 'date created';
  static const labelSortResultsBy = OperationUiConstants.labelSortResultsBy;

  static const Map<String, String> sortFieldLabels = {
    'createdAt': 'Date Created',
    'batchLotNumber': 'Batch/Lot',
    'gtinCode': 'GTIN',
    'commissioningReference': 'Reference',
    'status': 'Status',
  };

  static String sortByLine(String fieldLabel, String orderSpan) =>
      OperationUiConstants.sortByLine(fieldLabel, orderSpan);
}
