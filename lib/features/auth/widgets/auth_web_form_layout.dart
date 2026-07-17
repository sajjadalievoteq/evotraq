import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_panel.dart';
import 'package:traqtrace_app/features/auth/widgets/branding_widget.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

class AuthWebFormLayout extends StatelessWidget {
  const AuthWebFormLayout({
    super.key,
    required this.layout,
    required this.header,
    required this.child,
    this.largeFormMaxWidth = 520,
    this.wrapInCard = true,
  });

  final AppLayoutData layout;
  final AuthFormHeader header;
  final Widget child;
  final double largeFormMaxWidth;
  final bool wrapInCard;

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
                    child: Align(
                      alignment: Alignment.centerLeft,
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
          const Divider(),
          Expanded(
            flex: 3,
            child: Container(
              color: c.surface,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: context.padding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: largeFormMaxWidth,
                            minHeight:
                                constraints.maxHeight -
                                context.padding.vertical,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AuthFormPanel(
                                header: header,
                                wrapInCard: wrapInCard,
                                child: child,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
