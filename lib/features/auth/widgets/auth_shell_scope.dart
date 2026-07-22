import 'package:flutter/material.dart';



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
