import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

String resolvePlatformStartupRoute() {
  if (kIsWeb) {
    final browserLocation = _browserRouteLocation();
    if (browserLocation != null) return browserLocation;
  }
  return Constants.splashRoute;
}

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