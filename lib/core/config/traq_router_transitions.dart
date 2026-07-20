import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';

abstract final class TraqRouterTransitions {
  static const Duration _forward = Duration(milliseconds: 220);
  static const Duration _reverse = Duration(milliseconds: 200);

  static Page<T> page<T extends Object?>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: SelectionArea(child: child),
      transitionDuration: _forward,
      reverseTransitionDuration: _reverse,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) {
          return child;
        }
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.018),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Fade + scale for auth form routes inside AuthShell (no slide).
  /// Animates only the page (right form); shell branding stays mounted.
  static Page<T> authShellPage<T extends Object?>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: SelectionArea(child: child),
      transitionDuration: TraqAnimationConstants.formDuration,
      reverseTransitionDuration: TraqAnimationConstants.formDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (TraqAnimationManager.reduceMotion(context)) {
          return child;
        }
        return TraqAnimationManager.fadeScaleTransition(child, animation);
      },
    );
  }
}
