import 'package:flutter/material.dart';





abstract final class TraqAnimationConstants {
  
  static const Curve curve = Curves.easeOutCubic;
  static const Curve reverseCurve = Curves.easeInCubic;
  static const Curve iconPop = Curves.easeOutCubic;

  
  
  static const int formDurationMs = 280;

  
  static const int fastDurationMs = 160;

  
  static const int statusMs = 260;

  
  static const int staggerDelayMs = 36;

  
  static const int entranceMs = 280;

  
  static const int brandingEntranceMs = 820;
  static const int brandingStaggerMs = 88;

  
  
  static const int splashEntranceMs = 280;
  static const int splashStaggerMs = 70;
  static const int splashProgressCycleMs = 1800;
  static const Curve splashProgressCurve = Curves.easeInOutCubic;

  /// Splash logo lean: tilt right on bottom-right, then settle back.
  static const double splashTiltAngle = 0.25; // ~7°
  static const int splashTiltOutDurationMs = 800;
  static const int splashTiltReturnDurationMs = 560;
  static const int splashTiltPauseMs = 600;
  static const Curve splashTiltOutCurve = Curves.easeOut;
  static const Curve splashTiltReturnCurve = Curves.easeInBack;

  
  static const int swapMs = formDurationMs;

  
  static const double formInitialScale = 0.97;
  static const double fieldInitialScale = 0.98;
  static const double buttonInitialScale = 0.95;
  static const double statusInitialScale = 0.96;
  static const double iconPopBeginScale = 0.92;
  static const double splashInitialScale = 0.98;

  
  
  static const double fieldOffsetPx = 6;

  
  static const double splashRisePx = 5;

  
  static const double brandingSlidePx = 64;

  static const double entranceFadePortion = 0.6;

  
  static const double slideUpDy = 0.015;
  static const double slideRightDx = 0.0;
  static const Offset slideUp = Offset(0, slideUpDy);
  static const Offset slideRight = Offset(slideRightDx, 0);

  // Router / navigation motion language — slide-first, buttery decelerations.
  static const int navForwardMs = 420;
  static const int navReverseMs = 360;
  static const Curve navCurve = Curves.easeOutCubic;
  static const Curve navReverseCurve = Curves.easeInCubic;

  /// Peer replace: soft vertical slide + fade (scale kept nearly neutral).
  static const double navFadeThroughBeginScale = 0.99;
  static const double navFadeThroughIncomingStart = 0.0;
  static const double navFadeThroughOutgoingEnd = 0.45;
  static const double navFadeThroughDy = 0.04;

  /// List → detail: clear horizontal slide is the primary cue.
  static const double navSharedAxisDx = 0.18;
  static const double navSharedAxisBeginScale = 1.0;
  static const double navSharedAxisOutgoingDx = 0.08;

  /// Modal / create: vertical slide up.
  static const double navModalBeginScale = 0.99;
  static const double navModalDy = 0.08;

  static Duration get formDuration =>
      const Duration(milliseconds: formDurationMs);
  static Duration get fastDuration =>
      const Duration(milliseconds: fastDurationMs);
  static Duration get status => const Duration(milliseconds: statusMs);
  static Duration get staggerDelay =>
      const Duration(milliseconds: staggerDelayMs);
  static Duration get entrance => const Duration(milliseconds: entranceMs);
  static Duration get brandingEntrance =>
      const Duration(milliseconds: brandingEntranceMs);
  static Duration get brandingStagger =>
      const Duration(milliseconds: brandingStaggerMs);
  static Duration get splashEntrance =>
      const Duration(milliseconds: splashEntranceMs);
  static Duration get splashStagger =>
      const Duration(milliseconds: splashStaggerMs);
  static Duration get splashProgressCycle =>
      const Duration(milliseconds: splashProgressCycleMs);
  static Duration get splashTiltOutDuration =>
      const Duration(milliseconds: splashTiltOutDurationMs);
  static Duration get splashTiltReturnDuration =>
      const Duration(milliseconds: splashTiltReturnDurationMs);
  static Duration get splashTiltPause =>
      const Duration(milliseconds: splashTiltPauseMs);
  static Duration get splashTiltCycle => Duration(
        milliseconds: splashTiltOutDurationMs +
            splashTiltReturnDurationMs +
            splashTiltPauseMs,
      );
  static Duration get navForward =>
      const Duration(milliseconds: navForwardMs);
  static Duration get navReverse =>
      const Duration(milliseconds: navReverseMs);

  static Duration get swap => formDuration;
  static Duration get stagger => staggerDelay;
}
