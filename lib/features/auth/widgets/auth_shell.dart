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

/// Persistent auth chrome: left branding stays mounted across auth routes.
///
/// [child] is go_router's ShellRoute [Navigator] (GlobalKey'd). It must be
/// rendered directly — never inside [AnimatedSwitcher] / keyed swap — or the
/// navigator is duplicated/reparented mid-layout and throws relayout assertions.
/// Form swap motion belongs on the route page ([TraqRouterTransitions.authShellPage]).
///
/// Branding entrance is owned by [TraqStaggeredEntrance] State (once per mount);
/// do not latch [playEntrance] here — auth rebuilds would skip the animation.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return AuthShellScope(
      location: location,
      child: BackgroundContainerWidget(
        child: AppLayoutBuilder(
          builder: (context, layout) {
            if (layout.isLarge) {
              return _AuthShellDesktop(layout: layout, child: child);
            }
            return _AuthShellMobile(layout: layout, child: child);
          },
        ),
      ),
    );
  }
}

class _AuthShellDesktop extends StatelessWidget {
  const _AuthShellDesktop({
    required this.layout,
    required this.child,
  });

  final AppLayoutData layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SizedBox(
      width: layout.width,
      height: layout.height,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: ClipRect(
              child: Container(
                color: c.background,
                child: Stack(
                  children: [
                    Positioned.fill(child: Container(color: c.background)),
                    Container(
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssets.traqBackgroundPng),
                          fit: BoxFit.cover,
                          opacity: 0.2,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                    Padding(
                      padding: context.padding,
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
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
          ),
          const Divider(),
          Expanded(
            flex: 3,
            child: Container(
              color: c.surface,
              child: SafeArea(child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthShellMobile extends StatelessWidget {
  const _AuthShellMobile({
    required this.layout,
    required this.child,
  });

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
    );
  }
}
