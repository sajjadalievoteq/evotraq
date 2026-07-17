import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_panel.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_mobile_form_layout.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell_scope.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_web_form_layout.dart';

class AuthResponsiveFormLayout extends StatelessWidget {
  const AuthResponsiveFormLayout({
    super.key,
    required this.header,
    required this.child,
    this.smallMaxWidth = 600,
    this.largeFormMaxWidth = 520,
    this.showBrandingOnSmall = true,
    this.wrapInCard = true,
    this.gap = 48,
  });

  final AuthFormHeader header;
  final Widget child;
  final double smallMaxWidth;
  final double largeFormMaxWidth;
  final bool showBrandingOnSmall;
  final bool wrapInCard;
  final double gap;

  @override
  Widget build(BuildContext context) {
    // Inside AuthShell the left branding is persistent — only render the form.
    if (AuthShellScope.isActive(context)) {
      return AppLayoutBuilder(
        builder: (context, layout) {
          return AuthFormPanel(
            header: header,
            wrapInCard: wrapInCard,
            compactHeader: !layout.isLarge,
            child: child,
          );
        },
      );
    }

    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isLarge) {
          return AuthWebFormLayout(
            layout: layout,
            header: header,
            child: child,
            largeFormMaxWidth: largeFormMaxWidth,
            wrapInCard: wrapInCard,
          );
        }

        return AuthMobileFormLayout(
          layout: layout,
          header: header,
          child: child,
          smallMaxWidth: smallMaxWidth,
          showBrandingOnSmall: showBrandingOnSmall,
          wrapInCard: wrapInCard,
        );
      },
    );
  }
}
