import 'dart:html' as html;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';

const String _frontendBaseUrl = String.fromEnvironment(
  'FRONTEND_BASE_URL',
  defaultValue: '',
);

bool _isStagingHost(String host) {
  return host == 'localhost' ||
      host == '127.0.0.1' ||
      host.contains('azurestaticapps.net');
}

void goToLogin(BuildContext context) {
  final canonical = _frontendBaseUrl.trim();
  final host = Uri.base.host;

  if (canonical.isNotEmpty && _isStagingHost(host)) {
    final loginUri = Uri.parse(canonical).replace(path: Constants.loginRoute);
    html.window.location.assign(loginUri.toString());
    return;
  }

  context.go(Constants.loginRoute);
}
