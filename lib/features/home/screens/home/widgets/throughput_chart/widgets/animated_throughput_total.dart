import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';

/// Interpolates the headline throughput figure from its previous value.
class AnimatedThroughputTotal extends StatelessWidget {
  const AnimatedThroughputTotal({
    super.key,
    required this.value,
    required this.style,
    required this.reduceMotion,
  });

  final int value;
  final TextStyle style;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.decimalPattern().format;
    if (reduceMotion) {
      return Text(formatted(value), style: style);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: TraqAnimationManager.durationOf(
        context,
        TraqAnimationConstants.throughputMorph,
      ),
      curve: TraqAnimationConstants.curve,
      builder: (context, animated, child) {
        return Text(formatted(animated.round()), style: style);
      },
    );
  }
}
