import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

/// Shared UI constants for all operation list and filter screens.
abstract final class OperationUiConstants {
  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;
  static const String filterAll = 'ALL';

  static const String quickFiltersTitle = 'Quick Filters';
  static const String advancedFiltersTitle = 'Advanced Filters';
  static const String filterSectionStatus = 'Status';

  static const String buttonApply = 'Apply';
  static const String buttonCancel = 'Cancel';
  static const String buttonClearFilters = 'Clear Filters';

  static const String sortAscendingLabel = 'Oldest';
  static const String sortDescendingLabel = 'Newest';
  static const String sortFieldFallback = 'date processed';
  static const String labelSortResultsBy = 'Sort results by';

  static const List<String> standardStatusFilterOptions = <String>[
    filterAll,
    'success',
    'partialSuccess',
    'failed',
    'validationError',
  ];

  static String standardStatusFilterLabel(String value) {
    return switch (value) {
      filterAll => 'All',
      'success' => 'Success',
      'partialSuccess' => 'Partial',
      'failed' => 'Failed',
      'validationError' => 'Validation Error',
      _ => value,
    };
  }

  static String sortByLine(String fieldLabel, String orderSpan) =>
      'Sort by $fieldLabel ($orderSpan)';
}
