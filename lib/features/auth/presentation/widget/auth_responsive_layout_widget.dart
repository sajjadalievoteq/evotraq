import 'package:flutter/material.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

import 'auth_form_header.dart';
import '../screens/mobile/auth_mobile_form_layout.dart';
import '../screens/web/auth_web_form_layout.dart';

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
