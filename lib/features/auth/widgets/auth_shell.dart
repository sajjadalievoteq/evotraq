import 'package:traqtrace_app/core/layout/app_layout_builder.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell_scope.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell_desktop.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell_mobile.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return AuthShellScope(
      location: location,
      child: BackgroundContainerWidget(
        child: AppLayoutBuilder(
          builder: (context, layout) {
            if (layout.isLarge) {
              return AuthShellDesktop(layout: layout, child: child);
            }
            return AuthShellMobile(layout: layout, child: child);
          },
        ),
      ),
    );
  }
}
