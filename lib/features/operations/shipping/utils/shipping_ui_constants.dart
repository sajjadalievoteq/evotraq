import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

abstract final class ShippingUiConstants {
  static const entityPluralOperations = 'shipping operations';
  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;
  static const filterAll = 'ALL';

  static const listSearchHint =
      'Search by reference, source, destination, tracking...';

  static const quickFiltersTitle = 'Quick Filters';
  static const advancedFiltersTitle = 'Advanced Filters';
  static const filterSectionStatus = 'Status';

  static const buttonApply = 'Apply';
  static const buttonCancel = 'Cancel';
  static const buttonClearFilters = 'Clear Filters';

  static const quickFiltersFooterHint =
      'Status filters apply to loaded results. Use Advanced Filters for tracking and sort options.';

  static const statusFilterOptions = <String>[
    filterAll,
    'success',
    'partialSuccess',
    'failed',
    'validationError',
  ];

  static String statusFilterLabel(String value) {
    return switch (value) {
      filterAll => 'All',
      'success' => 'Success',
      'partialSuccess' => 'Partial',
      'failed' => 'Failed',
      'validationError' => 'Validation Error',
      _ => value,
    };
  }

  static const sortAscendingLabel = 'Oldest';
  static const sortDescendingLabel = 'Newest';
  static const sortFieldFallback = 'date processed';
  static const labelSortResultsBy = 'Sort results by';

  static const Map<String, String> sortFieldLabels = {
    'processedAt': 'Date Processed',
    'shippingReference': 'Reference',
    'sourceGLN': 'Ship From GLN',
    'destinationGLN': 'Ship To GLN',
    'status': 'Status',
    'shippedEpcsCount': 'Shipped EPCs',
  };

  static String sortByLine(String fieldLabel, String orderSpan) =>
      'Sort by $fieldLabel ($orderSpan)';
}
