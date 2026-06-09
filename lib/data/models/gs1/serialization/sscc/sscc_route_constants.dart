abstract final class SsccRouteConstants {
  static const String base = '/gs1/ssccs';
  static const String newSscc = '$base/new';
  static const String detail = '$base/:ssccId';
  static const String edit = '$base/:ssccId/edit';

  static const String pathParamSsccId = 'ssccId';

  static String pathForSsccCode(String ssccCode) => '$base/$ssccCode';

  static String pathForSsccCodeEdit(String ssccCode) => '$base/$ssccCode/edit';
}
