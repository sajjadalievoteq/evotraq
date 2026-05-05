import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/trace_network_background.dart';
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
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.bg1,
        borderRadius: EvotraqRadius.card,
        border: Border.all(color: c.line1),
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
    final c = context.colors;
    final t = context.text;


    Widget buildSurface(Widget content) {
      return wrapInCard ? AuthSurfaceCard(child: content) : content;
    }

    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isLarge) {
          // IMPORTANT: don't wrap desktop auth in scroll views / padded shells.
          // We want the split panels to take the full viewport height.
          return SizedBox(
            width: layout.width,
            height: layout.height,
            child: Row(
              children: [
                // Left hero panel (animated trace network)
                Expanded(
                  flex: 5,
                  child: Container(
                    color: c.bg0,
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: TraceNetworkBackground(density: 1.0),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: c.bg0.withOpacity(0.06),
                          ),
                        ),
                        Padding(
                          padding: context.padding,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AuthBrandingSection(
                              layout: layout,
                              primary: c.sig,
                              textSecondary: c.fg2,
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
                // Right auth form panel
                Divider(),
                Expanded(
                  flex: 3,
                  child: Container(
                    color: c.bg1,
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: largeFormMaxWidth),
                        child: Padding(
                          padding:  context.padding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 2,
                                children: [
                                  Text(
                                    'SYSTEM ACCESS',
                                    style: t.body.copyWith(color: c.fg2,fontSize: 12),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    'Sign in',
                                    style:  t.body.copyWith(color: c.fg0,fontSize: 26,fontWeight: FontWeight.bold),),

                                  Text(
                                    'Welcome back. Continue to your operations console',
                                    style: t.body.copyWith(color: c.fg2,fontSize: 12),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              SizedBox(height: 40,),
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

        // Smaller screens: allow scroll, keep safe area.
        return SafeArea(
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
                          primary: c.sig,
                          textSecondary: c.fg2,
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
                            'SYSTEM ACCESS',
                            style: t.body.copyWith(color: c.fg2,fontSize: 12),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            'Sign in',
                            style:  t.body.copyWith(color: c.fg0,fontSize: 26,fontWeight: FontWeight.bold),),

                          Text(
                            'Welcome back. Continue to your operations console',
                            style: t.body.copyWith(color: c.fg2,fontSize: 12),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      buildSurface(child),
                      SizedBox(height: 40,),
                      layout.isCompact || layout.isTabletUp ? Row
                        (
                        spacing: 20,
                        children: [
                          Text(
                            "GS1 EPCIS 2.0",
                            style: t.body.copyWith(color: c.fg2),
                          ),
                          Container(height: 5,width: 5,
                            decoration: BoxDecoration(
                              color: c.fg2,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            "CBV 2.0",
                            style: t.body.copyWith(color: c.fg2),
                          ),
                          Container(height: 5,width: 5,
                            decoration: BoxDecoration(
                              color: c.fg2,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            "DSCSA • EU FMD",
                            style: t.body.copyWith(color: c.fg2),


                          ),
                        ],
                      )
:SizedBox.shrink()
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
