/// GoRouter paths for SSCC master-data screens.
abstract final class SsccRouteConstants {
  static const String base = '/gs1/ssccs';
  static const String newSscc = '$base/new';
  static const String detail = '$base/:ssccId';
  static const String edit = '$base/:ssccId/edit';

  /// [GoRoute.pathParameters] key used by [detail] and [edit].
  static const String pathParamSsccId = 'ssccId';

  /// Path when the logistic unit is addressed by **SSCC code** (18 digits).
  static String pathForSsccCode(String ssccCode) => '$base/$ssccCode';

  static String pathForSsccCodeEdit(String ssccCode) => '$base/$ssccCode/edit';
}
