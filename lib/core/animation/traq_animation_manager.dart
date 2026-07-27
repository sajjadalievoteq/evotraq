import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';

/// Shared entrance / transition helpers for Traq motion.
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

  /// Fade + scale using a [CurvedAnimation] owned by a small [StatefulWidget]
  /// so callers can safely invoke this from `build` / `transitionsBuilder`
  /// without leaking listeners each frame.
  static Widget fadeScaleTransition(
    Widget child,
    Animation<double> animation, {
    double beginScale = TraqAnimationConstants.formInitialScale,
    Alignment alignment = Alignment.center,
  }) {
    return _TraqFadeScaleTransition(
      animation: animation,
      beginScale: beginScale,
      alignment: alignment,
      child: child,
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

class _TraqFadeScaleTransition extends StatefulWidget {
  const _TraqFadeScaleTransition({
    required this.animation,
    required this.beginScale,
    required this.alignment,
    required this.child,
  });

  final Animation<double> animation;
  final double beginScale;
  final Alignment alignment;
  final Widget child;

  @override
  State<_TraqFadeScaleTransition> createState() =>
      _TraqFadeScaleTransitionState();
}

class _TraqFadeScaleTransitionState extends State<_TraqFadeScaleTransition> {
  late CurvedAnimation _curved;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _bind(widget.animation, widget.beginScale);
  }

  @override
  void didUpdateWidget(covariant _TraqFadeScaleTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.beginScale != widget.beginScale) {
      _curved.dispose();
      _bind(widget.animation, widget.beginScale);
    }
  }

  void _bind(Animation<double> parent, double beginScale) {
    _curved = CurvedAnimation(
      parent: parent,
      curve: TraqAnimationConstants.curve,
      reverseCurve: TraqAnimationConstants.reverseCurve,
    );
    _scale = Tween<double>(begin: beginScale, end: 1).animate(_curved);
  }

  @override
  void dispose() {
    _curved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: ScaleTransition(
        alignment: widget.alignment,
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
