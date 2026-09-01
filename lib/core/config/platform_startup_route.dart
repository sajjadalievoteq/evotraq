import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

/// Resolves the route GoRouter should open on cold start / reload.
///
/// On web, [Uri.base] is the source of truth so reload keeps the address-bar
/// path. When the platform reports `/` (common while a temporary [MaterialApp]
/// is mounted before [GoRouter]), go_router falls back to [initialLocation] —
/// so we must seed it from the browser URL, not always `/splash`.
String resolvePlatformStartupRoute() {
  if (kIsWeb) {
    final browserLocation = _browserRouteLocation();
    if (browserLocation != null) return browserLocation;
  }
  return Constants.splashRoute;
}

/// Maps the captured startup URL to [GoRouter.initialLocation].
///
/// Branding runs in [SplashScreen] before the router mounts; seeding
/// [GoRouter] at `/splash` would remount a second splash route.
String resolveRouterInitialLocation(String startupRoute) {
  final uri = Uri.parse(
    startupRoute.startsWith('/') ? startupRoute : '/$startupRoute',
  );
  final path = uri.path;
  if (path.isEmpty || path == '/' || path == Constants.splashRoute) {
    return '/';
  }
  return uri.toString();
}

String? _browserRouteLocation() {
  final uri = Uri.base;
  var path = uri.path;
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  if (path.isEmpty || path == '/') return null;

  return Uri(
    path: path,
    queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
  ).toString();
}
