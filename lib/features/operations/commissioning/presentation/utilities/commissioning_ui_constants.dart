/// UI copy and filter options for commissioning list screens.
abstract final class CommissioningUiConstants {
  static const filterAll = 'ALL';

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

  /// Maps [filterAll] + [CommissioningBatchStatus.name] values.
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
}
