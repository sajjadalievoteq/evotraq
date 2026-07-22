import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell_scope.dart';



class AuthScreenHost extends StatelessWidget {
  const AuthScreenHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AuthShellScope.isActive(context)) {
      return child;
    }
    return BackgroundContainerWidget(child: child);
  }
}
