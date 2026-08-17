import 'package:flutter/material.dart';

/// Shared non-visual timing policy for Traq motion.
abstract final class TraqAnimationManager {
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.of(context).disableAnimations;

  static Duration durationOf(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;
}
