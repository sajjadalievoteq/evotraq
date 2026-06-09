import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

abstract final class CommissioningUiConstants {
  static const entityPluralOperations = 'operations';
  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;  static const filterAll = 'ALL';

  static const listSearchHint =
      'Search by reference, GTIN, lot number, location...';

  static const quickFiltersTitle = 'Quick Filters';
  static const advancedFiltersTitle = 'Advanced Filters';
  static const filterSectionStatus = 'Status';

  static const buttonApply = 'Apply';
  static const buttonCancel = 'Cancel';
  static const buttonClearFilters = 'Clear Filters';

  static const quickFiltersFooterHint =
      'Status filters apply to loaded results. Use Advanced Filters to filter by GTIN on the server.';

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

  static const sortAscendingLabel = 'Oldest';
  static const sortDescendingLabel = 'Newest';
  static const sortFieldFallback = 'date created';
  static const labelSortResultsBy = 'Sort results by';

  static const Map<String, String> sortFieldLabels = {
    'createdAt': 'Date Created',
    'batchLotNumber': 'Batch/Lot',
    'gtinCode': 'GTIN',
    'commissioningReference': 'Reference',
    'status': 'Status',
  };

  static String sortByLine(String fieldLabel, String orderSpan) =>
      'Sort by $fieldLabel ($orderSpan)';
}
