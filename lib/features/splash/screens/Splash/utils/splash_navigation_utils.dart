import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';

/// Resolves a post-splash redirect from the `from` query parameter.
String? resolveSplashPendingLocation(BuildContext context) {
  final from = GoRouterState.of(context).uri.queryParameters['from'];
  if (from == null || from.isEmpty || from == Constants.splashRoute) {
    return null;
  }

  final parsed = Uri.tryParse(from);
  if (parsed == null || parsed.path == Constants.splashRoute) {
    return null;
  }

  return parsed.toString();
}
