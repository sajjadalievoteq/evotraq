import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

abstract final class CancelShippingUiConstants {
  static const String operationLabel = 'Cancel Shipping';
  static const String gs1BizStep = 'void_shipping';

  static const entityPluralOperations = 'cancel shipping';
  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;
  static const filterAll = 'ALL';

  static const listSearchHint =
      'Search by reference, GINC, cancel reason, source, destination...';

  static const quickFiltersTitle = 'Quick Filters';
  static const advancedFiltersTitle = 'Advanced Filters';
  static const filterSectionStatus = 'Status';

  static const buttonApply = 'Apply';
  static const buttonCancel = 'Cancel';
  static const buttonClearFilters = 'Clear Filters';

  static const quickFiltersFooterHint =
      'Status filters apply to loaded results. Use Advanced Filters for GINC and sort options.';

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
    'cancelShippingReference': 'Reference',
    'sourceGLN': 'Ship From GLN',
    'destinationGLN': 'Ship To GLN',
    'status': 'Status',
    'cancelledEpcsCount': 'Cancelled EPCs',
  };

  static String sortByLine(String fieldLabel, String orderSpan) =>
      'Sort by $fieldLabel ($orderSpan)';
}
