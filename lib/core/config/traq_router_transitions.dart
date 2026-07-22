import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/widgets/route_aware_selection_area.dart';

/// Navigation intent for page transitions — not route-specific animation code.
enum TraqNavigationTransitionType {
  /// Peer top-level destinations (workspace replace).
  fadeThrough,

  /// List → detail / push navigation (horizontal shared-axis inspired).
  sharedAxisHorizontal,

  /// Auth shell panel swaps (login, register, forgot password, …).
  auth,

  /// Wizards, create flows, overlays (shared-axis Z inspired).
  modal,
}

/// Slide-first router motion. All timings/offsets come from
/// [TraqAnimationConstants]. Reduced-motion is gated by
/// [TraqAnimationManager.reduceMotion] (currently always-on).
abstract final class TraqRouterTransitions {
  static Page<T> page<T extends Object?>({
    required LocalKey key,
    required Widget child,
    TraqNavigationTransitionType type = TraqNavigationTransitionType.fadeThrough,
    bool animate = true,
  }) {
    return switch (type) {
      TraqNavigationTransitionType.fadeThrough => fadeThroughPage(
          key: key,
          child: child,
          animate: animate,
        ),
      TraqNavigationTransitionType.sharedAxisHorizontal =>
        sharedAxisHorizontalPage(key: key, child: child, animate: animate),
      TraqNavigationTransitionType.auth =>
        authShellPage(key: key, child: child),
      TraqNavigationTransitionType.modal =>
        modalPage(key: key, child: child, animate: animate),
    };
  }

  /// Peer destinations: vertical slide + fade.
  static Page<T> fadeThroughPage<T extends Object?>({
    required LocalKey key,
    required Widget child,
    bool animate = true,
  }) {
    return _buildPage<T>(
      key: key,
      child: child,
      animate: animate,
      builder: _fadeThroughBuilder,
    );
  }

  /// List → detail: horizontal slide (primary cue) + light fade.
  static Page<T> sharedAxisHorizontalPage<T extends Object?>({
    required LocalKey key,
    required Widget child,
    bool animate = true,
  }) {
    return _buildPage<T>(
      key: key,
      child: child,
      animate: animate,
      builder: _sharedAxisHorizontalBuilder,
    );
  }

  /// Auth shell panel content — existing fade + scale.
  static Page<T> authShellPage<T extends Object?>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: RouteAwareSelectionArea(child: child),
      transitionDuration: TraqAnimationConstants.formDuration,
      reverseTransitionDuration: TraqAnimationConstants.formDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final content = TraqAnimationManager.reduceMotion(context)
            ? child
            : TraqAnimationManager.fadeScaleTransition(child, animation);
        return _TransitionPointerGuard(animation: animation, child: content);
      },
    );
  }

  /// Modal / create: vertical slide up + fade.
  static Page<T> modalPage<T extends Object?>({
    required LocalKey key,
    required Widget child,
    bool animate = true,
  }) {
    return _buildPage<T>(
      key: key,
      child: child,
      animate: animate,
      builder: _modalBuilder,
    );
  }

  static Page<T> _buildPage<T extends Object?>({
    required LocalKey key,
    required Widget child,
    required bool animate,
    required Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) builder,
  }) {
    final duration =
        animate ? TraqAnimationConstants.navForward : Duration.zero;
    final reverseDuration =
        animate ? TraqAnimationConstants.navReverse : Duration.zero;

    return CustomTransitionPage<T>(
      key: key,
      child: RouteAwareSelectionArea(child: child),
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Widget content;
        if (!animate || TraqAnimationManager.reduceMotion(context)) {
          content = child;
        } else {
          content = builder(context, animation, secondaryAnimation, child);
        }
        return _TransitionPointerGuard(animation: animation, child: content);
      },
    );
  }

  static CurvedAnimation _primary(Animation<double> animation) {
    return CurvedAnimation(
      parent: animation,
      curve: TraqAnimationConstants.navCurve,
      reverseCurve: TraqAnimationConstants.navReverseCurve,
    );
  }

  /// Peer: slide up slightly while fading in; outgoing eases out.
  static Widget _fadeThroughBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = _primary(animation);
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: TraqAnimationConstants.navCurve,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.4).animate(outgoing),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -TraqAnimationConstants.navFadeThroughDy * 0.5),
        ).animate(outgoing),
        child: FadeTransition(
          opacity: incoming,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, TraqAnimationConstants.navFadeThroughDy),
              end: Offset.zero,
            ).animate(incoming),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Detail push: enter from trailing edge; exit opposite — slide only + fade.
  static Widget _sharedAxisHorizontalBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final primary = _primary(animation);
    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: TraqAnimationConstants.navCurve,
      reverseCurve: TraqAnimationConstants.navReverseCurve,
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final enterDx = isRtl
        ? -TraqAnimationConstants.navSharedAxisDx
        : TraqAnimationConstants.navSharedAxisDx;
    final exitDx = isRtl
        ? TraqAnimationConstants.navSharedAxisOutgoingDx
        : -TraqAnimationConstants.navSharedAxisOutgoingDx;

    // Fade only the first portion so the slide reads cleanly.
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.55, curve: TraqAnimationConstants.navCurve),
      reverseCurve: const Interval(
        0.45,
        1.0,
        curve: TraqAnimationConstants.navReverseCurve,
      ),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.65).animate(secondary),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: Offset(exitDx, 0),
        ).animate(secondary),
        child: FadeTransition(
          opacity: fadeIn,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(enterDx, 0),
              end: Offset.zero,
            ).animate(primary),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Modal: slide up from below + fade.
  static Widget _modalBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final primary = _primary(animation);
    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: TraqAnimationConstants.navCurve,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.75).animate(secondary),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.02),
        ).animate(secondary),
        child: FadeTransition(
          opacity: primary,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, TraqAnimationConstants.navModalDy),
              end: Offset.zero,
            ).animate(primary),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Blocks pointer input while a route transition is in flight.
class _TransitionPointerGuard extends StatelessWidget {
  const _TransitionPointerGuard({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final animating = animation.status == AnimationStatus.forward ||
            animation.status == AnimationStatus.reverse;
        return IgnorePointer(ignoring: animating, child: child!);
      },
    );
  }
}
