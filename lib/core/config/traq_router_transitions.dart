import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
}
