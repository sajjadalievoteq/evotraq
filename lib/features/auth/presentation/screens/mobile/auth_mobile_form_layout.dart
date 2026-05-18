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
        height:MediaQuery.sizeOf(context).height,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: smallMaxWidth),
            child: Padding(
              padding:EdgeInsetsGeometry.fromLTRB( context.padding.bottom, 0,  context.padding.bottom,  context.padding.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [


                    AuthBrandingSection(
                      layout: layout,
                      primary: c.primary,
                      textSecondary: c.textMuted,
                    ),


                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header.eyebrow,
                        style: t.body.copyWith(
                          color: c.textMuted,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        header.title,
                        style: t.body.copyWith(
                          color: c.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        header.subtitle,
                        style: t.body.copyWith(
                          color: c.textMuted,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 20),
                      buildSurface(child),
                      const SizedBox(height: 20),
                    ],
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
                  )



                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
