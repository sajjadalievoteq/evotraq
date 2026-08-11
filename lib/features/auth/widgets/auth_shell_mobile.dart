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
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.padding.bottom,
            0,
            context.padding.bottom,
            context.padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthBrandingSection(
                layout: layout,
                primary: c.primary,
                textSecondary: c.textMuted,
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
      ),
    );
  }
}
