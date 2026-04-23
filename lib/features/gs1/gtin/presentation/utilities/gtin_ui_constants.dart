/// Filter, sort, and pagination options shared by GTIN list UI.
abstract final class GtinUiConstants {
  static const List<String> statusOptions = [
    'All',
    'Active',
    'Withdrawn',
    'Suspended',
    'Discontinued',
  ];

  static const List<String> packagingLevelOptions = [
    'All',
    'ITEM',
    'INNER_PACK',
    'PACK',
    'CASE',
    'PALLET',
  ];

  /// Packaging levels for forms (no "All" sentinel).
  static const List<String> packagingLevelValues = [
    'ITEM',
    'INNER_PACK',
    'PACK',
    'CASE',
    'PALLET',
  ];

  static const List<int> pageSizeOptions = [10, 25, 50, 100];
}
