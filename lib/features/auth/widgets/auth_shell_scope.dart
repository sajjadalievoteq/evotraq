import 'package:flutter/material.dart';

/// Marks the subtree as hosted inside [AuthShell] so screens/layouts
/// render form-only content (left branding stays mounted in the shell).
class AuthShellScope extends InheritedWidget {
  const AuthShellScope({
    super.key,
    required this.location,
    required super.child,
  });

  final String location;

  static AuthShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthShellScope>();
  }

  static bool isActive(BuildContext context) => maybeOf(context) != null;

  @override
  bool updateShouldNotify(AuthShellScope oldWidget) =>
      location != oldWidget.location;
}
