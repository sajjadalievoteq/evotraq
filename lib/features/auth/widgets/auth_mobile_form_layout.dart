import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_branding_section.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_panel.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_mobile_scroll_body.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_standards_footer.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';

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
    final maxWidth = smallMaxWidth < layout.maxContentWidth
        ? smallMaxWidth
        : layout.maxContentWidth;

    return CardWithBackgroundWidget(
      isPrimary: false,
      margin: EdgeInsets.zero,
      child: SafeArea(
        child: AuthMobileScrollBody(
          layout: layout,
          maxWidth: maxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showBrandingOnSmall) ...[
                AuthBrandingSection(
                  layout: layout,
                  primary: c.primary,
                  textSecondary: c.textMuted,
                ),
                const SizedBox(height: TraqSpacing.lg),
                Divider(height: 1, thickness: 1, color: c.border),
                const SizedBox(height: TraqSpacing.lg),
              ],
              AuthFormPanel(
                header: header,
                wrapInCard: wrapInCard,
                compactHeader: true,
                child: child,
              ),
              const SizedBox(height: TraqSpacing.xl),
              AuthStandardsFooter(
                muted: c.textMuted,
                style: t.mono.copyWith(
                  color: c.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
