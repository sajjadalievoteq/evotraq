/// Master-data API paths and defaults used by [GTINService].
abstract final class GtinApiConsts {
  // paths
  static const String masterDataGtinsPath = '/master-data/gtins';
  static const String deriveIdentificationPath = '/derive-identification';

  // defaults (sorting / filtering)
  static const String defaultSortBy = 'productName';
  static const String defaultSortDirection = 'ASC';
  static const String allFilterSentinel = 'All';
}
