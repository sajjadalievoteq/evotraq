import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/animation/traq_fade_scale_transition.dart';
import 'package:traqtrace_app/core/widgets/route_aware_selection_area.dart';
import 'package:traqtrace_app/core/widgets/router_transitions/traq_fade_through_transition.dart';
import 'package:traqtrace_app/core/widgets/router_transitions/traq_modal_transition.dart';
import 'package:traqtrace_app/core/widgets/router_transitions/traq_shared_axis_horizontal_transition.dart';
import 'package:traqtrace_app/core/widgets/router_transitions/transition_pointer_guard.dart';

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
/// [TraqAnimationManager.reduceMotion].
abstract final class TraqRouterTransitions {
  static Page<T> page<T extends Object?>({
    required LocalKey key,
    required Widget child,
    TraqNavigationTransitionType type =
        TraqNavigationTransitionType.fadeThrough,
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
      TraqNavigationTransitionType.auth => authShellPage(
        key: key,
        child: child,
      ),
      TraqNavigationTransitionType.modal => modalPage(
        key: key,
        child: child,
        animate: animate,
      ),
    };
  }

  /// Peer destinations: horizontal slide (right-to-left) + fade.
  static Page<T> fadeThroughPage<T extends Object?>({
    required LocalKey key,
    required Widget child,
    bool animate = true,
  }) {
    return _buildPage<T>(
      key: key,
      child: child,
      animate: animate,
      builder: (context, animation, secondaryAnimation, child) =>
          TraqFadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
    );
  }

  /// Parent-navigator page for a feature [ShellRoute].
  ///
  /// A `builder`-only [ShellRoute] is wrapped in a platform [MaterialPage],
  /// which has no horizontal slide on desktop/web. Use this so Home → feature
  /// matches other drill-downs. Pass [GoRouterState.pageKey] (stable for a
  /// given shell across child routes).
  static Page<T> featureShellPage<T extends Object?>({
    required LocalKey key,
    required Widget child,
  }) => sharedAxisHorizontalPage(key: key, child: child);

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
      builder: (context, animation, secondaryAnimation, child) =>
          TraqSharedAxisHorizontalTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
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
            : TraqFadeScaleTransition(
                animation: animation,
                beginScale: TraqAnimationConstants.formInitialScale,
                alignment: Alignment.center,
                child: child,
              );
        return TransitionPointerGuard(animation: animation, child: content);
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
      builder: (context, animation, secondaryAnimation, child) =>
          TraqModalTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
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
    )
    builder,
  }) {
    final duration = animate
        ? TraqAnimationConstants.navForward
        : Duration.zero;
    final reverseDuration = animate
        ? TraqAnimationConstants.navReverse
        : Duration.zero;

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
        return TransitionPointerGuard(animation: animation, child: content);
      },
    );
  }
}
