/// GoRouter / navigation paths for GLN (master data) screens.
/// Used by [Constants] in [app_consts.dart] for a single source of truth.
abstract final class GlnRouteConstants {
  static const String base = '/gs1/glns';
  static const String newGln = '$base/new';
  static const String detail = '$base/:glnId';
  static const String edit = '$base/:glnId/edit';

  /// [GoRoute.pathParameters] key used by [detail] and [edit].
  static const String pathParamGlnId = 'glnId';

  /// Path for a GLN record when the location is addressed by **code** (list → detail).
  static String pathForGlnCode(String glnCode) => '$base/$glnCode';

  static String pathForGlnCodeEdit(String glnCode) => '$base/$glnCode/edit';
}
