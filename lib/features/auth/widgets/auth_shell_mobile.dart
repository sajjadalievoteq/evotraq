import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_branding_section.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_mobile_scroll_body.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_standards_footer.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';

class AuthShellMobile extends StatelessWidget {
  const AuthShellMobile({super.key, required this.layout, required this.child});

  final AppLayoutData layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    return CardWithBackgroundWidget(
      isPrimary: false,
      margin: EdgeInsets.zero,
      child: SafeArea(
        child: AuthMobileScrollBody(
          layout: layout,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthBrandingSection(
                layout: layout,
                primary: c.primary,
                textSecondary: c.textMuted,
              ),
              const SizedBox(height: TraqSpacing.lg),


              child,
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
