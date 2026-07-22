import 'package:traqtrace_app/core/config/constants.dart';



String? resolvePendingLocationFrom(String? location) {
  if (location == null || location.isEmpty) return null;

  final uri = Uri.parse(location);
  final path = uri.path;

  if (path == Constants.splashRoute) return null;
  if (path == Constants.loginRoute) return null;
  if (path == Constants.registerRoute) return null;
  if (path == Constants.forgotPasswordRoute) return null;
  if (path == Constants.checkEmailRoute) return null;
  if (path == Constants.authResetPasswordRoute) return null;
  if (path == Constants.resetPasswordRoute) return null;
  if (path == Constants.verifyEmailRoute) return null;
  if (path == Constants.verifyEmailAliasRoute) return null;

  return location;
}


String? resolveSplashPendingLocationFrom(String? location) {
  if (location == null || location.isEmpty) return null;
  final uri = Uri.parse(location);
  if (uri.path == Constants.splashRoute) return null;
  return location;
}


String splashLocationWithFrom(String? from) {
  final target = resolvePendingLocationFrom(from);
  if (target == null) return Constants.splashRoute;

  return Uri(
    path: Constants.splashRoute,
    queryParameters: {'from': target},
  ).toString();
}


String loginLocationWithFrom(String? from) {
  final target = resolvePendingLocationFrom(from);
  if (target == null) return Constants.loginRoute;

  return Uri(
    path: Constants.loginRoute,
    queryParameters: {'from': target},
  ).toString();
}
