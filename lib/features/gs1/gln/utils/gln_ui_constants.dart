import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

/// Filter, sort, and pagination options shared by GLN list UI (parallel to GTIN).
abstract final class GlnUiConstants {
  static const List<String> statusOptions = ['All', 'Active', 'Inactive'];

  static const List<String> locationTypeOptions = [
    'All',
    'Manufacturing Site',
    'Warehouse',
    'Distribution Center',
    'Pharmacy',
    'Hospital',
    'Wholesaler',
    'Clinic',
    'Regulatory Body',
    'Other',
  ];

  static const List<int> pageSizeOptions = Gs1ListPageSizes.defaults;

  static const String listSearchHint =
      'Search by GLN code, location name, address, or contact info...';

  /// API [sortBy] values → short labels for the sort row.
  static const Map<String, String> sortFieldLabels = {
    'locationName': 'location name',
    'glnCode': 'GLN code',
    'addressLine1': 'address',
    'city': 'city',
    'licenseNumber': 'license number',
  };
}
