abstract final class GlnRouteConstants {
  static const String base = '/gs1/glns';
  static const String newGln = '$base/new';
  static const String detail = '$base/:glnId';
  static const String edit = '$base/:glnId/edit';

  static const String pathParamGlnId = 'glnId';

  static String pathForGlnCode(String glnCode) => '$base/$glnCode';

  static String pathForGlnCodeEdit(String glnCode) => '$base/$glnCode/edit';
}
