import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_panel.dart';
import 'package:traqtrace_app/features/auth/widgets/branding_widget.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

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

    return CardWithBackgroundWidget(
      isPrimary: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: smallMaxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.padding.bottom,
                0,
                context.padding.bottom,
                context.padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBrandingOnSmall)
                    AuthBrandingSection(
                      layout: layout,
                      primary: c.primary,
                      textSecondary: c.textMuted,
                    ),
                  AuthFormPanel(
                    header: header,
                    wrapInCard: wrapInCard,
                    compactHeader: true,
                    child: child,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'GS1 EPCIS 2.0',
                          style: t.body.copyWith(color: c.textMuted),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            color: c.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'CBV 2.0',
                          style: t.body.copyWith(color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
