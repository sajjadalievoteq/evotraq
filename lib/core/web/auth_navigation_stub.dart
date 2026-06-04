import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';

/// Navigates to the login screen (non-web platforms).
void goToLogin(BuildContext context) {
  context.go(Constants.loginRoute);
}
