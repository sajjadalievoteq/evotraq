import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared [Page] transitions for [GoRouter] routes.
abstract final class TraqRouterTransitions {
  static const Duration _forward = Duration(milliseconds: 220);
  static const Duration _reverse = Duration(milliseconds: 200);

  /// Light fade with a short vertical slide — keeps navigations readable on web.
  static Page<T> page<T extends Object?>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
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
}
