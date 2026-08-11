import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell_scope.dart';
import 'package:traqtrace_app/features/auth/widgets/branding_widget.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';

class AuthShellDesktop extends StatelessWidget {
  const AuthShellDesktop({required this.layout, required this.child});

  final AppLayoutData layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SizedBox(
      width: layout.width,
      height: layout.height,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: ClipRect(
              child: Container(
                color: c.background,
                child: Stack(
                  children: [
                    Positioned.fill(child: Container(color: c.background)),
                    Container(
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssets.traqBackgroundPng),
                          fit: BoxFit.cover,
                          opacity: 0.2,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                    Padding(
                      padding: context.padding,
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: AuthBrandingSection(
                          layout: layout,
                          primary: c.primary,
                          textSecondary: c.textMuted,
                          prominent: true,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            flex: 3,
            child: Container(
              color: c.surface,
              child: SafeArea(child: child),
            ),
          ),
        ],
      ),
    );
  }
}
