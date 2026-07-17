import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_motion.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell_scope.dart';
import 'package:traqtrace_app/features/auth/widgets/branding_widget.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';

/// Persistent auth chrome: left branding stays mounted; [child] (current form)
/// swaps with a Material shared-axis fade-through + smooth height change.
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
              return _AuthShellDesktop(
                layout: layout,
                location: location,
                child: child,
              );
            }
            return _AuthShellMobile(
              layout: layout,
              location: location,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class _AuthShellDesktop extends StatelessWidget {
  const _AuthShellDesktop({
    required this.layout,
    required this.location,
    required this.child,
  });

  final AppLayoutData layout;
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = AuthMotion.reduceMotion(context);
    final duration = AuthMotion.durationOf(context, AuthMotion.swap);

    return SizedBox(
      width: layout.width,
      height: layout.height,
      child: Row(
        children: [
          Expanded(
            flex: 5,
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
                    child: Align(
                      alignment: Alignment.centerLeft,
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
          const Divider(),
          Expanded(
            flex: 3,
            child: Container(
              color: c.surface,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: context.padding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 520,
                            minHeight:
                                constraints.maxHeight -
                                context.padding.vertical,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: RepaintBoundary(
                              child: AnimatedSize(
                                duration: duration,
                                curve: AuthMotion.curve,
                                alignment: Alignment.topCenter,
                                child: AnimatedSwitcher(
                                  duration: duration,
                                  switchInCurve: AuthMotion.curve,
                                  switchOutCurve: AuthMotion.reverseCurve,
                                  transitionBuilder: (widget, animation) {
                                    if (reduce) return widget;
                                    return AuthMotion.fadeThroughTransition(
                                      widget,
                                      animation,
                                    );
                                  },
                                  layoutBuilder: (current, previous) {
                                    return Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        ...previous,
                                        ?current,
                                      ],
                                    );
                                  },
                                  child: KeyedSubtree(
                                    key: ValueKey(location),
                                    child: child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
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
    required this.location,
    required this.child,
  });

  final AppLayoutData layout;
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final reduce = AuthMotion.reduceMotion(context);
    final duration = AuthMotion.durationOf(context, AuthMotion.swap);

    return CardWithBackgroundWidget(
      isPrimary: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                  AuthBrandingSection(
                    layout: layout,
                    primary: c.primary,
                    textSecondary: c.textMuted,
                  ),
                  RepaintBoundary(
                    child: AnimatedSize(
                      duration: duration,
                      curve: AuthMotion.curve,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: duration,
                        switchInCurve: AuthMotion.curve,
                        switchOutCurve: AuthMotion.reverseCurve,
                        transitionBuilder: (widget, animation) {
                          if (reduce) return widget;
                          return AuthMotion.fadeThroughTransition(
                            widget,
                            animation,
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(location),
                          child: child,
                        ),
                      ),
                    ),
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
