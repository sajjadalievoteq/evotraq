import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';







abstract final class TraqAnimationManager {
  /// Single toggle for reduced-motion honoring.
  ///
  /// Always returns `false` so page transitions and entrance animations play
  /// regardless of OS/browser `prefers-reduced-motion`. To restore respecting
  /// that preference, replace the body with:
  /// `MediaQuery.disableAnimationsOf(context)`.
  static bool reduceMotion(BuildContext context) => false;

  static Duration durationOf(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;

  
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

  
  /// Peer-level fade-through (subtle scale, no slide).
  static Widget fadeThroughTransition(
    Widget child,
    Animation<double> animation,
  ) {
    return fadeScaleTransition(
      child,
      animation,
      beginScale: TraqAnimationConstants.navFadeThroughBeginScale,
    );
  }

  
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
