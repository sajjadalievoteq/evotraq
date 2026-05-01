import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

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

  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;

  static const String listSearchHint =
      'Search by GTIN code, product name, or manufacturer...';
}
