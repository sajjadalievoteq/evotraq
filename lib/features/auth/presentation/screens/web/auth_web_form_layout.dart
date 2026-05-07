import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/trace_network_background.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_surface_card.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/branding_widget.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

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
    final t = context.text;

    Widget buildSurface(Widget content) {
      return wrapInCard ? AuthSurfaceCard(child: content) : content;
    }

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
                  const Positioned.fill(
                    child: TraceNetworkBackground(density: 1.0),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: c.background.withOpacity(0.06),
                    ),
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
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: largeFormMaxWidth),
                  child: Padding(
                    padding: context.padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              header.eyebrow,
                              style: t.body
                                  .copyWith(color: c.textMuted, fontSize: 12),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              header.title,
                              style: t.body.copyWith(
                                color: c.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              header.subtitle,
                              style: t.body
                                  .copyWith(color: c.textMuted, fontSize: 12),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        buildSurface(child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
