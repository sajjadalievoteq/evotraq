import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';

/// App-wide animation helpers (reduced-motion, shared transitions).
///
/// Tunable values live in [TraqAnimationConstants]. Widgets:
/// [TraqStaggeredEntrance], [TraqStatusSwitcher], [TraqIconPop].
///
/// Prefer subtle **fade + scale** over large slides (premium Material Motion).
abstract final class TraqAnimationManager {
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration durationOf(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;

  /// Premium form / page transition: opacity + slight scale (no slide).
  static Widget fadeScaleTransition(
    Widget child,
    Animation<double> animation, {
    double beginScale = TraqAnimationConstants.formInitialScale,
    Alignment alignment = Alignment.center,
  }) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: TraqAnimationConstants.curve,
      reverseCurve: TraqAnimationConstants.reverseCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        alignment: alignment,
        scale: Tween<double>(begin: beginScale, end: 1).animate(curved),
        child: child,
      ),
    );
  }

  /// Auth / form route swaps. Historically “fade-through”; now fade + scale
  /// with no noticeable translation. API preserved for callers.
  static Widget fadeThroughTransition(
    Widget child,
    Animation<double> animation,
  ) {
    return fadeScaleTransition(
      child,
      animation,
      beginScale: TraqAnimationConstants.formInitialScale,
    );
  }

  /// Status / confirmation swaps. Fade + scale (no slide). API preserved.
  static Widget fadeRiseTransition(
    Widget child,
    Animation<double> animation,
  ) {
    return fadeScaleTransition(
      child,
      animation,
      beginScale: TraqAnimationConstants.statusInitialScale,
      alignment: Alignment.topCenter,
    );
  }
}
