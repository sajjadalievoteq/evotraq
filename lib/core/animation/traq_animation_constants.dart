import 'package:flutter/material.dart';

/// Auth motion playground tokens (Phase 1).
///
/// Keep these calm and fast — total auth entrance should feel under ~500ms.
/// Edit `*Ms` / scale / offset values here.
abstract final class TraqAnimationConstants {
  // ── Curves ───────────────────────────────────────────────────────────────
  static const Curve curve = Curves.easeOutCubic;
  static const Curve reverseCurve = Curves.easeInCubic;
  static const Curve iconPop = Curves.easeOutCubic;

  // ── Durations (ms) ───────────────────────────────────────────────────────
  /// Auth card / form page swap (fade + scale).
  static const int formDurationMs = 280;

  /// Quick feedback (button loading morph, small fades).
  static const int fastDurationMs = 160;

  /// Status / error / success cross-fades.
  static const int statusMs = 260;

  /// Stagger between auth children (fields, brand lines).
  static const int staggerDelayMs = 36;

  /// Each staggered child’s own motion window.
  static const int entranceMs = 280;

  /// Left branding: slide from panel right edge to settled left position.
  static const int brandingEntranceMs = 820;
  static const int brandingStaggerMs = 88;

  /// Splash coordinated entrance (icon → logo → status → progress).
  /// Total ≈ entrance + stagger × 3 ≈ 500–700ms.
  static const int splashEntranceMs = 280;
  static const int splashStaggerMs = 70;
  static const int splashProgressCycleMs = 1800;
  static const Curve splashProgressCurve = Curves.easeInOutCubic;

  /// Alias of [formDurationMs].
  static const int swapMs = formDurationMs;

  // ── Scales ───────────────────────────────────────────────────────────────
  static const double formInitialScale = 0.97;
  static const double fieldInitialScale = 0.98;
  static const double buttonInitialScale = 0.95;
  static const double statusInitialScale = 0.96;
  static const double iconPopBeginScale = 0.92;
  static const double splashInitialScale = 0.98;

  // ── Offsets (px) — keep tiny ─────────────────────────────────────────────
  /// Form field / line rise.
  static const double fieldOffsetPx = 6;

  /// Splash fade-rise travel (icon / logo / status).
  static const double splashRisePx = 5;

  /// Branding horizontal travel when width is unknown (prefer [LayoutBuilder] width).
  static const double brandingSlidePx = 64;

  static const double entranceFadePortion = 0.6;

  // Legacy fractional tokens (prefer px above).
  static const double slideUpDy = 0.015;
  static const double slideRightDx = 0.0;
  static const Offset slideUp = Offset(0, slideUpDy);
  static const Offset slideRight = Offset(slideRightDx, 0);

  // ── Duration getters ─────────────────────────────────────────────────────
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

  static Duration get swap => formDuration;
  static Duration get stagger => staggerDelay;
}
