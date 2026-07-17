import 'package:flutter/material.dart';

/// Shared motion tokens for auth screen polish (Material-aligned, subtle).
abstract final class AuthMotion {
  static const Duration swap = Duration(milliseconds: 300);
  static const Duration entrance = Duration(milliseconds: 400);
  static const Duration status = Duration(milliseconds: 320);
  static const Duration stagger = Duration(milliseconds: 90);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve reverseCurve = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve iconPop = Curves.easeOutBack;

  static const double slidePx = 14;
  static const Offset slideRight = Offset(0.04, 0);
  static const Offset slideUp = Offset(0, 0.035);

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration durationOf(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;

  /// Shared-axis fade-through for form swaps.
  static Widget fadeThroughTransition(
    Widget child,
    Animation<double> animation,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve,
      reverseCurve: reverseCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: slideRight,
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  /// Soft fade + slight rise for status / confirmation entrances.
  static Widget fadeRiseTransition(
    Widget child,
    Animation<double> animation,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve,
      reverseCurve: reverseCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: slideUp,
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
