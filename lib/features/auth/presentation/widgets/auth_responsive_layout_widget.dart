import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

import 'branding_widget.dart';

class AuthSurfaceCard extends StatelessWidget {
  const AuthSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.92 : 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}



class AuthResponsiveFormLayout extends StatelessWidget {
  const AuthResponsiveFormLayout({
    super.key,
    required this.child,
    this.smallMaxWidth = 600,
    this.largeFormMaxWidth = 520,
    this.showBrandingOnSmall = true,
    this.wrapInCard = true,
    this.gap = 48,
  });

  final Widget child;
  final double smallMaxWidth;
  final double largeFormMaxWidth;
  final bool showBrandingOnSmall;
  final bool wrapInCard;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget buildSurface(Widget content) {
      return wrapInCard ? AuthSurfaceCard(child: content) : content;
    }

    return AppResponsiveBody.builder(
      builder: (context, layout) {
        if (layout.isLarge) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 200),
            height: layout.height - (layout.verticalPadding * 2),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: AuthBrandingSection(
                          layout: layout,
                          primary: primary,
                          textSecondary: textSecondary,
                          prominent: true,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: largeFormMaxWidth),
                        child: buildSurface(child),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: smallMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: layout.resolve(
                    compact: 40.0,
                    medium: 48.0,
                    expanded: 56.0,
                  ),
                ),
                if (showBrandingOnSmall) ...[
                  AuthBrandingSection(
                    layout: layout,
                    primary: primary,
                    textSecondary: textSecondary,
                  ),
                  SizedBox(
                    height: layout.resolve(
                      compact: 40.0,
                      medium: 44.0,
                      expanded: 48.0,
                    ),
                  ),
                ],
                buildSurface(child),
              ],
            ),
          ),
        );
      },
    );
  }
}
