import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_branding_section.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';

class AuthShellMobile extends StatelessWidget {
  const AuthShellMobile({required this.layout, required this.child});

  final AppLayoutData layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    return CardWithBackgroundWidget(
      isPrimary: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:  EdgeInsets.all(context.padding.bottom,),
              child: AuthBrandingSection(
                layout: layout,
                primary: c.primary,
                textSecondary: c.textMuted,
              ),
            ),
            Expanded(child: child),
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
                  Text('CBV 2.0', style: t.body.copyWith(color: c.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
