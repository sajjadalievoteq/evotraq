import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';





abstract final class AuthMotion {
  static Duration get swap => TraqAnimationConstants.swap;
  static Duration get entrance => TraqAnimationConstants.entrance;
  static Duration get status => TraqAnimationConstants.status;
  static Duration get stagger => TraqAnimationConstants.stagger;
  static Duration get brandingEntrance =>
      TraqAnimationConstants.brandingEntrance;
  static Duration get brandingStagger => TraqAnimationConstants.brandingStagger;

  static Curve get curve => TraqAnimationConstants.curve;
  static Curve get reverseCurve => TraqAnimationConstants.reverseCurve;
  static Curve get emphasized => TraqAnimationConstants.curve;
  static Curve get iconPop => TraqAnimationConstants.iconPop;

  static double get brandingSlidePx => TraqAnimationConstants.brandingSlidePx;
  static Offset get slideRight => TraqAnimationConstants.slideRight;
  static Offset get slideUp => TraqAnimationConstants.slideUp;

  static bool reduceMotion(BuildContext context) =>
      TraqAnimationManager.reduceMotion(context);

  static Duration durationOf(BuildContext context, Duration normal) =>
      TraqAnimationManager.durationOf(context, normal);

  static Widget fadeThroughTransition(
    Widget child,
    Animation<double> animation,
  ) =>
      TraqAnimationManager.fadeThroughTransition(child, animation);

  static Widget fadeRiseTransition(
    Widget child,
    Animation<double> animation,
  ) =>
      TraqAnimationManager.fadeRiseTransition(child, animation);

  static Widget fadeScaleTransition(
    Widget child,
    Animation<double> animation, {
    double beginScale = TraqAnimationConstants.formInitialScale,
  }) =>
      TraqAnimationManager.fadeScaleTransition(
        child,
        animation,
        beginScale: beginScale,
      );
}
