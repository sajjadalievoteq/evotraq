import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_surface_card.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/branding_widget.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

class AuthMobileFormLayout extends StatelessWidget {
  const AuthMobileFormLayout({
    super.key,
    required this.layout,
    required this.header,
    required this.child,
    this.smallMaxWidth = 600,
    this.showBrandingOnSmall = true,
    this.wrapInCard = true,
  });

  final AppLayoutData layout;
  final AuthFormHeader header;
  final Widget child;
  final double smallMaxWidth;
  final bool showBrandingOnSmall;
  final bool wrapInCard;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    Widget buildSurface(Widget content) {
      return wrapInCard ? AuthSurfaceCard(child: content) : content;
    }

    return CardWithBackgroundWidget(
      isPrimary: false,
      child: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: smallMaxWidth),
              child: Padding(
                padding: context.padding,
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
                        primary: c.primary,
                        textSecondary: c.textMuted,
                      ),
                      SizedBox(
                        height: layout.resolve(
                          compact: 40.0,
                          medium: 44.0,
                          expanded: 48.0,
                        ),
                      ),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          header.eyebrow,
                          style: t.body.copyWith(
                            color: c.textMuted,
                            fontSize: 12,
                          ),
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
                          style: t.body.copyWith(
                            color: c.textMuted,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    buildSurface(child),
                    const SizedBox(height: 40),
                    layout.isCompact || layout.isTabletUp
                        ? Row(
                            spacing: 20,
                            children: [
                              Text(
                                'GS1 EPCIS 2.0',
                                style: t.body.copyWith(color: c.textMuted),
                              ),
                              Container(
                                height: 5,
                                width: 5,
                                decoration: BoxDecoration(
                                  color: c.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                'CBV 2.0',
                                style: t.body.copyWith(color: c.textMuted),
                              ),
                              Container(
                                height: 5,
                                width: 5,
                                decoration: BoxDecoration(
                                  color: c.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                'DSCSA • EU FMD',
                                style: t.body.copyWith(color: c.textMuted),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
